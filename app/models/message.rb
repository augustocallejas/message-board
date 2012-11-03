
class Message < ActiveRecord::Base

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :sender,
             :class_name=>'User',
             :foreign_key=>'sender_id'
  belongs_to :recipient,
             :class_name=>'User',
             :foreign_key=>'recipient_id'
  belongs_to :reply_to,
             :class_name=>'Message',
             :foreign_key=>'reply_to_id'

  #
  # VALIDATION METHODS
  #
  
  attr_protected :sender_id
  attr_protected :recipient_id
  attr_protected :sender_delete
  attr_protected :recipient_delete
  attr_protected :recipient_viewed

  validates_length_of :subject, 
                      :minimum=>1,
                      :on=>:create,
                      :message=>'subject cannot be empty.'
  validates_length_of :subject, 
                      :maximum=>100,
                      :on=>:create,
                      :message=>'subject is too long.'

  validates_presence_of :content,
                        :on=>:create,
                        :message=>'body cannot be empty.'

  #
  # PUBLIC METHODS
  #

  def subject=(subj)
    self[:subject] = subj.strip if not subj.nil?
  end

end
