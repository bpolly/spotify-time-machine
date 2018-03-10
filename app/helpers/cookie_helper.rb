module CookieHelper
  def current_user_name
    cookies[:sp_user_id]
  end

  def connected_to_spotify?
    cookies[:sp_refresh_token].present?
  end
end
