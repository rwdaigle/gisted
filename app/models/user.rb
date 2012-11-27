class User < ActiveRecord::Base

  attr_accessible :gh_id, :gh_email, :gh_name, :gh_avatar_url, :gh_oauth_token, :gh_url, :gh_username, :gh_auth_active

  has_many :gists, :dependent => :destroy
  has_many :files, :through => :gists

  scope :active_auth, where(gh_auth_active: true)

  class << self

    def authenticate(auth)

      attributes = {
        gh_id: auth.uid, gh_oauth_token: auth.credentials.token, gh_username: auth.info.nickname, gh_name: auth.info.name,
        gh_email: auth.info.email, gh_avatar_url: auth.info.image, gh_url: auth.info.urls.GitHub, gh_auth_active: true
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

    def refresh_indexes(all = false)
      User.active_auth.pluck(:id).each do |user_id|
        refresh_index(user_id, all)
      end
    end

    def refresh_index(user_id, all = false)
      user = User.find(user_id)
      log({ns: self, fn: __method__}, user) do
        Gist.reindex(all ? user.gists : user.gists.since(user.last_indexed_at))
        user.indexed!
      end
    end
  end

  def indexed!
    update_attribute(:last_indexed_at, Time.now)
  end

  def indexed?
    !last_indexed_at.nil?
  end

  def last_gist_updated_at(gist_scope = gists)
    gist = gist_scope.order("gh_updated_at DESC").first
    gist ? gist.gh_updated_at : nil
  end

  def invalidate_auth!
    update_attribute(:gh_auth_active, false)
  end

  def gists_count
    @gists_count ||= gists.count
  end

  def files_count
    @files_count ||= files.count
  end

  def to_log
    { user: gh_username, user_id: id, user_email: gh_email }
  end
end
