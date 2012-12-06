class UsersController < ApplicationController

  before_filter :force_user_login

  def toggle_notifications
    current_user.toggle_notifications
    redirect_to :back
  end
end