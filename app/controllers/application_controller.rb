class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def update_access_token_cookie(access_token:, expires_in: 3600)
    cookies[:sp_access_token] = { value: access_token, expires: expires_in.seconds.from_now }
  end

  def user_access_token
    cookies[:sp_access_token].presence || get_new_access_token
  end

  # rubocop:disable Naming/AccessorMethodName
  def get_new_access_token
    new_token = UserAPIClient.refresh_access_token(cookies[:sp_refresh_token])
    update_access_token_cookie(access_token: new_token)
    new_token
  end
  # rubocop:enable Naming/AccessorMethodName
end
