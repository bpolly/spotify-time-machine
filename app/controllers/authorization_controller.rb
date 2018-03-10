class AuthorizationController < ApplicationController

  def connect_to_spotify
    unless request.referrer.include?('connect_to_spotify')
      cookies[:last_page_visit] = { value: request.referrer, expires: 20.minutes.from_now }
    end
    redirect_to UserAPIClient.get_user_authorization_url
  end

  def disconnect_from_spotify
    [:sp_user_id, :sp_access_token, :sp_refresh_token, :last_page_visit].each do |cookie|
      cookies.delete(cookie)
    end
    redirect_to 'https://www.spotify.com/account/apps/'
  end

  def landing
    authorization_token = params[:code]
    state = params[:state]
    save_tokens(authorization_token: authorization_token)
    save_user_id
    redirect_to (cookies[:last_page_visit] || root_path)
  end

  private

  def save_tokens(authorization_token:)
    token_response = UserAPIClient.request_user_tokens(authorization_token)
    if(token_response.success?)
      parsed_response = JSON.parse(token_response.body, object_class: OpenStruct)
      save_tokens_in_cookie(
        parsed_response.access_token,
        parsed_response.refresh_token,
        parsed_response.expires_in
      )
      return true
    end
    false
  end

  def save_user_id
    user_id = UserAPIClient.get_spotify_user_id(cookies[:sp_access_token])
    cookies.permanent[:sp_user_id] = user_id if user_id
  end

  def save_tokens_in_cookie(access_token, refresh_token, expires_in)
    cookies[:sp_access_token] = { value: access_token, expires: expires_in.seconds.from_now }
    cookies.permanent[:sp_refresh_token] = refresh_token
  end
end
