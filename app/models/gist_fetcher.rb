class GistFetcher

  class << self

    def fetch(user_id)
      user = User.find(user_id)
      user.gh_client.gists.each do |gh_gist|
        # Create local gist
      end
    end
  end
end