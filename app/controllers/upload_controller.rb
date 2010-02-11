class UploadController < ApplicationController

 DATA_DIR = File.dirname(__FILE__) + "/../../public/data" 

  def self.check_for_new_file
     true if Dir[DATA_DIR+"/snapshot*.txt"]
  end
 
  
  def table
      processed_days = Array.new
        
       File.open(DATA_DIR+"/snapshot.txt") do |file|
         file.each_line do |line|
            @record = Record.new ( :login => line.split(",")[0], :click_date => line.split(",")[1] )
           processed_days << @record.process if @record.save
           
         end
        WorkingDay.stat_refresh(processed_days.uniq)
       end
      
       flash[:notice] = "File was found" if UploadController.check_for_new_file
       redirect_to :controller =>'records', :action => 'show'
  end

end
