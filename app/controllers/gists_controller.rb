class GistsController < ApplicationController

  before_filter :force_user_login

  def index
    @gists = gh_client.gists
  end

  protected

  def gh_client
    @gh_client ||= Octokit::Client.new(:login => current_user.gh_username, :oauth_token => current_user.gh_oauth_token)
  end
end