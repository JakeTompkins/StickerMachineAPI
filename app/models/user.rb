class User < ApplicationRecord
  has_secure_password
  has_many :stickers
  validates :email, uniqueness: true

  def to_token_payload
    {
      email: email,
      password: password
    }
  end


  def self.from_token_request(payload)
    email = payload.params["auth"]["email"]
    self.find_by email: email
  end

  # def self.from_token_request(request)
  #   email = request.params["auth"]["email"]
  #   password = request.params["auth"]["password"]
  #   self.find_by email: email
  # end
end
