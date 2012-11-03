class InviteManager

  def self.go
    Thread.new {
      while true
        self.generate_invites
        #puts "InviteManager.sleep\n"
        sleep(1.hour)
      end
    }
  end

  def self.generate_invites
    users = User.get_with_no_invites
    users.concat(User.get_with_all_accepted_invites)
    for user in users
      rand(6).times {
        user.invites << Invite.new 
      }
    end
  end

end
