class BoardMailer < ActionMailer::Base

  def invite(from_user, to_email, invitekey)
    @subject    = 'messageboard invite.'
    @body       = {:invitekey=>invitekey,
                   :from_user=>from_user}
    @recipients = to_email
    @from       = 'admin@example.com'
    @sent_on    = Time.now
    @headers    = {}
  end

  def reset_password(to_email, new_password)
    @subject    = 'password reset.'
    @body       = {:new_password=>new_password}
    @recipients = to_email
    @from       = 'admin@example.com'
    @sent_on    = Time.now
    @headers    = {}
  end
end
