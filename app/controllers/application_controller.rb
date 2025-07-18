class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern


  def encode_token(payload)
    JWT.encode(payload, ENV['JWT_SECRET'])
  end

  def decode_token
    auth_header = request.headers['Authorization']
    if auth_header
        token = auth_header.split(' ')[1]
        begin
            JWT.decode(token, ENV['JWT_SECRET'])
        rescue JWT::DecodeError
            nil
        end
    end
  end

    def authorized_user
      jwt_token = decode_token()
      if jwt_token
          user_id = jwt_token[0]['user']
          @current_user = User.find_by(id: user_id)
      end
    end
  

  def authorize
      render json: { message: 'You have to log in.' }, status: :unauthorized unless authorized_user
  end

  def authenticate_admin!
    unless @current_user.is_a?(Administrator)
      render json: { error: "Only admin can use this" }, status: :unauthorized
    end
  end
  protected
  def current_administrator
    @current_user if @current_user.is_a?(Administrator)
  end
end
