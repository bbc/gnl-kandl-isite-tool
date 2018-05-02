#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'logger'
require 'openssl'
require 'optparse'
require 'set'

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'app/config/settings.rb'
require_relative 'app/lib/file-handler'
require_relative 'app/lib/isite2/upload'
require_relative 'app/lib/xml-handler'
require_relative 'lib/service/isite2/publish'

logDirectory = sprintf(
    "./data/%s-environment/%s/%s/.logs/",
    Settings.environment,
    Settings.project,
    Settings.filetype
)

FileUtils.mkdir_p(logDirectory) unless File.exists?(logDirectory)

console = Logger.new(STDOUT)
console.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
end

uploadLog = Logger.new("#{logDirectory}/upload.log")
uploadLog.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity} #{msg}\n"
end

publishLog = Logger.new("#{logDirectory}/publish.log")
publishLog.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity} #{msg}\n"
end

# Send up the files that need to be published first
uploadFiles = UploadContent.new()
uploadFiles.process("#{Settings.data}/upload/live/*.xml")

# Then publish those documents
publish = PublishService.new(Settings, console, publishLog)
publish.source("#{Settings.data}/upload/live/*.xml")
publish.start()
publish.prepareRequests()

# Finally send up the files that are in-progress
uploadFiles.process("#{Settings.data}/upload/in-progress/*.xml")
