# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  ABBR_DAYNAMES = %w(Sun Mon Tue Wed Thu Fri Sat)
  ABBR_MONTHNAMES = %w(Jan Feb Mar Apr May Jun July Aug Sep Oct Nov Dec)
  ABBR_FULL_MONTHNAMES = %w(January February March April May June July August September October November December)
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
 
  #date helpers
  #TODO correct code to work not only during current year
  
  def jan1(year)
    Date.parse("#{year}-01-01")
  end

  def week_last_day(week, year)
    jan1(year) + 7*week + 7 - jan1(year).cwday
  end 

  def week_first_day(week, year)
    week_last_day(week, year) - 6
  end
  
   def day_value(d)
     d.day.to_s + ' '+ ABBR_MONTHNAMES[d.month-1]
   end
   
  def full_day_value(d)
    "#{d.day} #{ABBR_FULL_MONTHNAMES[d.month-1]} #{d.year}" 
  end 
   
  def week_value(week, year)
    "#{day_value(week_first_day(week, year))} - #{day_value(week_last_day(week, year))}"
  end

  def month_value(month)
    ABBR_FULL_MONTHNAMES[month-1]
  end

  def recent_weeks(week, year, number)
    result = Array.new
  
  (0..number-1).each do |i|
    if week - i > 0
      result << [week - i, year]
    else
      result << [52 + week - i, year - 1]
    end
  end

  result.reverse
  end

  def recent_months(month, year, number)
    result = Array.new
  
  (0..number-1).each do |i|
    if month - i > 0
      result << [month - i, year]
    else
      result << [12 + month - i, year - 1]
    end
  end

  result.reverse
  end
end
