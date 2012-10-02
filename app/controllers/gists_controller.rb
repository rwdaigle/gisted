require "queue_classic"

class GistsController < ApplicationController

  before_filter :force_user_login

  def index
    @gists = [] #current_user.gh_client.gists
  end

  def refresh
    puts QC.enqueue("GistFetcher.fetch", current_user.id)
    redirect_to gists_path
  end
end