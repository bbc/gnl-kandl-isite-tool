#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';

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


Settings.parseOptions

# Retrieve a list of guids from iSite2 for the filetype we're targetting
listFiles = ListContent.new;
targetGUIDs = listFiles.extractGUIDs();

# Determine the status of each document
documentStatus = ContentMetadata.new(targetGUIDs);

# deletableDocuments = DeleteContent.new(targetGUIDs);
# #deletableDocuments.delete();
# deletableDocuments.permanent();

# #
# iSiteFiles = ISiteAPI.new;
# iSiteFiles.unpublish(
#     documentStatus.getPublishedDocuments()
# );
# # iSiteFiles.delete(targetGUIDs);
