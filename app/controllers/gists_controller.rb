require "queue_classic"

class GistsController < ApplicationController

  before_filter :force_user_login

  def index
    @gists = [] #gh_client.gists
  end

  def refresh
    puts QC.enqueue("GistFetcher.fetch", current_user.id)
    redirect_to gists_path
  end

  protected

  def gh_client
    @gh_client ||= Octokit::Client.new(:login => current_user.gh_username, :oauth_token => current_user.gh_oauth_token)
  end
end