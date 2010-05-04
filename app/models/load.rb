require 'enkata_adapter'


class Load
  attr_reader :chunk

 DATA_DIR = File.dirname(__FILE__) + "/../../public/data"
 HRH_DIR = File.dirname(__FILE__) + "/../../public/hierarchy" 

  def initialize(chunk)
     @chunk = chunk
  end

  def self.new_files_to_process
     Dir.glob(DATA_DIR+"/*.csv")
  end
 
  def self.users_hierarchy
    File.open(HRH_DIR+"/enkata.yml") do |file|
     return  arr = YAML::load(file)
    end
  end
  
  def run!
      processed_days = Array.new

       users,records = ProcessFile.process(@chunk)
       hrr = Load::users_hierarchy

       users.each do |u|
        
        unless User.find(:first, :conditions => {:login => u[:login]})
          puts "Adding #{u[:login]}" 

          user = User.new(u)
          user.email = user.login
          user.set_type_and_manager(hrr)
          user.password_confirmation = user.password = 'Password10'

          begin
            user.save!
          rescue ActiveRecord::RecordInvalid
            puts "#{u[:login]} doesn't pass validation"
          end
        end
       end

       records.each do |rec| 
         @record = Record.new(rec)
         print "."
         processed_days << @record.process if @record.save
       end
       puts ''
       puts "Refreshing Daily Statistics"
       WorkingDay.stat_refresh(processed_days.uniq)

       puts "Load Completed"

      ProcessFile.cleanup(@chunk)
       puts "Cleanup Completed"
  end

end    

