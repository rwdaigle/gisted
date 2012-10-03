class GistFetcher

  class << self

    def fetch_user_gists(user_id)
      user = User.find(user_id)
      gh_client(user).gists.each do |gh_gist|
        # TODO add Scrolls logging
        Gist.import(gh_gist)
      end
    end

    # Fetch individual gists from API (needed only for additional info?)
    # def fetch_gist(user_id, gist_gh_id)
    #   user = User.find(user_id)
    #   gh_gist = user.gh_client.gist(gist_gh_id)
    #   # TODO: Persist gist
    #   # Gist.transfer_from_gh(user_id, gh_gist)
    # end

    private

    def gh_client(user)
      Octokit::Client.new(:login => user.gh_username, :oauth_token => user.gh_oauth_token, :auto_traversal => true)
    end

  end
end