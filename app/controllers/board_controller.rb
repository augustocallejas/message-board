
require 'SearchEngine'

class BoardController < ApplicationController

  #session :off, :only=>['login',
  #                      'open_invite',
  #                      'request_password_reset',
  #                      'reset_password']

  #
  # FILTER METHODS
  #

  before_filter :authorize, :except=>['index',
                                      'authenticate',
                                      'login',
                                      'logout',
                                      'open_invite',
                                      'create_account',
                                      'request_password_reset',
                                      'reset_password']

  before_filter :update_activity, :except=>['index',
                                            'authenticate',
                                            'login',
                                            'logout',
                                            'open_invite',
                                            'create_account',
                                            'request_password_reset',
                                            'reset_password']

  #
  # LAYOUT METHODS
  #

  layout 'authenticated', :except=>['login','open_invite','create_account',
                                    'request_password_reset']


  #
  # AUTHENTICATION METHODS
  #
  
  def authenticate
    if params[:user].nil?
      reset_session
      redirect_to :action=>'login', :message=>'bad username/password.', :status=>:found
      return
    end

    user = User.authenticate(params[:user][:username],
                             params[:user][:password])
    
    if user
      session[:user_id] = user.id
      session[:user_name] = user.username
      #logger.info 'found user, redirecting'
      redirect_to :action=>'list_topics', :status=>:found
    else
      reset_session
      redirect_to :action=>'login', :message=>'bad username/password.', :status=>:found
    end
  end

  def logout
    reset_session
    redirect_to :action=>'login', :status=>:found
  end

  def update_password
    user = get_user()
    # TODO: check that params[:password] is not nil
    curr = params[:password][:current].strip
    pass1 = params[:password][:new].strip
    pass2 = params[:password][:confirmation].strip
    @errors = []

    if curr.length == 0
      @errors << "missing current password."
      render :action=>'change_password'
      return
    elsif not user.is_password(curr)
      @errors << "incorrect current password."
      render :action=>'change_password'
      return
    elsif pass1.length == 0
      @errors << "no new password provided."
      render :action=>'change_password'
      return
    elsif not (pass1 == pass2)
      @errors << "confirmation password doesn not match."
      render :action=>'change_password'
      return
    else
      user.change_password(pass1)
      flash[:notice] = "password changed."
      redirect_to :action=>'change_password', :status=>:found
    end
  end
  
  def reset_password
    username = params[:username]
    secret_word = params[:secret_word]

    if not username.nil?
      username = username.strip
    end

    if not secret_word.nil?
      secret_word = secret_word.strip.downcase
    end

    if username.nil? or username.length < 1
      redirect_to :action=>'request_password_reset', 
                  :message=>'please provide a username.',
                  :status=>:found
      return
    end

    if secret_word.nil?
      redirect_to :action=>'request_password_reset',
                  :message=>'please provide a favorite color.',
                  :status=>:found
      return
    end

    user = User.find_by_username_and_secret_word(username, secret_word)

    if user.nil?
      redirect_to :action=>'request_password_reset',
                  :message=>'invalid username/color combination.',
                  :status=>:found
      return
    end

    pass = User.generate_password()
    user.change_password(pass)

    BoardMailer.deliver_reset_password(user.email, pass)

    redirect_to :action=>'login', 
                :message=>'your password has been reset.  please check your email.',
                :status=>:found
  end

  def default_url_options(options)
    {:skip_relative_url_root => true }
  end

  #
  # DISPLAY METHODS
  #

  def index
    redirect_to :action=>'list_topics'
  end

  def default_url_options
    {}
  end

  def list_topics
    @topics = Topic.paginate :page=>params[:p],
                             :order =>'last_post_time desc',
                             :per_page=>30
  end

  def show_topic
    @topic = Topic.find(params[:id])
    @post = Post.new
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'invalid thread'
    redirect_to :action=>'list_topics', :status=>:found
  end

  def view_profile
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound => e
    flash[:notice] = 'invalid user'
    redirect_to :action=>'list_topics', :status=>:found
  end

  def list_user_topics
    @user = User.find(params[:id])
    @topics = Topic.paginate :page=>params[:p],
                             :per_page=>25,
                             :conditions=>['user_id = :id', params],
                             :order=>'last_post_time DESC'
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'invalid user'
    redirect_to :action=>'list_topics', :status=>:found
  end

  def list_user_posts
    @user = User.find(params[:id])
    @posts = Post.paginate :page=>params[:p],
                           :per_page=>25,
                           :conditions=>['user_id = :id', params],
                           :order=>'created_at DESC'
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'invalid user'
    redirect_to :action=>'list_topics', :status=>:found
  end

  def add_topic
    @errors = []
  end


  #
  # CREATE METHODS
  #

  def create_topic
    user = get_user()
    topic = Topic.new(params[:topic])
    post = Post.new(params[:post])
    post.user = user

    if !topic.valid? or !post.valid?
      @topic = topic
      @post = post

      @errors = []
