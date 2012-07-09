require_relative '../database'

require_relative 'user'

class Restrictcaptain < ActiveRecord::Base
  belongs_to :user

  validates :user, :presence => true
end
