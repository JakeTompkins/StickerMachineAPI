class UsersController < ApplicationController
  # before_action :authenticate_user, only: [:update]
  

  # def create
  #   code = params[:code]
  #   @user = User.find_by_email(wechat_email(code).downcase) || User.create!(user_params(code))
  #   render json: @user
  # end 

  def register
    code = params[:code]
    params = user_params(code)

    @user = User.new(params)
    if @user.save!
      render_data(data: @user.as_json)
    else
      @user.errors.each { |error, message| p "#{error}: #{message}" }
      render_error(error: "User could not be saved")
    end

    # code = params[:code]
    # @user = User.find_by_email(wechat_email(code).downcase) || User.create!(user_params(code))

    # render json: @user
  end

  def wechat_email(code)
    @wechat_email ||= fetch_open_id(code)  + "@stickermachine.cool"
  end

  def fetch_open_id(code)
    url = "https://api.weixin.qq.com/sns/jscode2session"
    wechat_params = {
      appid: ENV['wechat_app_id'],
      secret: ENV['wechat_app_secret'],
      js_code: code,
      grant_type: 'authorization_code' }
    response = RestClient.post(url, wechat_params)

    p JSON.parse(response.body)

    JSON.parse(response.body)['openid']
  end

  def user_params(code)

    # return @user_params if @user_params

    @user_params = {}
    email = wechat_email(code)
    # GET both openid and session_key
    @user_params['email'] = email
    @user_params['password'] = 'impenetetrablepasswordpassword'
    @user_params['open_id'] = email.split('@').first
    @user_params
  end

  # def set_params
  #   params.require(:user).permit(:email, :password_digest, :open_id)
  #   params.require(:user).permit(:email, :password, :password_confirmation)
  # end

  

  
end