class AdminController < ApplicationController
  before_filter :admin_only, :only => :index

  def index
  end

  def login
  end
end
