module SessionsHelper
  def current_user
    @current_user ||= User.find_by_id(session[:user_id]) if session[:user_id]
  end

  def valid_signin_token?
    session[:sign_in_token].present? && (current_user.current_sign_in_token == session[:sign_in_token])
  end

  def valid_current_user?
    current_user.present? && current_user.active? && valid_signin_token? && !current_user.inactive?
  end

  def link_to_logout
    link_to 'Sign out', logout_path, method: :delete
  end

  def clear_session
    session[:user_id] = nil
    session[:verified_email] = nil
    session[:sign_in_token] = nil
  end
end
