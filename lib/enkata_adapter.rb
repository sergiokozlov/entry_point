module ProcessFile
# This module takes the input file, validates it and returns:
# array of records: [dt,login]
# array of users: [name,login]

	def self.login_from_name(name)
	  (name.split(' ')[1][0,1] + name.split(' ')[0]).downcase + '@enkata.com'
    rescue
      nil
	end
	
	def self.record_dt(date,time)
		DateTime.parse(date.gsub('.','-') + 'T' + time)
	rescue ArgumentError
		nil
	end
	
	def self.process(csv_chunk)
		names = Array.new()
		records = Array.new()
		
		File.open(csv_chunk) do |file|
		puts "processing ... #{file}"
			events = file.readlines
			#events.delete_if { |x|   not(x =~ /���� ��������/) }
			
			events.each do |record|
				data = record.split('","').map{|x| x.gsub('"','')}
				if dt = record_dt(data[2],data[3])
                name = data[-2]
                  if  login_from_name(name)
					names << name
					records << {:login => login_from_name(name), :click_date => dt }
                  end
				end 
			end
			users = names.uniq.map { |name| {:name => name, :login => login_from_name(name)} }
			return [users,records]
		end
	end

    def self.cleanup

    end

end

#puts ProcessFile.process("1222-1225-628.csv")