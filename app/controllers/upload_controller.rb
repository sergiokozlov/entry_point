class UploadController < ApplicationController

 DATA_DIR = "C:/Sergio/EntryPoint/mc_and_dj/public/data" 

  def self.check_for_new_file
     true if Dir[DATA_DIR+"/snapshot*.txt"]
  end
 
  
  def table
      fields = [:login, :click_date]
      @data = Array.new
      
       File.open(DATA_DIR+"/snapshot.txt") do |file|
         file.each_line {|line| @data << line.split(",") }
       end
      
      Record.import (fields,@data)

      flash[:notice] = "#{@data[1]} found" if UploadController.check_for_new_file
      redirect_to :controller =>'records', :action => 'show'
  end

end
