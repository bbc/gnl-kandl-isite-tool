#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';
require 'openssl'

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'app/config/settings.rb'

#
require_relative 'app/lib/file-handler'
require_relative 'app/lib/xml-handler'

#
require_relative 'app/lib/isite2/delete'
require_relative 'app/lib/isite2/list'
require_relative 'app/lib/isite2/metadata'
require_relative 'app/lib/isite2/publish'
require_relative 'app/lib/isite2/unpublish'
require_relative 'app/lib/isite2/upload'

# Find GUIDs for Specified File Ids

# Which zids are we looking for
contentsArray = File.readlines("../relocated/one-step-guides.txt").map(&:chomp)

count = 0

allFiles = Dir.glob("#{Settings.data}/extracted/live/*.xml").sort
allFiles.each  do |filename|
    guid = File.basename(filename, '.xml');

    xh = XmlHandler.new
    xh.init(IO.read(filename));

    fileId = xh.getXPathText('/xmlns:article/xmlns:summary/xmlns:id');

    if contentsArray.include? fileId
        sourceMetadataFile = "#{Settings.cache}/metadata/#{guid}.json"
        destinationMetadataFile = "#{Settings.cache}/upload/#{guid}.json"

        sourceContentFile = filename
        destinationContentFile = filename.gsub('/extracted/', '/upload/')

        fh = FileHandler.new
        fh.copy(sourceMetadataFile, destinationMetadataFile)

        fh = FileHandler.new
        fh.copy(sourceContentFile, destinationContentFile)
        # count = count + 1
        # puts "| #{count} | https://www.bbc.co.uk/bitesize/articles/#{fileId} | #{guid} |"
    end
end

allFiles = Dir.glob("#{Settings.data}/extracted/in-progress/*.xml").sort
allFiles.each  do |filename|
    guid = File.basename(filename, '.xml');

    xh = XmlHandler.new
    xh.init(IO.read(filename));

    fileId = xh.getXPathText('/xmlns:article/xmlns:summary/xmlns:id');

    if contentsArray.include? fileId
        sourceContentFile = filename
        destinationContentFile = filename.gsub('/extracted/', '/upload/')

        fh = FileHandler.new
        fh.copy(sourceContentFile, destinationContentFile)
    end
end

# Send up the files that need to be published first
uploadFiles = UploadContent.new();
uploadFiles.process("#{Settings.data}/upload/live/*.xml")

# Then publish those documents
publish = PublishContent.new("#{Settings.cache}/upload/");
publish.useDirectory("#{Settings.data}/upload/live/");
publish.start();

# Finally send up the files that are in-progress
uploadFiles.process("#{Settings.data}/upload/in-progress/*.xml");

