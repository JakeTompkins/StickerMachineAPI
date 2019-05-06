class User < ApplicationRecord
  has_secure_password
  has_many :stickers
  validates :email, uniqueness: true



  ######### worked in previous version
  # def to_token_payload
  #   {
  #     email: email,
  #     password: password
  #   }
  # end


  def self.from_token_request(payload)
    email = payload.params["auth"]["email"].downcase
    self.find_by email: email
  end
end
