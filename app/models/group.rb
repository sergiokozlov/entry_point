class Group < ActiveRecord::Base
  has_one :manager, :foreign_key => 'manager_id'
  has_many :developers

  def weeks_to_analyze
    result = Array.new

    self.developers.each do |dev| 
      result += dev.logged_working_weeks
    end
    result.uniq.sort {|a,b| b<=> a}
  end
  
end
