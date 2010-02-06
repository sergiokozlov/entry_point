class WorkingDay < ActiveRecord::Base
  has_many :records
 # virtual attributes

  def wday_string  
    wday.strftime("%m/%d/%Y")
  end

  def recalculate(whn = 'pasttime')
    self.check_in = Record.minimum(:click_date, :conditions => {:working_day_id => self.id})

    if whn =='today'
      self.check_out = Time.now
    else
      self.check_out = Record.maximum(:click_date, :conditions => {:working_day_id => self.id})
    end

    self.duration = (self.check_out.to_i - self.check_in.to_i).floor/60
    self.save
  end
end
