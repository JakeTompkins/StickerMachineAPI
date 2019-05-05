class User < ApplicationRecord
  has_secure_password
  has_many :stickers
  validates :email, uniqueness: true

  def to_token_payload
    {
      email: email
    }
  end


  # def self.from_token_payload(payload)

  #   email = payload.params["auth"]["email"]
  #   User.find_by_email(email)
  #   # self.find_by email: email
  # end

  def self.from_token_request(request)
    puts "whatt is this doing"
    email = request.params["auth"] && request.params["auth"]["email"]
    # password = request.params["auth"]["password"]
    self.find_by email: email
  end
end
