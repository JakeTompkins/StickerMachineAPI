class ApplicationController < ActionController::API
  include Knock::Authenticable
  
  def render_data(data, status=200)
    render json: {status: status, data: data}
  end

  def render_error message
    render json: {error: message}
  end
end
