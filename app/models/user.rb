class User < ActiveRecord::Base
	
	attr_accessor :remember_token, :activation_token
	before_create :create_activation_digest
	before_save   :downcase_email


	has_many :microposts, dependent: :destroy
	has_secure_password

	validates :name, 
          :presence => {:message => "can't be blank" },
          :length => { :maximum => 20, :message => "should less then 20 words"}

	validates :email, 
          :presence => {:message => "format is invalid" }


  # Returns true if the given token matches the digest.
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end


  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end


  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

    # Returns a random token.
  def User.new_token
    SecureRandom.urlsafe_base64
  end


  # Activates an account.
  def activate
    update_attribute(:activated,    true)
    update_attribute(:activated_at, Time.zone.now)
  end

  # Sends activation email.
  def send_activation_email
    UserMailer.account_activation(self).deliver
  end


 private

    # Converts email to all lower-case.
    def downcase_email
      self.email = email.downcase
    end


    # Creates and assigns the activation token and digest.
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end


end
