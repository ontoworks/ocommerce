require 'digest/md5'

class LoginController < ApplicationController
  def index
    @md5 = Digest::MD5.hexdigest("7epapa12")
  end

  def login
    @user = User.find(:first, :conditions => ['email LIKE ?', params[:user][:email]])
    if !(@user.nil?)
      @passwd_and_salt = @user.password.split(':')
      if Digest::MD5.hexdigest(@passwd_and_salt[1]+params[:user][:password]) != @passwd_and_salt[0]
        redirect_to :action => 'index'
      end
    else
      redirect_to :action => 'index'
    end
  end
end
