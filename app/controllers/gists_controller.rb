require "queue_classic"

class GistsController < ApplicationController

  before_filter :force_user_login

  def index
    @gists = current_user.gists.includes(:files)
  end

  def refresh
    QC.enqueue("GistFetcher.fetch_user_gists", current_user.id)
    redirect_to gists_path
  end
end