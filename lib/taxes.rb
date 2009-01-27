# === Usage
# This modules handles all the state's taxes calculations. Nothing too
# fancy. Currently, it requires a "States" table in the database with the following fields:
# * full_name - string - State's full name (e.g. Texas)
# * short_name - string - State's abbreviation (e.g. TX)
# * tax - float - Tax to apply to this state (e.g. 0.0825 => 8.25%)
#
# To create the taxes for a state, just create a state and call
# #create_state_tax:
#     s = State.new (:full_name => "Texas", :short_name => "TX", :tax => 0.0825)
#     create_state_tax(s)
# 
# === Authors
# * Federico Builes  (mailto:federico.builes@gmail.com)
#

# Returns the taxes for a state.
#    s = State.new (:full_name => "Texas", :short_name => "TX", :tax => 0.0825)
#    p state_tax(s) => 0.0825
def state_tax(state)
  s = State.find_by_short_name(state.upcase)
  s.nil? ? 0.00 : s.tax
end

# Creates the taxes for a state or updates them if they already exist.
#     s = State.new (:full_name => "Texas", :short_name => "TX", :tax => 0.0825)
#     p state_tax(s) => 0.0825
#     s.tax = 0.05 
#     create_state_tax(s)
#     p state_tax(s) => 0.05
def create_state_tax(state)
  s = State.find_by_short_name(state[:short_name].upcase)
  if s.nil? 
    State.create(state) 
  else
    State.delete(s)
    State.create(state)
  end
end
