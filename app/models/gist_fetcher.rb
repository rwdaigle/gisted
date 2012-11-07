  class GistFetcher

  class << self

    def fetch
      period = ENV['FETCH_INTERVAL_MINS'] ? ENV['FETCH_INTERVAL_MINS'].to_i : 1440
      since = period.minutes.ago
      log({ns: self, fn: __method__}, since: since) do
        User.last_fetched_before(since).active_auth.pluck(:id).each do |user_id|
          QC.enqueue("GistFetcher.fetch_gists", user_id)
        end
      end
    end

    def fetch_gists(user_id)

      user = User.find(user_id)

      gh_client(user) do |gh|
        log({ns: self, fn: __method__, measure: true}, user) do
          gh.gists.each do |gh_gist|
            Gist.import(gh_gist)
          end
          user.gists.pluck(:gh_id).each do |gh_gist_id|
            QC.enqueue("GistFetcher.fetch_gist_files", user_id, gh_gist_id)
          end
        end
        QC.enqueue("User.refresh_index", user_id)
        QC.enqueue("User.fetched!", user_id)
      end
    end

    def fetch_gist_files(user_id, gh_gist_id)
      user = User.find(user_id)
      log({ns: self, fn: __method__, measure: true, gh_gist_id: gh_gist_id}, user) do
        gh = gh_client(user)
        GistFile.import(gh.gist(gh_gist_id))
      end
    end

    private

    def gh_client(user)
      client = Octokit::Client.new(:login => user.gh_username, :oauth_token => user.gh_oauth_token, :auto_traversal => true)
      begin
        client.user # throws exception if oauth not cool
        yield client
      rescue Octokit::Unauthorized => e
        log_exception({ns: self, fn: __method__, measure: true}, user, e)
        user.invalidate_auth!
      end
    end

  end
end