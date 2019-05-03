class UsersController < ApplicationController
  respond_to :json 
  # skip_before_action :authenticate_user!, raise: false
  # skip_before_action :require_login, raise: false
  

  acts_as_token_authentication_handler_for User, except: [ :show, :index, :create ]

  before_action :set_user, only: [ :show ]

  after_action :verify_authorized, except: [:index, :create]
  # skip_before_action :verify_authenticity_token, :only => :create
  

  def create
    code = params[:code]
    @user = User.find_by_open_id(open_id(code).downcase) || User.create!(user_params(code))
    render json: @user
  end

  def open_id(code)
    @open_id ||= fetch_open_id(code)
  end

  def fetch_open_id(code)
    url = "https://api.weixin.qq.com/sns/jscode2session"
    wechat_params = {
      appid: ENV.fetch('APP_ID'),
      secret: ENV.fetch('APP_SECRET'),
      js_code: code,
      grant_type: 'authorization_code' }
    response = RestClient.post(url, wechat_params)

    p JSON.parse(response.body)

    JSON.parse(response.body)['openid']
  end

  def set_user
    @user = User.find(params[:id])
  end

  def user_params(code)
    return @user_params if @user_params

    @user_params
    # GET both openid and session_key
    @user_params['open_id'] = open_id(code)
    @user_params['encrypted_password'] = Devise.friendly_token
    @user_params['authentication_token'] = Devise.friendly_token
    @user_params
  end


end