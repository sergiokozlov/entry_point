require 'enkata_adapter'


class Load 

 DATA_DIR = File.dirname(__FILE__) + "/../../public/data"
 HRH_DIR = File.dirname(__FILE__) + "/../../public/hierarchy" 

 def initialize

 end

  def check_for_new_file
     true if Dir[DATA_DIR+"/1222-1225-628.csv"]
  end
 
  def self.users_hierarchy
    File.open(HRH_DIR+"/enkata.yml") do |file|
     return  arr = YAML::load(file)
    end
  end
  
  def run!
      processed_days = Array.new

       users,records = ProcessFile.process(DATA_DIR+"/1222-1225-628.csv")
       hrr = Load::users_hierarchy

       users.each do |u|
        puts "Adding #{u[:login]}"

        unless User.find(:first, :conditions => {:login => u[:login]}) 
          user = User.new(u)
          user.email = user.login

          user[:type], user[:reports_to] = User::user_type_manager(user.login,hrr)
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

       puts "Refreshing Daily Statistics"
       WorkingDay.stat_refresh(processed_days.uniq)

       puts "Load Completed"

      ProcessFile.cleanup(DATA_DIR+"/1222-1225-628.csv")
       puts "Cleanup Completed"
  end

end    

