# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Board::Application.initialize!

## Include your application configuration below

require 'InviteManager'
InviteManager.go

require 'SessionManager'
SessionManager.go

require 'ActivityManager'
ActivityManager.go

require 'SystemInfo'
SystemInfo.record_start_time

require 'will_paginate'
