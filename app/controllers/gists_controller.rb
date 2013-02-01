class GistsController < ApplicationController

  before_filter :force_user_login

  JUMP_CHAR = '!'

  # def index
  #   @gists = current_user.gists.order("gh_created_at DESC").includes(:files)
  # end

  def search
    if(!cache? || stale?(etag: search_etag, last_modified: current_user.updated_at))
      @results = Gist.search(current_user, normalized_query)
      if(feeling_lucky_directive? && lucky_result = @results.first)
        redirect_to lucky_result.url
      elsif(pjax?)
        render :partial => "results"
      end
    end
  end

  def refresh
    QUEUE.enqueue("GistFetcher.fetch_gists", current_user.id)
    redirect_to search_gists_path
  end

  private

  # Strip navigational search directives ("!") without modifying original query param
  # This is at the controller level b/c it's a navigational command, not a search command
  def normalized_query
    @normalized_query ||= feeling_lucky_directive? ? params[:q][0..-2] : params[:q]
  end

  def feeling_lucky_directive?
    params[:q] && JUMP_CHAR == params[:q].last
  end

  def search_etag
    "#{CACHE_VERSION}-#{current_user.id}-pjax:#{pjax?}-#{params[:q]}"
  end

  def pjax?
    !request.headers['X-PJAX'].blank?
  end

  def cache?
    CACHE_ACTIVE
  end

end