class AuthorizationController < ApplicationController

  def connect_to_spotify
    cookies[:last_page_visit] = request.referrer
    redirect_to APIClient.get_user_authorization_url
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
    token_response = APIClient.request_user_tokens(authorization_token)
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
    user_id = APIClient.get_spotify_user_id(cookies[:spotify_access_token])
    cookies.permanent[:sp_user_id] = user_id if user_id
  end

  def save_tokens_in_cookie(access_token, refresh_token, expires_in)
    cookies[:spotify_access_token] = { value: access_token, expires: expires_in.seconds.from_now }
    cookies.permanent[:spotify_refresh_token] = refresh_token
  end
end
