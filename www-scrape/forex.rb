require 'date'
require 'mechanize'
# Also using nokogiri 

def xrates_lookup(from, to, date)
  key = date.to_s
  a = Mechanize.new { |agent|
    agent.user_agent_alias = 'Mac Safari'
  }
  r=nil
  url = "http://www.x-rates.com/historical/?from=#{from}&amount=1.00&date=#{key}"
  print "Fetching from : #{url}\n"
  a.get(url) do |page|
    #puts "Warning: No XRATE rate for: #{key}"
    # Find: table class="ratesTable"
    
    hdr =  page.at("span[class='OutputHeader']")
    print hdr.text + ": "
    tbl =  page.at("table[class='tablesorter ratesTable']")
    if tbl
      # Iterate over each row
      tr = tbl.css("tr")
      if tr
        tr.map do | row |
          # TD0 is the fullname
          # look for the link that includes the forex PAIR
          links = row.css("a")
          links.map do |link|
            if  link["href"] =~ /to=#{to}/
              td0 = row.xpath("./td")[0]
              print "#{date} : to=#{to}, from=#{from}: #{td0.text}: #{link.text}"
              return
            end
          end
        end
      end
    end
  end
  print "Not found!"
end

if ARGV.length != 3
  print "USAGE: forex: FROM TO DATE"
else
  from=ARGV[0]
  to=ARGV[1]
  date=Date.parse(ARGV[2])
  xrates_lookup(from, to, date)
end
