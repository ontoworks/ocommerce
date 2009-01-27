require 'digest/sha1'
require 'digest/md5'
class User < ActiveRecord::Base
  has_many :orders
  has_one :cart
  # Virtual attribute for the unencrypted password
#  attr_accessor :password

  validates_presence_of     :email, :firstname, :lastname
  validates_presence_of     :crypted_password,                   :if => :password_required?
#  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :crypted_password, :within => 4..40, :if => :password_required?
#  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :email,    :within => 3..100
  validates_uniqueness_of   :email, :case_sensitive => false
  before_save :encrypt_password

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :email, :password_confirmation,
  :firstname, :lastname, :company, :street_address, :zip_code, :city, :state,
  :country, :telephone, :crypted_password

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(email, pwd)
    u = find_by_email(email) # need to get the salt
    u && u.authenticated?(pwd) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(pwd, salt)
    Digest::MD5.hexdigest("#{salt}#{pwd}") + ":" + salt
  end

  # Encrypts the password with the user salt.
  def encrypt(pwd)
    s = old_salt
    self.class.encrypt(pwd, s)
  end

  def authenticated?(pwd)
    password == encrypt(pwd)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def self.find_by_like(query, search_by, order_by, sort, limit)
    User.find(:all,
      :conditions => [ 'LOWER('+search_by+') LIKE ?',
      '%' + query.downcase + '%' ],
      :order => order_by+' '+sort,
      :limit => limit)
  end

  def self.count_by_like(query, search_by)
    User.count(:all,
      :conditions => [ 'LOWER('+search_by+') LIKE ?',
      '%' + query.downcase + '%' ])
  end

  def password_key
    #password[0,32]
    password.split(":")[0]
  end

  protected
    # before filter
    # Please don't be fooled, crypted password's not totally crypted, the password to check
    # agaisnt is "password". Made this way for backwards compatibility
    def encrypt_password
      s =  (rand(58) + 65).chr + (rand(58) + 65).chr
      u = User.find_by_email(self.email)
#      if u.nil?
      if  !crypted_password.nil? && !crypted_password.empty?
        self.salt = s
        self.password = encrypt(crypted_password)
        self.crypted_password = ""
      else
        return
      end
    end

    def old_salt
      self.salt.empty? ? self.password[-2..-1] : self.salt
    end

    def password_required?
      !password.blank?
    end

end
