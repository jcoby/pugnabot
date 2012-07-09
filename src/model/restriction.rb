require_relative '../database'

require_relative 'user'

class Restriction < ActiveRecord::Base
  belongs_to :user
  
  validates :user, :presence => true
end
