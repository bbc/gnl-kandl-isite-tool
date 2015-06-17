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


# Send up the files that need to be published first
uploadFiles = UploadContent.new();
uploadFiles.process("#{Settings.data}/upload/live/*.xml")

# Then publish those documents
publish = PublishContent.new("#{Settings.cache}/upload/");
publish.useDirectory("#{Settings.data}/upload/live/");
publish.start();

# Finally send up the files that are in-progress
uploadFiles.process("#{Settings.data}/upload/in-progress/*.xml");
