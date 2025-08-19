class User < ApplicationRecord
    attr_accessor :raw_remember_token, :activation_token, :reset_token
    has_many :microposts, dependent: :destroy
    has_many :active_relationships, class_name: "Relationship",
        foreign_key: "follower_id",
        dependent: :destroy
    has_many :passive_relationships, class_name: "Relationship",
        foreign_key: "followed_id",
        dependent: :destroy
    has_many :following, through: :active_relationships, source: :followed
    has_many :followers, through: :passive_relationships, source: :follower
    
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
        format: { with: VALID_EMAIL_REGEX }
    validates :email, uniqueness: true
    before_save { self.email = email.downcase }
    before_create :create_activation_digest
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
    
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")
        return false if digest.nil?
        BCrypt::Password.new(digest).is_password?(token)
    rescue BCrypt::Errors::InvalidHash
        false
    end

    def forget
        update_attribute(:remember_token, nil)
        self.raw_remember_token = nil
    end

    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    def admin?
        admin
    end

    def activated?
        activated
    end

    def create_reset_digest
        self.reset_token = User.new_token
        update_attribute(:reset_digest, User.digest(reset_token))
        update_attribute(:reset_sent_at, Time.zone.now)
    end

    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    def password_reset_expired?
        reset_sent_at < 2.hours.ago
    end

    def activate
        update_attribute(:activated, true)
        update_attribute(:activated_at, Time.zone.now)
    end

    def feed
        following_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
        Micropost.where("user_id IN (#{following_ids}) OR user_id = :user_id", user_id: id)
    end

    def follow(other_user)
        following << other_user unless self == other_user
    end

    def unfollow(other_user)
        following.delete(other_user)
    end

    def following?(other_user)
        following.include?(other_user)
    end

    private

        def create_activation_digest
            self.activation_token = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
