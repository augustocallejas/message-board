class ActivityManager

  #
  # Cleans up activities that haven't been accessed recently.
  # Runs in a separate thread every hour.
  #
  def self.go
    Thread.new {
      while true
        self.cleanup
        #puts "ActivityManager.sleep\n"
        sleep(1.hour)
      end
    }
  end

  def self.cleanup
    Activity.delete_recent()
  end

end
