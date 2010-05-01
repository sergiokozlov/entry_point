#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "development"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # TODO: Add logging
  # ActiveRecord::Base.logger.info "This daemon is still running at #{Time.now}.\n"
   next_load = Load.new
   if next_load.check_for_new_file
    next_load.run!
   else
    sleep 600
   end 
end
