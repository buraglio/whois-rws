#!/usr/bin/env ruby

require "rubygems"
require "google_spreadsheet"

# Remove http:// and / from a string
def remove_uri(uri)
  uri.sub(/http:\/\/(.*?)\/$/,"\\1")
end

session = GoogleSpreadsheet.login("username", "password")

# Establish the spreadsheet session
ws = session.spreadsheet_by_key("session-key").worksheets[0]

# Print cell A,2
p remove_uri(ws[2,2])