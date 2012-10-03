class User < ActiveRecord::Base

  attr_accessible :gh_id, :gh_email, :gh_name, :gh_avatar_url, :gh_oauth_token, :gh_url, :gh_username

  has_many :gists, :dependent => :destroy

  class << self

    def authenticate(auth)

      attributes = {
        gh_id: auth.uid, gh_oauth_token: auth.credentials.token, gh_username: auth.info.nickname, gh_name: auth.info.name,
        gh_email: auth.info.email, gh_avatar_url: auth.info.image, gh_url: auth.info.urls.GitHub
      }

      if(existing_user = User.where(gh_id: auth.uid).first)
        existing_user.update_attributes(attributes)
        existing_user
      else
        User.create(attributes)
      end
    end
  end
end
