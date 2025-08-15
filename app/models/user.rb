class User < ApplicationRecord
    attr_accessor :raw_remember_token
    
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
        format: { with: VALID_EMAIL_REGEX }
    validates :email, uniqueness: true
    before_save { self.email = email.downcase }
    has_secure_password
    validates :password, length: { minimum: 6 }, allow_nil: true

    def User.new_token
        SecureRandom.urlsafe_base64
    end

    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    def remember
        raw_token = User.new_token
        self.raw_remember_token = raw_token
        update_attribute(:remember_token, User.digest(raw_token))
        remember_token
    end
    
    def session_token
        remember_token || remember
    end
    
    def authenticated?(remember_token)
        return false if remember_token.nil?
        return false if self.remember_token.nil?
        BCrypt::Password.new(self.remember_token).is_password?(remember_token)
    rescue BCrypt::Errors::InvalidHash
        false
    end

    def forget
        update_attribute(:remember_token, nil)
        self.raw_remember_token = nil
    end

    def admin?
        admin
    end
end
