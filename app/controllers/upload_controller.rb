require 'enkata_adapter'

class UploadController < ApplicationController

 DATA_DIR = File.dirname(__FILE__) + "/../../public/data" 

  def self.check_for_new_file
     true if Dir[DATA_DIR+"/1222-1225-628.csv"]
  end
 
  
  def table
      processed_days = Array.new

=begin
      Dir.glob(DATA_DIR+"/snapshot*.txt").each do |snp|
      #TODO: Made chomp on the file  
       File.open(snp) do |file|
         file.each_line do |line|
            @record = Record.new ( :login => line.split(",")[0], :click_date => line.split(",")[1] )
           processed_days << @record.process if @record.save
           
         end
      end
        WorkingDay.stat_refresh(processed_days.uniq)
      end
=end
       users,records = ProcessFile.process(DATA_DIR+"/1222-1225-628.csv")
       hrr = users_hierarchy

       users.each do |u|
        puts "Adding #{u[:login]}"

        unless User.find(:first, :conditions => {:login => u[:login]}) 
          user = User.new(u)
          user.email = user.login

          user[:type], user[:reports_to] = user_type_manager(user.login,hrr)
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
         processed_days << @record.process if @record.save
       end

       WorkingDay.stat_refresh(processed_days.uniq)

       flash[:notice] = "File was found" if UploadController.check_for_new_file
       redirect_to :controller =>'records', :action => 'show'
  end

end
