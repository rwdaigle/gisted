class HomesController < ApplicationController

  def index
    username, token = session['omniauth.auth'].info.nickname, session['omniauth.auth'].credentials.token
    client = Octokit::Client.new(:login => username, :oauth_token => token)
    @gists = client.gists
  end
end