class User < ActiveRecord::Base

  attr_accessible :gh_avatar_url, :gh_oauth_token, :gh_url, :gh_username

  class << self

    def authorize(auth)
      token = auth.credentials.token
      user = User.find_by_gh_oauth_token(token)
      user = create_from_gh_oauth(token, auth) unless user
      return user
    end

    def create_from_gh_oauth(token, auth)
      gh_username, gh_avatar_url, gh_url = auth.info.nickname, auth.info.image, auth.info.GitHub
      User.create(gh_oauth_token: token, gh_username: gh_username, gh_avatar_url: gh_avatar_url, gh_url: gh_url)
    end
  end

  # Don't like this hear, but it's convenient for now
  def gh_client
    @gh_client ||= Octokit::Client.new(:login => gh_username, :oauth_token => gh_oauth_token)
  end
end
