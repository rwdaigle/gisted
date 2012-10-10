class HomesController < ApplicationController

  before_filter :skip_if_logged_in, :only => :index

  private

  def skip_if_logged_in
    redirect_to search_gists_path if user_logged_in?
  end

end