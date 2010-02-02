class UploadController < ApplicationController
  def row
      require_user
       @record = Record.new
  end

end
