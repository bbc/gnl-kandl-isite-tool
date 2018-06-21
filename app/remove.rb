#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'openssl'
require 'optparse'
require 'set'

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

#
require_relative 'lib/file-handler'
require_relative 'lib/xml-handler'

#
require_relative 'lib/isite2/delete'
require_relative 'lib/isite2/list'
require_relative 'lib/isite2/metadata'
require_relative 'lib/isite2/publish'
require_relative 'lib/isite2/unpublish'
require_relative 'lib/isite2/upload'

# Retrieve a list of guids from iSite2 for the filetype we're targetting
listFiles = ListContent.new;
targetGUIDs = listFiles.extractGUIDs();

# Example of determining GUIDs from a file instead of targetting a filetype
# targetGUIDs = File.readlines("narrative.txt").each{|line| line.chomp!}

# Determine the status of each document
documentStatus = ContentMetadata.new(targetGUIDs);

#
iSiteFiles = ISiteAPI.new;
iSiteFiles.unpublish(
    documentStatus.getPublishedDocuments()
);
iSiteFiles.delete(targetGUIDs);
