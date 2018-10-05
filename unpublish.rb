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

# Find GUIDs for specified file ids
contentsArray = File.readlines("../relocated/BITESIZE-7708.txt").map(&:chomp)

targetGuids = [];

count = 0

allFiles = Dir.glob("#{Settings.data}/extracted/live/*.xml").sort
allFiles.each  do |filename|
    guid = File.basename(filename, '.xml');
    xh = XmlHandler.new
    xh.init(IO.read(filename));

    fileId = xh.getXPathText('/xmlns:guide/xmlns:summary/xmlns:id');

    if contentsArray.include? fileId
        targetGuids.push(guid)
    end
end

# Unpublish the selected files
unPublishFiles = ISiteAPI.new();
unPublishFiles.unpublish(targetGuids)
