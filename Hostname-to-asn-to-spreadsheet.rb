#!/usr/bin/env ruby 

require 'rubygems'
require 'httparty'
require 'rest_client'
require 'net/dns/resolver'
require 'google_spreadsheet'
require 'em-resolv-replace'
    
# Define ARIN class and set it's base URL
class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
  
  # Remove http:// and / from a string
  def self.only_uri(uri)
    uri.gsub(/http:\/\/(.*?)\/$/,"\\1")
  end    
  
  def self.only_orghandle(ip)
    # Ask ARIN which ORG handle owns the IP address passed to this method
    get("/ip/#{ip}").parsed_response["net"]["orgRef"].to_s.split('/').last
      end
    
  def self.only_asn(orghandle)
    # Ask ARIN which ASN owns the orghandle passed to this method
    get("/org/#{orghandle}/asns").parsed_response["asns"]["asnRef"].to_s.split('/').last
  end
  
  # Return a hash of all networks owned by a given orghandle
  def self.only_nets(orghandle)
    get("/org/#{orghandle}/nets").parsed_response["nets"]["netRef"]
  end
  
  
  #{"net"=>
    #{"name"=>"GO-DADDY-SOFTWARE-INC", "comment"=>{"line"=>"Please send abuse complaints to abuse@godaddy.com"}, "startAddress"=>"173.201.0.0", "handle"=>"NET-173-201-0-0-1", "updateDate"=>"2009-09-18T00:00:00-04:00", 
    #{}"parentNetRef"=>"http://whois.arin.net/rest/net/NET-173-0-0-0-0", "originASes"=>
      #{"originAS"=>"AS26496"}, "orgRef"=>"http://whois.arin.net/rest/org/GODAD", "version"=>"4", "endAddress"=>"173.201.255.255", "nameservers"=>
      #{}"nameserver"=>["CNS1.SECURESERVER.NET", "CNS2.SECURESERVER.NET", "CNS3.SECURESERVER.NET"]}, "netBlocks"=>{"netBlock"=>{"startAddress"=>"173.201.0.0", "type"=>"DA", "endAddress"=>"173.201.255.255", "cidrLength"=>"16", "description"=>"Direct Allocation"}}, "ref"=>"http://whois.arin.net/rest/net/NET-173-201-0-0-1", "termsOfUse"=>"https://www.arin.net/whois_tou.html", "registrationDate"=>"2009-09-18T00:00:00-04:00", "xmlns"=>"http://www.arin.net/whoisrws/core/v1"}}
  
  def self.only_cidrlength(net)
    get(net).parsed_response["net"]["name"]["handle"]
    get(net).parsed_response["net"]["netBlocks"]["netBlock"]["cidrLength"]
  end
  
  def self.process_spreadsheet(hostcolumn,ascolumn,firstrow,lastrow,)
end

# Login to Google Spreadsheet
session = GoogleSpreadsheet.login("email@address.com", "password")

# Establish the spreadsheet session
ws = session.spreadsheet_by_key("sessionid").worksheets[0]

# Iterate through the spreadsheet, starting at the second row to avoid the header
#for row in ws.num_rows-5..ws.num_rows
for row in 2..6
  hostname = ARIN.only_uri(ws[row,2])    
  hostname.each do |hostname|
  begin
    Net::DNS::Resolver.new(:nameservers => "8.8.4.4")
    Net::DNS::Resolver.start(hostname).each_address do |ip|
      orghandle = ARIN.only_orghandle(ip)
      p orghandle
      asn = ARIN.only_asn(orghandle)
      ws[row,21] = asn
      p "#{hostname}'s ip address is #{ip}, it's ORG Handle is #{orghandle}, and it's asn is #{asn}"         
      ARIN.only_nets(orghandle).each do |net|
        p net
        p ARIN.only_cidrlength(net)
      end
      # Next we need to go through every net associated with an org handle, go to it's network handle page, read them all into an array, convert the cidr mask into a count, then add
    end
      rescue
        $stderr.print "DNS Shit failed: " + $!
      end 
  end
end
# Write changes to worksheet
ws.save()
