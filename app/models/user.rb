
require 'digest/sha1'

class User < ActiveRecord::Base

  #
  # CONSTANT
  #

  RECENT_ACTIVITY_MIN = 10

  #
  # MODEL RELATIONSHIPS
  #

  has_many :topics,
           :order=>'last_post_time DESC'
  has_many :posts,
           :order=>'created_at DESC'
  has_one  :last_post,
           :class_name=>"Post",
           :order=>'created_at DESC'
  has_many :invites
  has_many :unissued_invites,
           :class_name=>'Invite',
           :conditions=>'invitekey is null'
  has_many :issued_invites,
           :class_name=>'Invite',
           :conditions=>'invitekey is not null and accepted != 1'
  has_one  :activity
  belongs_to :invited_by,
             :class_name=>'User',
             :foreign_key=>'invited_by_id'
  has_many :invited,
           :class_name=>'User',
           :foreign_key=>'invited_by_id'
  has_many :shares,
           :order=>'created_at DESC'

  #
  # VALIDATION METHODS
  #

  attr_protected :email

  validates_format_of :photourl,
                      :with=>%r{^http(s?):.+$|^$}i
  validates_format_of :url,
                      :with=>%r{^http(s?):.+$|^$}i

  validates_uniqueness_of :username,
                          :case_insensitive=>true,
                          :on=>:create,
                          :message=>'username is already taken.'
  validates_format_of :username,
                      :with=>%r{^[a-z0-9_\-. ]+$}i,
                      :on=>:create,
                      :message=>'username is invalid.'

  #
  # PUBLIC METHODS
  #

  def photourl=(value)
    write_attribute("photourl", value.strip) if not value.nil?
  end

  def url=(value)
    write_attribute("url", value.strip) if not value.nil?
  end

  def im_username=(value)
    write_attribute("im_username", value.strip) if not value.nil?
  end

  def location=(value)
    write_attribute("location", value.strip) if not value.nil?
  end

  def is_password(password)
    return User.find(:first, :conditions=>['password = ?', 
                                           User.encrypt(password)]) != nil
  end

  def change_password(password)
    update_attribute "password", User.encrypt(password)
  end

  def get_unread_message_count()
    return Message.count(
      :conditions=>["recipient_id = ? and recipient_delete != 1 and recipient_viewed != 1", 
       id])
  end

  def get_first_unread_message()
    return Message.find(:first,
      :conditions=>["recipient_id = ? and recipient_delete != 1 and recipient_viewed != 1",
       id])
  end


  #
  # CLASS METHODS
  #
  
  def self.generate_password()
    chars = ("a".."z").to_a + ("1".."9").to_a
    pass = ""
    1.upto(10) { |i| pass << chars[rand(chars.size-1)] }
    return pass
  end

  def self.authenticate(username, password)
    return find(:first, 
                :conditions=>['username = ? and password = ? and disabled = 0',
                              username, User.encrypt(password)])
  end

  def self.encrypt(text)
    return Digest::SHA1.hexdigest("--#{text}--")
  end

  def self.find_recent()
    return find(:all,
                :conditions=>['activities.updated_at>?', 
                              RECENT_ACTIVITY_MIN.minutes.ago],
                :include=>:activity,
                :order=>'username')
  end

  def self.find_recent_count()
    return count(:all,
                 :conditions=>['activities.updated_at>?', 
                               RECENT_ACTIVITY_MIN.minutes.ago],
                 :include=>:activity)
  end

  def self.get_with_no_invites()
    return User.find_by_sql("select u.* from users as u left join invites" +
                            " as i on u.id=i.user_id where i.user_id is null")
  end

  def self.get_with_all_accepted_invites()
    users = []
    rs = User.connection.execute("select u.id, count(*) as count," +
                                 " sum(accepted) as sum from users as u" + 
                                 " left join invites as i" +
                                 " on u.id=i.user_id group by u.id")

    rs.each do |row|
      if not row.nil? and not row[1].nil? and not row[2].nil?
        if row[1] == row[2]
          users << User.find(row[1])
        end
      end
    end
    return users
  end


  #
  # PRIVATE METHODS
  #

end
