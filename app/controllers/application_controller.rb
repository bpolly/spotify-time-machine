class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def update_access_token_cookie(access_token:, expires_in: 3600)
    cookies[:spotify_access_token] = { value: access_token, expires: expires_in.seconds.from_now }
  end

  def user_access_token
    cookies[:spotify_access_token] || get_new_access_token
  end

  def get_new_access_token
    new_token = APIClient.refresh_access_token(refresh_token)
    update_access_token_cookie(access_token: new_token)
    new_token
  end
end
