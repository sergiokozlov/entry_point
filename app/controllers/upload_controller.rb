class UploadController < ApplicationController

 DATA_DIR = "C:/Sergio/EntryPoint/mc_and_dj/public/data" 

  def self.check_for_new_file
     true if Dir[DATA_DIR+"/snapshot*.txt"]
  end
 
  
  def table
        
       File.open(DATA_DIR+"/snapshot.txt") do |file|
         file.each_line do |line|
            @record = Record.new ( :login => line.split(",")[0], :click_date => line.split(",")[1] )
            @record.process if @record.save
         end
       end
      
       flash[:notice] = "File was found" if UploadController.check_for_new_file
       redirect_to :controller =>'records', :action => 'show'
  end

end
