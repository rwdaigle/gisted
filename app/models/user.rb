class User < ActiveRecord::Base

  attr_accessible :gh_id, :gh_email, :gh_name, :gh_avatar_url, :gh_oauth_token, :gh_url, :gh_username

  has_many :gists, :dependent => :destroy
  has_many :files, :through => :gists

  scope :last_fetched_before, lambda { |since| where(["last_gh_fetch < ? OR last_gh_fetch IS NULL", since])}

  class << self

    def authenticate(auth)

      attributes = {
        gh_id: auth.uid, gh_oauth_token: auth.credentials.token, gh_username: auth.info.nickname, gh_name: auth.info.name,
        gh_email: auth.info.email, gh_avatar_url: auth.info.image, gh_url: auth.info.urls.GitHub
      }

      if(existing_user = User.where(gh_id: auth.uid).first)
        log({ns: self, fn: __method__, measure: true, at: 'user-authenticated'}, existing_user)
        existing_user.update_attributes(attributes)
        existing_user
      else
        new_user = User.create(attributes)
        log({ns: self, fn: __method__, measure: true, at: 'user-created'}, new_user)
        new_user
      end
    end

    def refresh_index(user_id)
      user = User.find(user_id)
      log({ns: self, fn: __method__}, user) do
        user.gists.each { |gist| gist.update_index }
      end
      Gist.tire.index.refresh
    end

    def fetched!(user_id)
      user = User.find(user_id)
      user.fetched!
    end
  end

  def fetched!
    update_attribute(:last_gh_fetch, Time.now)
  end

  def gists_count
    @gists_count ||= gists.count
  end

  def files_count
    @files_count ||= files.count
  end

  def fetched?
    !last_gh_fetch.nil?
  end

  def to_log
    { user: gh_username, user_id: id, user_email: gh_email }
  end
end
