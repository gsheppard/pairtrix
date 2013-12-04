class SessionsController < ApplicationController

  skip_authorization_check

  def create
    @user = User.from_omniauth(env['omniauth.auth'])
    session[:user_id] = @user.id
    redirect_url = (@user.save_last_viewed_url? && !@user.last_viewed_url.blank?) ? @user.last_viewed_url : dashboard_url
    redirect_to(redirect_url, flash: { success: 'Signed in successfully.' })
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_url, flash: { notice: 'Signed out successfully.' }
  end

  def failure
    redirect_to root_url, flash: { error: 'Authentication failed, please try again.' }
  end

end
