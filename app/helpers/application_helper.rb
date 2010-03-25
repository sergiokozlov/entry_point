# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
  # Hours and minutes arithmetics
  def h60  (i)
    i / 60
  end
  
  def m60 (i)
    i % 60
  end  
  
  def leading_zero(n)
    if n.to_s.length == 1
      '0'+n.to_s
    else
      n.to_s
    end
  end
  
  def to_time(minutes)
    leading_zero(h60(minutes)) + ':' + leading_zero(m60(minutes))
  end
  
  # array of days starting from today going backwards for lag days
  def days_array(length,lag=0)
    a = Array.new
    d = Date.today
    (-length..-lag).each {|i| a << d + i}
    return a
  end
end
