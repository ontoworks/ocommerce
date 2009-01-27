class AdminUsersController < ApplicationController
  layout "admin"

  before_filter :admin_only

  def index
  end
end
