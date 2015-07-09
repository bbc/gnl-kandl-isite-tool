#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

#
require_relative 'lib/file-handler'

Settings.parseOptions

# If the downloaded file and the transformed file are the same then there's
# no point in re-uploading the file
Dir.glob("#{Settings.data}/updated/**/*.xml") do |updatedFile|
    extractedFile = updatedFile.gsub('/updated/', '/extracted/');
    uploadFile = updatedFile.gsub('/updated/', '/upload/');

    if File.file?(extractedFile)
        if FileUtils.compare_file(extractedFile, updatedFile) === false
            # The files are different, so copy the updated version
            # into the upload directory
            fh = FileHandler.new
            fh.copy(updatedFile, uploadFile)
        end
    end
end

# Check if documents marked as in progress are the same as the published
# version. If so delete the in progress version as it doesn't actually
# contain any changes
Dir.glob("#{Settings.data}/upload/live/*.xml") do |publishedFile|
    inProgressFile = publishedFile.sub('/upload/live/', '/upload/in-progress/');

    if File.file?(inProgressFile)
        if FileUtils.compare_file(publishedFile, inProgressFile) === true
            # The files are the same, so remove the in progress version
            FileUtils.rm(inProgressFile);
            puts "Removed #{inProgressFile} as the 'in-progress' version is no different from the published version"
        end
    end
end
