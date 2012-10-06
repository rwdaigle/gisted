class SessionsController < ApplicationController

  def login
    redirect_to "/auth/github"
  end

  def logout
    log_out_user
    redirect_to root_path
  end

  def create
    user = User.authenticate(request.env['omniauth.auth'])
    log_in_user(user.id)
    log({ns: self.class, fn: __method__, measure: true, at: 'login'}, user)
    QC.enqueue("GistFetcher.fetch_user", user.id) if !user.fetched?
    redirect_to search_gists_path
  end
end