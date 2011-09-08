require 'renaissance_adapter'


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
        unless m = User.find(:first, :conditions => {:name => group['manager'], :type => 'Manager'})
          puts "Adding #{group['manager']}" 

          m = Manager.new(:name => group['manager'])
          begin
            m.save!
		  rescue ActiveRecord::RecordInvalid
            puts "#{m.name} doesn't pass validation"
          end
		  
		  g = m.create_group(:name => group['group'], :department => department['department'])
		  p g
        else
          g = m.group
        end

        #check for the director and link groups to them
        department['directors'].each do |director|
          unless d = User.find(:first, :conditions => {:name => director, :type => 'Director'})
            puts "Adding #{director}" 

            d = Director.new(:name => director)

            begin
              d.save!
            rescue ActiveRecord::RecordInvalid
              puts "#{d.name} doesn't pass validation"
            end
          end
          d.groups = d.groups | [g]
        end

          # check developers and update position in hierarchy  
          group['developers'].each do |dev|
            unless user = User.find(:first, :conditions => {:name => dev})
              puts "Adding #{dev}" 

              new_user = Developer.new(:name => dev)
              new_user.group = g

              begin
                new_user.save!
              rescue ActiveRecord::RecordInvalid
                puts "#{dev.name} doesn't pass validation"
              end
            else
              user.group = g
              user.save!
            end
          end
        end
      end 
    end

    def run!
      processed_days = Array.new

      users,records = ProcessFile.process(@chunk)

      users.each do |u|
        unless user = User.find(:first, :conditions => {:login => u[:login]})
          puts "Adding #{u[:name]} that wasn't found in hierarchy"

          user = User.new(u)
    
        begin
          user.save!
        rescue ActiveRecord::RecordInvalid
          puts "#{u[:name]} raw data doesn't pass validation"
        end
		
		end
      end

      records.each do |rec| 
        @record = Record.new(rec)
        print "."
        processed_days << @record.process if @record.save && @record.user
      end
      puts ''
      puts "Refreshing Daily Statistics"
      WorkingDay.stat_refresh(processed_days.uniq)

      puts "Load Completed"

      ProcessFile.cleanup(@chunk)
      puts "Cleanup Completed"
    end

  end    

