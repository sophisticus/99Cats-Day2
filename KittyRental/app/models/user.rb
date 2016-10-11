class User < ActiveRecord::Base
  validates :username, :session_token, presence: true, uniqueness: true
  validates :password_digest, presence: { message: "Password can't be blank" }
  validates :password, length: { minimum: 6, allow_nil: true }

  attr_reader :password


  def self.reset_session_token!
    self.session_token = User.generate_session_token
    self.save!
    self.session_token
  end

  def password=(password)
    @password = password
    self.password_digest = BCrypt::Password.create(password)
  end

  def is_password?(password)
    BCrypt::Password.new(self.password_digest).is_password?(password)
  end


  def find_by_credentials(username, password)
    user = User.find_by(username: username)
    return user if user && user.is_password?(password) ? user : nil
  end

  private

  def ensure_session_token
    self.session_token ||= SecureRandom::urlsafe_base64(16)
  end
end
