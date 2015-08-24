require 'active_record'
# Task ActiveRecord model
class Task < ActiveRecord::Base
  belongs_to :client

  scope :incompleted, -> { where completed: false }
end