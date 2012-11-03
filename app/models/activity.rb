
class Activity < ActiveRecord::Base

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :user

  #
  # VALIDATION METHODS
  #

  #
  # PUBLIC METHODS
  #

  def self.delete_recent()
    destroy_all(['updated_at < ?', 
                 User::RECENT_ACTIVITY_MIN.minutes.ago])
  end

  #
  # PRIVATE METHODS
  #

end
