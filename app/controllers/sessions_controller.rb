class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      redirect_to user
    else
      flash[:errors] = "Incorrect email or password."
      redirect_to login_path
  end

  def destroy
  end
end