#      @errors << "subject cannot be empty." if @topic.errors.invalid?(:title)
      @errors << "subject cannot be empty." if @topic.errors[:title].any?

      @topic.errors.clear

#      @errors << "body cannot be empty." if @post.errors.invalid?(:content)
      @errors << "body cannot be empty." if @post.errors[:content].any?

      @post.errors.clear

      render :action=>'add_topic'
      return
    end

    topic.user = user
    topic.posts << post
    topic.last_post_username = post.user.username
    topic.last_post_userid = post.user.id
    topic.last_post_time = Time.now
    topic.save!

    SearchEngine.insert_topic(topic.id, topic.title)
    SearchEngine.insert_post(post.id, post.content)

    redirect_to :action=>'list_topics', :status=>:found
  end

  def create_post
    user = get_user()
    topic = Topic.find(params[:id])
    post = Post.new(params[:post])
    post.user = user

    if !post.valid?
      @topic = Topic.find(params[:id])
      @user = user
      @post = post

      @errors = []
      @errors << "reply cannot be empty." if @post.errors.invalid?(:content)
      @post.errors.clear

      render :action=>'show_topic'
    else
      topic.posts << post
      topic.last_post_time = post.created_at
      topic.last_post_username = post.user.username
      topic.last_post_userid = post.user.id
      topic.save!

      SearchEngine.insert_post(post.id, post.content)

      redirect_to :action=>'list_topics', :status=>:found
    end
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'invalid thread'
    redirect_to :action=>'list_topics', :status=>:found
  end


  #
  # PROFILE METHODS
  #

  def edit_profile
    @user = get_user()
    @errors = []
    @protos = Improtocol.find_all
  end

  def update_profile
    @user = get_user()
    @user.update_attributes(params[:user])
    @protos = Improtocol.find_all

    if !@user.save
      @errors = []
      @errors << "photo is an invalid URL." if @user.errors.invalid?(:photourl)
      @errors << "homepage is an invalid URL." if @user.errors.invalid?(:url)
      @user.errors.clear
      @user.reload

      render :action=>'edit_profile'
      return
    end

    redirect_to :action=>'view_profile', :id=>@user, :status=>:found
  end

  #
  # INVITE METHODS
  #

  def list_invites
    @issued = get_user().issued_invites
    @unissued = get_user().unissued_invites
  end

  def send_invite
    email = params[:email].strip.downcase
    if check_email(email)
      if get_user().unissued_invites.size > 0
        invite = get_user().unissued_invites[0]
        invite.email = email
        invite.save!

        BoardMailer.deliver_invite(get_user().username,
                                   invite.email,
                                   invite.invitekey)

        flash[:notice] = 'invite sent.'
        redirect_to :action=>'list_invites', :status=>:found
        return
      else
        @issued = get_user().issued_invites
        @unissued = get_user().unissued_invites
        @errors = []
        @errors << 'no more invites.'
        render :action=>'list_invites'
        return
      end
    else
      @issued = get_user().issued_invites
      @unissued = get_user().unissued_invites
      @errors = []
      @errors << 'invalid email address.'
      render :action=>'list_invites'
    end
  end

  def uninvite
    invite = get_user().issued_invites.find(params[:id])
    invite.unissue()
    invite.save!

    flash[:notice] = 'uninvited.'
    redirect_to :action=>'list_invites', :status=>:found
  rescue ActiveRecord::RecordNotFound
    flash[:notice] = 'invalid invite'
    redirect_to :action=>'list_topics', :status=>:found
  end

  def open_invite
    @invite = Invite.find_unaccepted_invite(params[:id])
  end

  def create_account
    invitekey = params[:invite]
    username  = params[:username]
    pass1     = params[:password]
    pass2     = params[:password_confirm]
    secret_word = params[:secret_word]
    @errors   = []

    @invite = Invite.find_unaccepted_invite(invitekey)

    # TODO: display better error message
    if @invite.nil?
      return
    end

    if not username.nil?
      username = username.strip
    end

    if username.nil? or username.length < 1
      @errors << 'please provide a username.'
      render :action=>'open_invite'
      return
    end

    if pass1.nil? or pass1.length < 1
      @errors << 'please provide a password.'
      render :action=>'open_invite'
      return
    end

    if pass1.nil? or pass2.nil? or not (pass1 == pass2)
      @errors << 'passwords do not match.'
      render :action=>'open_invite'
      return
    end

    if not secret_word.nil?
      secret_word = secret_word.strip.downcase
    end

    if secret_word.nil? or secret_word.length < 1
      @errors << 'please provide a favorite color.'
      render :action=>'open_invite'
      return
    end

    user = User.new
    user.username = username
    user.password = User.encrypt(pass1)
    user.email = @invite.email
    user.invited_by = @invite.user
    user.secret_word = secret_word

    if not user.save
      @errors = []
      @errors = user.errors[:username] if user.errors.invalid?(:username)
      user.errors.clear

      render :action=>'open_invite'
      return
    end

    @invite.accepted = true
    @invite.save!

    redirect_to :action=>'login', :message=>'account created.', :status=>:found
  end


  #
  # SEARCH ACTIONS
  #

  def search
    @options = [['post replies','post'],['thread subjects','topic']]
  end

  def perform_search
    if params[:q].nil? or params[:q].strip.length == 0
      flash[:notice] = 'nothing to search.'
      redirect_to :action=>'search', :status=>:found
      return
    end 

    terms = params[:q].downcase().split()

    if params[:type] == 'topic'
      @topics = Topic.find(SearchEngine.search_topics(terms),
                           :order=>'id DESC')

      #@topic_pages, @topics = paginate(:topics,
      #                                 :per_page=>25,
      #                                 :conditions=>["MATCH(title) AGAINST(:q)",
      #                                               params],
      #                                 :order=>'last_post_time DESC')
      render :action=>'list_search_topics'
      return
    else
      @posts = Post.find(SearchEngine.search_posts(terms),
                         :order=>'id DESC')
      #@post_pages, @posts = paginate(:posts,
      #                               :per_page=>25,
      #                               :conditions=>["MATCH(content) AGAINST(:q)",
      #                                             params],
      #                               :order=>'created_at DESC')
      render :action=>'list_search_posts'
      return
    end
  end


  #
  # MESSAGE ACTIONS
  #
  
  def view_inbox
    if get_user().get_unread_message_count() == 1
      id = get_user().get_first_unread_message()
      redirect_to :action=>'view_received_message', :id=>id, :status=>:found
    else
      @messages = Message.paginate :page=>params[:p], :per_page=>25,
                 :conditions=>['recipient_id = ? and not recipient_delete',
                               get_user().id],
                 :order=>'id DESC'
    end
  end

  def view_outbox
    @messages =
      Message.paginate :page=>params[:p],
                       :per_page=>25,
                       :conditions=>['sender_id = ? and not sender_delete',
                                      get_user().id],
                       :order=>'id DESC'
  end

  def view_received_message
    @message = Message.find(:first, 
                            :conditions=>['recipient_id = ? and id = ?',
                                          get_user().id, params[:id]])
    if @message.nil?
      flash[:notice] = 'invalid message.'
      redirect_to :action=>'view_inbox', :status=>:found
      return
    end

    if not @message.recipient_viewed
      @message.recipient_viewed = true
      @message.save!
    end
  end

  def view_sent_message
    @message = Message.find(:first, 
                            :conditions=>['sender_id = ? and id = ?',
                                          get_user().id, params[:id]])
    if @message.nil?
      flash[:notice] = 'invalid message.'
      redirect_to :action=>'view_outbox', :status=>:found
      return
    end
  end

  def compose_message
    @message = Message.new
     
    if not params[:reply_to].nil?
      @reply_to = Message.find(:first, 
                               :conditions=>['id = ? and recipient_id = ?',
                                             params[:reply_to], get_user().id])
    else
      @reply_to = nil
    end

    if not @reply_to.nil?
      if @reply_to.subject.index("re: ") == 0
        @message.subject = @reply_to.subject
      else
        @message.subject = "re: " + @reply_to.subject
      end
    end

    if not params[:id].nil?
      @recipient = User.find(params[:id])

      if @recipient.nil?
        flash[:notice] = 'invalid user.'
        redirect_to :action=>'list_topics', :status=>:found
        return
      end

      if @recipient.id == get_user().id
        flash[:notice] = "you can't send a message to yourself!"
        redirect_to :action=>'list_topics', :status=>:found
        return
      end
    else
      @recipient = nil
    end
  end

  def send_message

    if not params[:reply_to].nil?
      @reply_to = Message.find(:first, 
                               :conditions=>['id = ? and recipient_id = ?',
                                             params[:reply_to], get_user().id])
    else
      @reply_to = nil
    end

    if not params[:id].nil?
      @recipient = User.find(params[:id])
    elsif not params[:username].nil?
      @recipient = User.find(:first, 
                             :conditions=>['username = ?', 
                                           params[:username].strip])
    else
      @recipient = nil
    end

    if @recipient.nil?
      flash[:notice] = 'invalid user.'
      redirect_to :action=>'compose_message', :status=>:found
      return
    end

    if @recipient.id == get_user().id
      flash[:notice] = "you can't send a message to yourself!"
      redirect_to :action=>'compose_message', :status=>:found
      return
    end

    message = Message.new(params[:message])
    message.sender = get_user()
    message.recipient = @recipient
    message.reply_to = @reply_to

    if not message.save
      @errors = []
      @errors << message.errors[:subject] if message.errors.invalid?(:subject)
      @errors << message.errors[:content] if message.errors.invalid?(:content)

      render :action=>'compose_message'
      return
    end

    flash[:notice] = "message sent."
    redirect_to :action=>'view_inbox', :status=>:found
  end

  def delete_inbox_messages
    if params[:message].nil?
      flash[:notice] = "no messages selected."
      redirect_to :action=>'view_inbox', :status=>:found
      return
    end

    count = 0
    for id in params[:message].keys
      if params[:message][id] == "1"
        msg = Message.find(:first, :conditions=>["id = ? AND recipient_id = ?",
                                                 id,
                                                 get_user().id])
        if not msg.nil?
          msg.recipient_delete = true
          msg.save!
          count += 1
        end
      end
    end
    flash[:notice] = "deleted #{count} message(s)"
    redirect_to :action=>'view_inbox', :status=>:found
  end

  def delete_outbox_messages
    if params[:message].nil?
      flash[:notice] = "no messages selected."
      redirect_to :action=>'view_outbox', :status=>:found
      return
    end

    count = 0
    for id in params[:message].keys
      if params[:message][id] == "1"
        msg = Message.find(:first, :conditions=>["id = ? AND sender_id = ?",
                                                 id,
                                                 get_user().id])
        if not msg.nil?
          msg.sender_delete = true
          msg.save!
          count += 1
        end
      end
    end
    flash[:notice] = "deleted #{count} message(s)"
    redirect_to :action=>'view_outbox', :status=>:found
  end


  #
  # OPTIONS ACTIONS
  #

  def edit_options
    @user = get_user()
  end

  def update_options
    @user = get_user()
    secret_word = params[:user][:secret_word]
    @errors = []

    @user.disable_images = params[:user][:disable_images]
    @user.disable_unread_messages = params[:user][:disable_unread_messages]
    @user.save!

    if not secret_word.nil?
      secret_word = secret_word.strip.downcase
    end

    if secret_word.length == 0
      @errors << 'please provide a favorite color.'
      render :action=>'edit_options'
      return
    end

    @user.secret_word = secret_word.strip
    @user.save!

    flash[:notice] = 'options updated.'
    redirect_to :action=>'edit_options', :status=>:found
  end


  #
  # SHARE ACTIONS
  #

  def view_shares
    @shares = []
    if params[:id]
      @user = User.find(params[:id])
      @shares = Share.paginate :page=>params[:p],
                               :order=>'created_at desc',
                               :conditions=>['user_id = :id', params],
                               :per_page=>50
    else
      @user = nil
      @shares = Share.paginate :page=>params[:p],
                               :order=>'created_at desc, user_id',
                               :per_page=>50
    end
  end

  def add_share
  end

  def create_share
    user = get_user()
    share = Share.new(params[:share])
    share.user = user

    if !share.valid?
      @share = share

      # TODO: move error messages back into model
      @errors = []
      @errors << "author cannot be empty." if @share.errors.invalid?(:author)
      @errors << "title cannot be empty." if @share.errors.invalid?(:title)
      @errors << "url is an invalid URL." if @share.errors.invalid?(:url)
      @share.errors.clear

      render :action=>'add_share'
      return
    end

    share.save!

    flash[:notice] = "share added."
    redirect_to :action=>'view_shares', :status=>:found
  end


  #
  # MISCELLANEOUS ACTIONS
  #

  def show_active_users
    @active_users = User.find_recent()
  end

  def list_users
    @users = User.paginate :page=>params[:p],
                           :order=>'id',
                           :conditions=>'disabled = false',
                           :per_page=>50
  end

  def rescue_action_in_public(exception)
    case exception
      when  ::ActionController::UnknownAction
        render :file=>"#{RAILS_ROOT}/public/404.html",
               :status=>"404 Not Found"
      else
        render :file=>"#{RAILS_ROOT}/public/500.html",
               :status=>"500 Error"
        SystemNotifier.deliver_exception_notification(self,
                                                      request,
                                                      exception)
    end
  end


  #
  # PRIVATE METHODS
  #

  private

  def authorize
    #logger.info 'authorize'
    if not session[:user_id]
      #logger.info 'no user_id'
    end
    if not session['user_id'] or get_user().disabled
      #logger.info 'disabled user'
    end

    if not session[:user_id] or get_user().disabled
      reset_session
      redirect_to :action=>'login', :status=>:found
      return false
    end
  end

  def get_user
    return User.find(session[:user_id])
  end

  def update_activity
    user = get_user()
    if not user.nil?
      user.activity = Activity.new if user.activity.nil?
      user.activity.updated_at = Time.now
      user.activity.save
    end
  end

  #
  # Returns 'true' if a valid email address
  #
  def check_email(email)
    return !((email =~ %r{^[^@]+@([a-zA-Z0-9\-]+\.)+[a-zA-Z0-9]+$}).nil?)
  end
 
end
