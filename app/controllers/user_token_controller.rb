class UserTokenController < Knock::AuthTokenController
  skip_before_action :verify_authenticity_token, raise: false

  # def user_token_params
  #   params.require(:user_token).permit(:id)
  # end
end
