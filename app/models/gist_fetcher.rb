  class GistFetcher

  class << self

    def fetch
      log({ns: self, fn: __method__}) do
        User.active_auth.pluck(:id).each do |user_id|
          QUEUE.enqueue("GistFetcher.fetch_gists", user_id)
          QUEUE.enqueue("GistFetcher.fetch_starred_gists", user_id)
        end
      end
    end

    # TODO: lot of dup w/ fetch_starred_gists
    def fetch_gists(user_id)

      user = User.find(user_id)
      since = user.last_gist_updated_at(user.gists.not_starred)
      since = since ? (since + 1.second) : since

      gh_client(user) do |gh|
        log({ns: self, fn: __method__, measure: true, since: since}, user) do
          gh.gists(nil, since: since).each do |gh_gist|
            Gist.import(user_id, gh_gist)
            GistFetcher.fetch_gist_files(user_id, gh_gist.id)
          end
        end
      end
    end

    def fetch_starred_gists(user_id)

      user = User.find(user_id)
      since = user.last_gist_updated_at(user.gists.starred)
      since = since ? (since + 1.second) : since

      gh_client(user) do |gh|
        log({ns: self, fn: __method__, measure: true, since: since}, user) do
          gh.starred_gists(since: since).each do |gh_gist|
            Gist.import(user_id, gh_gist, starred: true)
            GistFetcher.fetch_gist_files(user_id, gh_gist.id)
          end
        end
      end
    end

    def fetch_gist_files(user_id, gh_gist_id)
      user = User.find(user_id)
      log({ns: self, fn: __method__, measure: true, gh_gist_id: gh_gist_id}, user) do
        gh_client(user) do |gh|
          GistFile.import(user_id, gh.gist(gh_gist_id))
        end
      end
    end

    private

    def gh_client(user)
      begin
        yield Octokit::Client.new(:login => user.gh_username, :oauth_token => user.gh_oauth_token, :auto_traversal => true)
      rescue Octokit::Unauthorized => e
        log_exception({ns: self, fn: __method__, measure: true}, user, e)
        user.invalidate_auth!
      end
    end

  end
end