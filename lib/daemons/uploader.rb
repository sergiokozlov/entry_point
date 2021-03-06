#!/usr/bin/env ruby

# You might want to change this
ENV["RAILS_ENV"] ||= "production"

require File.dirname(__FILE__) + "/../../config/environment"

$running = true
Signal.trap("TERM") do 
  $running = false
end

while($running) do
  
  # TODO: Add logging
  # ActiveRecord::Base.logger.info "This daemon is still running at #{Time.now}.\n"
   ffs =  Load.new_files_to_process

   unless ffs.blank?
    Load.load_hr!

    ffs.each do |file| 
      next_load = Load.new(file) 
      next_load.run!
    end
   else
    sleep 600
   end 
end
