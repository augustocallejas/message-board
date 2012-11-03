
class Topic < ActiveRecord::Base

  @@max_title_length = 100

  before_save :truncate_title

  def truncate_title
    self.title = self.title.slice(0,@@max_title_length)
  end

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :user, :counter_cache=>true
  has_many   :posts,
             :order=>'created_at'

  #
  # VALIDATION METHODS
  #

  validates_presence_of :title

  #
  # PUBLIC METHODS
  #

  def self.max_title_length
    return @@max_title_length
  end

end
