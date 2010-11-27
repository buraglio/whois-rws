#!/usr/bin/env ruby

# Simple script whith a hostname, resolves it, query's ARIN's whois database, and tells you the origin Autonomous Systems Number the IP belongs to

require 'rubygems'
require 'httparty'
require 'rest_client'
require 'net/dns/resolver'


class ARIN
  include HTTParty
  base_uri 'http://whois.arin.net/rest'
end

ARGV.each do |hostname|
  packet = Net::DNS::Resolver.start("#{hostname}")
  packet.each_address do |ip|
    response = ARIN.get("/ip/#{ip}")
    puts "#{hostname}'s ip address is #{ip}, and it's Origin ASn is " + response.parsed_response["net"]["originASes"]["originAS"]
  end
end