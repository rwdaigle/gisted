require "queue_classic"

class GistsController < ApplicationController

  before_filter :force_user_login

  def index
    @gists = current_user.gists.order("gh_created_at DESC").includes(:files)
  end

  def search
    @results = Gist.search(current_user, params[:q])
  end

  def refresh
    QC.enqueue("GistFetcher.fetch_user", current_user.id)
    redirect_to search_gists_path
  end
end