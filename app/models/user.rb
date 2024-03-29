class User < ActiveRecord::Base
  attr_accessor :domain
  attr_accessor :remember_token

  after_initialize :init_values, unless: :persisted?
  before_save :default_values, unless: :persisted?
  before_validation :modify_values, unless: :persisted?

  belongs_to :institution
  has_many :bookings, dependent: :destroy

  VALID_EMAIL_REGEX = /\A((“|”|\+|\-|\w)+\.?)+\z/i
  VALID_DOMAIN_REGEX = /\A\w+(\.|-)(\w+(\.|-))*\w+\z/i

  validates :email, {
      length: { maximum: 255 },
      format: { with: VALID_EMAIL_REGEX },
      unless: :persisted?
  }

  validate :email_uniqueness, unless: :persisted?
  validate :domain_validation, unless: :persisted?

  has_secure_password
  validates :password, {
    length: { minimum: 6, maximum: 255 },
    allow_blank: true
  }

  validates_inclusion_of :is_verified, in: [true, false]

  def verified?
    self.is_verified
  end

  def new_reset_token
    self.new_unique_token(:reset_token)
    self.reset_expire = 1.hours.from_now
    self.save
  end

  def nil_reset_token
    self.reset_token = nil
    self.reset_expire = nil
    self.save
  end

  def new_unique_token(column)
    begin
      self[column] = SecureRandom.urlsafe_base64
    end while User.exists?(column => self[column])
  end

  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  def remember
    self.remember_token = SecureRandom.urlsafe_base64
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  def forget
    update_attribute(:remember_digest, nil)
  end

  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  private

  def email_uniqueness
    if User.exists?(email: "#{self.email.downcase}@#{self.domain.downcase}")
      errors.add(:email, 'email address is already in use')
    end
  end

  def domain_validation
    unless domain =~ VALID_DOMAIN_REGEX
      errors.add(:email, 'domain is invalid')
      return
    end

    unless Institution.exists?(domain: domain)
      errors.add(:email, "domain '#{domain}' does not belong to any registered institution")
    end
  end

  def init_values
    self.is_verified = false
    self.new_unique_token(:activation_token)
  end

  def modify_values
    self.email = self.email.downcase
    self.domain = self.domain.downcase
  end

  def default_values
    self.email += "@#{self.domain.downcase}"
    self.email = self.email.downcase
  end
end
