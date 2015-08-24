require 'active_record'
# Client ActiveRecord model
class Client < ActiveRecord::Base
  has_many :tasks

  validates_uniqueness_of :ip
end