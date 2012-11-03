
class SystemInfo

  def self.record_start_time
    @@start_time = Time.now 
  end

  def self.get_start_time
    return @@start_time
  end

end
