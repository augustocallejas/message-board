
class SessionManager

  #
  # Cleans up sessions that haven't been accessed in a week.
  # Runs in a separate thread every 4 hours.
  #
  def self.go
    Thread.new {
      while true
        self.cleanup
        #puts "SessionManager.sleep\n"
        sleep(4.hours)
      end
    }
  end

  def self.cleanup
        ActiveRecord::SessionStore::Session.
          destroy_all(['updated_at < ?', 1.week.ago])
  end

end
