class GistFetcher

  class << self

    def fetch(user_id)
      user = User.find(user_id)
      log({ns: self, fn: __method__}, user) do
        gh = gh_client(user)
        fetch_gists(gh, user)
        fetch_files(gh, user)
        update_search_indices(user)
      end
    end

    protected

    # Make sure have all gist stubs imported
    def fetch_gists(gh, user)
      log({ns: self, fn: __method__}, user) do
        gh.gists.each do |gh_gist|
          Gist.import(gh_gist)
        end
      end
    end

    # Fetch individual gists from API to get file contents
    def fetch_files(gh, user)
      log({ns: self, fn: __method__}, user) do
        user.gists.pluck(:gh_id).each do |gh_gist_id|
          GistFile.import(gh.gist(gh_gist_id))
        end
      end
    end

    def update_search_indices(user)
      log({ns: self, fn: __method__}, user) do
        user.gists.each { |gist| gist.update_index }
      end
    end

    private

    def gh_client(user)
      Octokit::Client.new(:login => user.gh_username, :oauth_token => user.gh_oauth_token, :auto_traversal => true)
    end

  end
end