class ApplicationController < ActionController::Base

  protect_from_forgery

  protected

  def log_in_user(user_id)
    session[:user_id] = user_id
  end

  def log_out_user
    session.clear
    session[:user_id] = nil
  end

  def user_logged_in?
    !!current_user
  end

  def force_user_login
    redirect_to login_path unless user_logged_in?
  end

  def current_user
    begin
      @current_user ||= session[:user_id] ? User.find(session[:user_id]) : nil
    rescue Exception => e
      nil
    end
  end
end
