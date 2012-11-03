
class Post < ActiveRecord::Base

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :user, :counter_cache=>true
  belongs_to :topic

  #
  # VALIDATION METHODS
  #

  validates_presence_of :content

  #
  # PUBLIC METHODS
  #

end
