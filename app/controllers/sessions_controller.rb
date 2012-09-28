class SessionsController < ApplicationController

  def create
    session['omniauth.auth'] = request.env['omniauth.auth']
    redirect_to root_path
  end
end