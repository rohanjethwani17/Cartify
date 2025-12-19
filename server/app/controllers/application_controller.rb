class ApplicationController < ActionController::API
  include ActionController::Cookies

  before_action :set_current_user

  private

  def set_current_user
    @current_user = authenticate_user_from_token
  end

  def authenticate_user_from_token
    auth_header = request.headers['Authorization']
    return nil unless auth_header&.start_with?('Bearer ')

    token = auth_header.split.last
    User.from_jwt(token)
  end

  attr_reader :current_user
end
