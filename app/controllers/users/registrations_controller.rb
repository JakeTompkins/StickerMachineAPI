# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # before_action :configure_sign_up_params, only: [:create]
  # before_action :configure_account_update_params, only: [:update]
  
  respond_to :json 
  acts_as_token_authentication_handler_for User, except: [ :show, :index, :create ]
  

  before_action :set_user, only: [ :show ]

  after_action :verify_authorized, except: [:index, :create]
  # skip_before_action :verify_authenticity_token, :only => :create

  def create
    code = params[:code]
    @user = User.find_by_email(wechat_email(code).downcase) || User.create!(user_params(code))
    render json: @user
  end

  def open_id(code)
    @open_id ||= fetch_open_id(code)
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

  def set_user
    @user = User.find(params[:id])
  end

  def wechat_email(code)
    @email ||= open_id(code) + "@stickermachine.cool"
  end

  def user_params(code)
    return @user_params if @user_params
    @user_params = set_params
    # GET both openid and session_key
    @user_params['email'] = wechat_email(code)
    @user_params['password'] = 'secret123'
    @user_params['open_id'] = open_id(code)
    @user_params['encrypted_password'] = Devise.friendly_token
    @user_params['authentication_token'] = Devise.friendly_token
    @user_params
  end

  def set_params
    # update later with user model
    params.permit(:nickname)
  end


  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_up_params
  #   devise_parameter_sanitizer.permit(:sign_up, keys: [:attribute])
  # end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end
end
