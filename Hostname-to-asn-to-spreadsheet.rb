#!/usr/bin/env ruby 

require 'rubygems'
require 'httparty'
require 'rest_client'
require 'net/dns/resolver'
require "google_spreadsheet"


# Define ARIN class and set it's base URL
class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
end


# Remove http:// and / from a string
def remove_uri(uri)
  uri.gsub(/http:\/\/(.*?)\/$/,"\\1")
  uri.gsub(/http:\/\/(.*?)/,"\\1")
  uri.gsub(/http:\/\/(.*?)/,"\\1")
end

# Login to Google Spreadsheet
session = GoogleSpreadsheet.login("emailaddress", "passwd")

# Establish the spreadsheet session
ws = session.spreadsheet_by_key("KEY").worksheets[0]

for row in 1..ws.num_rows
  p remove_uri(ws[row,2])
    hostname = remove_uri(ws[row,2])    
    hostname.each do |hostname|
      res = Net::DNS::Resolver.new(:nameservers => "8.8.4.4", :retry => 10)
      packet = Net::DNS::Resolver.start("#{hostname}")
      packet.each_address do |ip|
        begin
          response = ARIN.get("/ip/#{ip}")
          puts "#{hostname}'s ip address is #{ip}, and it's Origin ASn is " + response.parsed_response["net"]["originASes"]["originAS"]
          ws[row,22]=response.parsed_response["net"]["originASes"]["originAS"]
        rescue
          $stderr.print "Shit failed: " + $!
        end
      end
    end
end
ws.save()

