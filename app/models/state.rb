class State < ActiveRecord::Base

  def before_create
    if @attributes["tax"] > 1
      @attributes["tax"] /= 100
    end
  end
end
