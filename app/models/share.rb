
class Share < ActiveRecord::Base

  #
  # MODEL RELATIONSHIPS
  #

  belongs_to :user

  #
  # VALIDATION METHODS
  #

  attr_protected :expired

  validates_presence_of :author,
                        :on=>:create
  validates_presence_of :title,
                        :on=>:create
  validates_format_of :url,
                      :with=>%r{^http(s?):.+$}i,
                      :on=>:create

  #
  # PUBLIC METHODS
  #

  def author=(value)
    write_attribute("author", value.strip) if not value.nil?
  end

  def title=(value)
    write_attribute("title", value.strip) if not value.nil?
  end

  def url=(value)
    write_attribute("url", value.strip) if not value.nil?
  end


  #
  # PRIVATE METHODS
  #


end
