class SessionsController < ApplicationController

  def logout
    log_out_user
    redirect_to root_path
  end

  def create
    user = User.authenticate(request.env['omniauth.auth'])
    log_in_user(user.id)
    log({ns: self.class, fn: __method__, measure: true, at: 'login'}, user)
    if(user.fetched?)
      log({ns: self.class, fn: __method__, measure: true, at: 'repeat-login'}, user)
      redirect_to(request.env['omniauth.origin'] || search_gists_path)
    else
      log({ns: self.class, fn: __method__, measure: true, at: 'first-login'}, user)
      QC.enqueue("GistFetcher.fetch_user", user.id)
      redirect_to status_gists_path
    end
  end

  def failure
    log({ns: self.class, fn: __method__, measure: true, at: 'login-failure'}, request.env['omniauth.auth'])    
  end
end