#!/usr/bin/env ruby 

require 'rubygems'
require 'httparty'
require 'rest_client'
require 'net/dns/resolver'
require 'google_spreadsheet'
#require 'em-resolv-replace'
    
# Define ARIN class and set it's base URL
class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
    
  # Returns the organization handle which is associated with the network assignment which owns the IP address
  # given to the method as an argument.
  def self.org_handle(ip)
    get("/ip/#{ip}").parsed_response["net"]["orgRef"].to_s.split('/').last
  end
    
  # Returns Autonomous Systems Number associated with an organization handle.
  def self.as_number(orghandle)
    # Ask ARIN which ASN owns the orghandle passed to this method
    get("/org/#{orghandle}/asns").parsed_response["asns"]["asnRef"].to_s.split('/').last
  end
  
  # Returns a hash of all network prefixes owned by a given orghandle
  def self.networks(orghandle)
    get("/org/#{orghandle}/nets").parsed_response["nets"]["netRef"]
  end
  
  
  #{"net"=>
    #{"name"=>"GO-DADDY-SOFTWARE-INC", "comment"=>{"line"=>"Please send abuse complaints to abuse@godaddy.com"}, "startAddress"=>"173.201.0.0", "handle"=>"NET-173-201-0-0-1", "updateDate"=>"2009-09-18T00:00:00-04:00", 
    #{}"parentNetRef"=>"http://whois.arin.net/rest/net/NET-173-0-0-0-0", "originASes"=>
      #{"originAS"=>"AS26496"}, "orgRef"=>"http://whois.arin.net/rest/org/GODAD", "version"=>"4", "endAddress"=>"173.201.255.255", "nameservers"=>
      #{}"nameserver"=>["CNS1.SECURESERVER.NET", "CNS2.SECURESERVER.NET", "CNS3.SECURESERVER.NET"]}, "netBlocks"=>{"netBlock"=>{"startAddress"=>"173.201.0.0", "type"=>"DA", "endAddress"=>"173.201.255.255", "cidrLength"=>"16", "description"=>"Direct Allocation"}}, "ref"=>"http://whois.arin.net/rest/net/NET-173-201-0-0-1", "termsOfUse"=>"https://www.arin.net/whois_tou.html", "registrationDate"=>"2009-09-18T00:00:00-04:00", "xmlns"=>"http://www.arin.net/whoisrws/core/v1"}}
  
  def self.cidr_length(net)
    get(net).parsed_response["net"]["name"]["handle"]
    get(net).parsed_response["net"]["netBlocks"]["netBlock"]["cidrLength"]
  end
  
  #def self.process_spreadsheet(hostcolumn,ascolumn,firstrow,lastrow)
  
  def self.cidr_networks(orghandle)
    ARIN.networks(orghandle).each do |net|
      p net
      p ARIN.cidr_length(net)
    end
  end
    
end

# Remove http:// and / from a string
def only_uri(uri)
  uri.gsub(/http:\/\/(.*?)\/$/,"\\1")
end    

# Login to Google Spreadsheet
session = GoogleSpreadsheet.login("email@address.com", "password")

# Establish the spreadsheet session
ws = session.spreadsheet_by_key("sessionid").worksheets[0]

# Iterate through the spreadsheet, starting at the second row to avoid the header
#for row in ws.num_rows-5..ws.num_rows
for row in 2..6
  hostname = only_uri(ws[row,2])    
  hostname.each do |hostname|
  begin
    Net::DNS::Resolver.new(:nameservers => "8.8.4.4")
    Net::DNS::Resolver.start(hostname).each_address do |ip|
      orghandle = ARIN.org_handle(ip)
      p orghandle
      asn = ARIN.as_number(orghandle)
      ws[row,21] = asn
      p "#{hostname}'s ip address is #{ip}, it's ORG Handle is #{orghandle}, and it's asn is #{asn}"         
      ARIN.cidr_networks(orghandle)
      # Next we need to go through every net associated with an org handle, go to it's network handle page, read them all into an array, convert the cidr mask into a count, then add
    end
      rescue
        $stderr.print "DNS Shit failed: " + $!
      end 
  end
end
# Write changes to worksheet
ws.save()
