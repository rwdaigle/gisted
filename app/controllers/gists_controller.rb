require "queue_classic"

class GistsController < ApplicationController

  before_filter :force_user_login

  JUMP_CHAR = '!'

  def index
    @gists = current_user.gists.order("gh_created_at DESC").includes(:files)
  end

  def search
    @results = Gist.search(current_user, normalized_query)
    if(feeling_lucky_directive? && lucky_result = @results.first)
      redirect_to lucky_result.url
      log({ns: self.class, fn: __method__, measure: true, at: 'auto-jump', query: params[:q]}, {:'redirect-to' => lucky_result.url}, current_user)
    end
  end

  def refresh
    QC.enqueue("GistFetcher.fetch_user", current_user.id)
    redirect_to search_gists_path
  end

  private

  # Strip navigational search directives ("!") without modifying original query param
  def normalized_query
    @normalized_query ||= feeling_lucky_directive? ? params[:q][0..-2] : params[:q]
  end

  def feeling_lucky_directive?
    params[:q] && JUMP_CHAR == params[:q].last
  end

end