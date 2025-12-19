module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      # Extract token from query params or headers
      token = request.params[:token] || request.headers['Authorization']&.split&.last

      if token.present?
        user = User.from_jwt(token)
        return user if user
      end

      # Allow anonymous connections for public subscriptions
      # but they won't be able to access protected resources
      nil
    end
  end
end
