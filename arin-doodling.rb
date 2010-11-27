#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'rest_client'
require 'pp'
require 'net/dns/resolver'

# ARIN's Web Services data model has five main first-order objects: networks, autonomous system numbers (asn), organizations, points of contacts, and customer

class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
end

# ARIN Network experimentation
 # Fields in a NET Record
 # ["name", "startAddress", "handle", "updateDate", "parentNetRef", "originASes", "orgRef", "version", "endAddress", "nameservers", "netBlocks", "ref", "termsOfUse", "registrationDate", "xmlns"]
 
 response = ARIN.get("/net/NET-208-75-56-0-1")
 p response.parsed_response["net"]["netBlocks"]
 
# ARIN Autonomous System Numbers experimentation
# ARIN Organization experimentation
 # Fields in an ORG Record
 # ["city", "name", "comment", "iso3166_2", "handle", "updateDate", "postalCode", "streetAddress", "ref", "termsOfUse", "registrationDate", "xmlns", "iso3166_1"]

 response = ARIN.get("/org/BITPU")
 # print all ORG keys
 puts "All ORG keys for " + response.parsed_response["org"]["name"]
 p response.parsed_response["org"].keys
 puts "\n"

 # The ability to get a bio on an IP address is really fucking  useful.
 response = ARIN.get("/ip/208.75.57.232")
 p response
 
# ARIN Point Of Contact experimentation
 # Fields in a POC record
 # ["city", "comment", "iso3166_2", "companyName", "handle", "lastName", "updateDate", "postalCode", "streetAddress", "firstName", "emails", "phones", "ref", "termsOfUse", "registrationDate", "xmlns", "iso3166_1"]
 response = ARIN.get("/poc/BITPU-ARIN")
 # print all POC keys
 puts "All POC Keys for " + response.parsed_response["poc"]["companyName"]
 p response.parsed_response["poc"].keys
 puts "\n"
 
 # print the POC's company name
 p response.parsed_response["poc"]["companyName"]
 
 # Print the POC handle
 p response.parsed_response["poc"]["handle"].chomp
 
 # Print all of the networks associated with a POC
 response = ARIN.get("/poc/BITPU-ARIN/nets")
 p response.parsed_response["nets"]["netPocLinkRef"][0].to_s.gsub(/http:\/\/whois.arin.net\/rest\/net\/NET-/, '')
 puts "\n"

 # Print all of the ASNs associated with a POC
 response = ARIN.get("/poc/BITPU-ARIN/asns")
 
 # No idea why ARIN returns 3 responses, will research later,  but they get turned into an array so we can move on.
 p response.parsed_response["asns"]["asnPocLinkRef"][0].to_s.gsub(/http:\/\/whois.arin.net\/rest\/asn\/AS/, '')
 

# puts Resolver("www.bitpusher.com").answer

 packet = Net::DNS::Resolver.start("bitpusher.com")
 packet.each_address do |ip|
      response = ARIN.get("/ip/#{ip}")
      puts "#{ip}" + "'s Associated AS Number is " + response.parsed_response["net"]["originASes"]["originAS"]
    end
 
# ARIN Customer experimentation

# Scratch
# 
# p response.parsed_response["poc"]["postalCode"]
# response.parsed_response["poc"].keys.each { |k| p k }