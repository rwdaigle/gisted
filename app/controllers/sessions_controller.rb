class SessionsController < ApplicationController

  def login
    redirect_to "/auth/github"
  end

  def logout
    log_out_user
    redirect_to root_path
  end

  def create
    user = User.authorize(request.env['omniauth.auth'])
    log_in_user(user.id)
    redirect_to gists_path
  end
end