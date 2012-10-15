class GistFetcher

  class << self

    def fetch
      period = ENV['FETCH_INTERVAL_MINS'] ? ENV['FETCH_INTERVAL_MINS'].to_i : 1440
      since = period.minutes.ago
      log({ns: self, fn: __method__}, since: since) do
        User.last_fetched_before(since).pluck(:id).each do |user_id|
          fetch_user(user_id)
        end
      end
    end

    def fetch_user(user_id)
      user = User.find(user_id)
      log({ns: self, fn: __method__}, user) do
        gh = gh_client(user)
        fetch_gists(gh, user)
        fetch_files(gh, user)
        update_search_indices(user)
      end
      user.update_attribute(:last_gh_fetch, Time.now)
    end

    protected

    # Make sure have all gist stubs imported
    def fetch_gists(gh, user)
      log({ns: self, fn: __method__, measure: true}, user) do
        begin
          gh.gists.each do |gh_gist|
            Gist.import(gh_gist)
          end
        rescue Exception => e
          Airbrake.notify(e, parameters: user.to_log)
          log({ns: self, fn: __method__, measure: true, at: :exception, message: e.message, exception: e.class}, user)
        end
      end
    end

    # Fetch individual gists from API to get file contents
    def fetch_files(gh, user)
      log({ns: self, fn: __method__, measure: true}, user) do
        user.gists.pluck(:gh_id).each do |gh_gist_id|
          begin
            GistFile.import(gh.gist(gh_gist_id))
          rescue Exception => e
            Airbrake.notify(e, parameters: user.to_log.merge(gh_gist_id: gh_gist_id))
            log({ns: self, fn: __method__, measure: true, gh_gist_id: gh_gist_id, at: :exception, message: e.message, exception: e.class}, user)
          end
        end
      end
    end

    def update_search_indices(user)
      log({ns: self, fn: __method__}, user) do
        user.gists.each { |gist| gist.update_index }
      end
      Gist.tire.index.refresh
    end

    private

    def gh_client(user)
      Octokit::Client.new(:login => user.gh_username, :oauth_token => user.gh_oauth_token, :auto_traversal => true)
    end

  end
end