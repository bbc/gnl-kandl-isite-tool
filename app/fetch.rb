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
require_relative 'lib/isite2/filter'
require_relative 'lib/isite2/list'
require_relative 'lib/isite2/metadata'
require_relative 'lib/isite2/unpublish'
require_relative 'lib/isite2/delete'
require_relative 'lib/isite2/upload'
require_relative 'lib/isite2/publish'

#
require_relative 'lib/transform'

Settings.parseOptions

# Retrieve a list of guids from iSite2 for the filetype we're targetting
listFiles = ListContent.new;
iSiteGUIDs = listFiles.extractGUIDs();

# Determine the status of each document
documentStatus = ContentMetadata.new(iSiteGUIDs);

# Sort all the documents into the appropriate sub-directory
# and download any required files
filterFiles = FilterContent.new(
    documentStatus.getPublishedDocuments(),
    documentStatus.getInProgressDocuments(),
    './export/content'
);
filterFiles.extractLiveDocuments(
    "#{Settings.data}/extracted/live/:guid.xml"
);
filterFiles.extractInProgressDocuments(
    "#{Settings.data}/extracted/in-progress/:guid.xml"
);

# Apply the XSL to each XML document
tc = Transform.new(Settings.xslpath);

# Update the 'Live' documents
tc.update(
    "#{Settings.data}/extracted/live/*.xml",
    "#{Settings.data}/transformed/live/:guid.xml",
);

# Update the 'In-Progress' documents
tc.update(
    "#{Settings.data}/extracted/in-progress/*.xml",
    "#{Settings.data}/transformed/in-progress/:guid.xml",
);
