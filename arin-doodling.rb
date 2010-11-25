#!/usr/bin/env ruby
require 'rubygems'
require 'httparty'
require 'rest_client'
require 'spreadsheet'


class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
end


# The POC Data types: 
# ["city", "comment", "iso3166_2", "companyName", "handle", "lastName", "updateDate", "postalCode", "streetAddress", "firstName", "emails", "phones", "ref", "termsOfUse", "registrationDate", "xmlns", "iso3166_1"]
response = ARIN.get("/poc/KOSTE-ARIN")
p response.parsed_response["poc"].keys
#p response.parsed_response["poc"]["postalCode"]

p response.parsed_response["poc"]["handle"]


#response.parsed_response["poc"].keys.each { |k| p k }