# encoding windows-1251
require 'fileutils'
require 'rubygems'
require 'russian'
require 'iconv'
require 'hierarchy_lookup'


module ProcessFile
# This module takes the input file, validates it and returns:
# array of records: [dt,login]
# array of users: [name,login]

  #TODO: Dry Violation - but it's adapter so ...
	def self.login_from_name(name)
	  (name.split(' ')[1][0,1] + name.split(' ')[0]).downcase
    rescue
      nil
	end
	
	def self.record_dt(date,time)
		DateTime.parse(date.gsub('.','-') + 'T' + time) unless date =~ /2000/
	rescue ArgumentError
		nil
	end
	
	def self.process(csv_chunk)
		names = Array.new()
		records = Array.new()
        ic = Iconv.new('UTF-8','WINDOWS-1251')
		
		File.open(csv_chunk) do |file|
		puts "processing ... #{file.path}"
			events = file.readlines
			#events.delete_if { |x|   not(x =~ /??????? }
			
			events.each do |record|
				data = record.split("\t")
                #puts dt = record_dt(data[0],data[1])
                #puts Russian.translit(ic.iconv(data[4]))
                #puts login_from_name(Russian.translit(ic.iconv(data[4])))

                if dt = record_dt(data[0],data[1])
                name = HierarchyLookup.lookup(Russian.translit(ic.iconv(data[4])).strip)
				if  login_from_name(name)
					names << name
					records << {:login => login_from_name(name), :click_date => dt }
                  end
				end 

			end
			users = names.uniq.map { |name| {:name => name.split(' ')[1] + ' ' + name.split(' ')[0], :login => login_from_name(name)} }
			return [users,records]
			#return users
		end
	end

    def self.cleanup (csv_chunk)
      destination = File.dirname(csv_chunk) + '/processed/'
      #destination = '/processed/'
      FileUtils.mv(csv_chunk, destination)
    end

end

#puts ProcessFile.process("מעקוע.txt")
