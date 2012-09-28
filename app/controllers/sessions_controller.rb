class SessionsController < ApplicationController

  def login
    puts url_for("/auth/github?request_uri=#{root_path(:only_path => false)}")
    redirect_to url_for("/auth/github?request_uri=#{root_path(:only_path => false)}")
  end

  def create
    session['omniauth.auth'] = request.env['omniauth.auth']
    redirect_to root_path
  end
end