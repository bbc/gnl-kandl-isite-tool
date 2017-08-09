#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'fileutils'
require 'logger'
require 'nokogiri'
require 'openssl'
require 'optparse'
require 'yaml'

require_relative 'lib/content-transformer'
require_relative 'lib/file-finder'
require_relative 'lib/options'
require_relative 'lib/xml-handler'


# Allow for a custom log and use this to store the details
# of any issues when validating the content

baseDirectory = "./data/#{@config['environment']}-environment/#{@config['filetype']}"

logDirectory = "#{baseDirectory}/.logs/"
sourcePath = "#{baseDirectory}/#{@config['source']}"
targetPath = "#{baseDirectory}/#{@config['target']}"

FileUtils.mkdir_p(logDirectory) unless File.exists?(logDirectory)

console = Logger.new(STDOUT)
console.formatter = proc do |severity, datetime, progname, msg|
    "#{msg}\n"
end

log = Logger.new("#{logDirectory}/transforms.log")
log.formatter = proc do |severity, datetime, progname, msg|
    date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
    "[#{date_format}] #{severity} #{msg}\n"
end

# Find all the documents with source and also generate
# the path of the document to be created
documents = FileFinder.new(sourcePath, targetPath, console)
documents.process()

# Run the XSLT over the documents and log any errors
transformations = ContentTransformer.new(documents.results, @config, log, console)
transformations.process()
