# frozen_string_literal: true

class Users::SessionsController < ApplicationController

  skip_before_action :verify_authenticity_token

  def create
    @user = User.new(user_params)
    @user.type = "Client"
    if @user.save
      token = encode_token(@user)
      render json: { user: @user, token: token }, status: :created
    else
      render json: { message: "User creation failed" }, status: :unprocessable_entity
    end
  end

  def login
    @user = User.find_by(email: user_params[:email])
    if @user && @user.authenticate(user_params[:password])
      token = encode_token({user: @user.id})
      render json: { user: @user, token: token }, status: :ok
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end


  
  private

  def user_params
    params.require(:user).permit(:email, :name, :password)
  end

end
