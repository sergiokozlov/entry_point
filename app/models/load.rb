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

  def self.load_hr!
    hrr = Load::users_hierarchy

    hrr.each do |department|
      department['structure'].each do |group|
        # check for the manager and link group to a manager
        unless m = User.find(:first, :conditions => {:login => group['manager'], :type => 'Manager'})
          puts "Adding #{group['manager']}" 

          m = Manager.new
          m.email = m.login = group['manager']
          m.password_confirmation = m.password = 'Password10'
          m.create_group (:name => group['group'], :department => department['department'])

          begin
            m.save!
          rescue ActiveRecord::RecordInvalid
            puts "#{m.login} doesn't pass validation"
          end
        end

        # check developers and update position in hierarchy  
        group['developers'].each do |dev|
          unless user = User.find(:first, :conditions => {:login => dev})
            puts "Adding #{dev}" 

            user = Developer.new
            user.email = user.login = dev
            user.password_confirmation = user.password = 'Password10'
            user.group = m.group

            begin
              user.save!
            rescue ActiveRecord::RecordInvalid
              puts "#{dev.login} doesn't pass validation"
            end
          end
        end
    end
   end 

  end
  
  def run!
      processed_days = Array.new

       users,records = ProcessFile.process(@chunk)
       hrr = Load::users_hierarchy

       users.each do |u|
        
        unless user = User.find(:first, :conditions => {:login => u[:login]})
          puts "Adding #{u[:login]}" 

          user = User.new(u)
          user.email = user.login
          user.password_confirmation = user.password = 'Password10'
        end
        
        begin
          user.save!
        rescue ActiveRecord::RecordInvalid
          puts "#{u[:login]} doesn't pass validation"
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

