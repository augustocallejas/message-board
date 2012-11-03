
require 'digest/sha1'

class Invite < ActiveRecord::Base

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :user

  #
  # VALIDATION METHODS
  #

  before_update :generate_key

  def generate_key
    if self.email
      gen_key()
    end
  end

  #
  # PUBLIC METHODS
  #

  def self.find_unaccepted_invite(key)
    return Invite.find(:first, :conditions=>['invitekey = ? and accepted != 1',
                                             key])
  end

  def unissue()
    self.email = nil
    self.invitekey = nil
  end

  #
  # PRIVATE METHODS
  #

  def gen_key()
    self.invitekey = Digest::SHA1.hexdigest("--#{self.id}--#{self.email}--")
  end

end
