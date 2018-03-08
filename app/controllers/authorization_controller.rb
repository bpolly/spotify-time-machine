class AuthorizationController < ApplicationController

  def get_user_authorization
    cookies[:last_page_visit] = request.referrer
    redirect_to APIClient.get_user_authorization_url
  end

  def landing
    authorization_token = params[:code]
    state = params[:state]
    # byebug
    token_response = APIClient.request_user_tokens(authorization_token)
    if(token_response)
      parsed_response = JSON.parse(token_response.body, object_class: OpenStruct)
      save_tokens_in_cookie(
        parsed_response.access_token,
        parsed_response.refresh_token,
        parsed_response.expires_in
      )
    end
    redirect_to (cookies[:last_page_visit] || root_path)
  end

  private

  def save_tokens_in_cookie(access_token, refresh_token, expires_in)
    cookies[:spotify_access_token] = { value: access_token, expires: expires_in.seconds.from_now }
    cookies.permanent[:spotify_refresh_token] = refresh_token
  end
end
