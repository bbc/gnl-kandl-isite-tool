#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

class FileFinder
    def initialize(source=nil, target=nil, metadataFolder=nil, console)
        @source = source
        @target = target
        @metadataFolder = metadataFolder
        @console = console
        @results = []
    end

    def process()
        @console.info "Analysing documents..."
        @console.info "================================================="

        if !Dir.glob(@source).empty?
            allFiles = Dir.glob(@source).sort
            allFiles.each  do |filename|
                if File.file?(filename)
                    @results << getFileDetails(filename)
                end
            end
        elsif File.file?(@source)
            @results << getFileDetails(filename)
        else
            raise ArgumentError, "Unable to find specified source: #{@source}"
        end

        @console.info " => Identified #{@results.count.to_s} document(s)"
        @console.info
    end

    def getFileDetails(sourceFilename)
        sourceFileExtension = File.extname(sourceFilename)
        guid = File.basename(sourceFilename, sourceFileExtension)
        parentDirectory = File.basename(File.dirname(sourceFilename))

        targetFilename = @target.gsub('/**', "/#{parentDirectory}")
        targetFilename = targetFilename.gsub('/*', "/#{guid}")

        if File.extname(targetFilename) != sourceFileExtension
            targetFilename += sourceFileExtension
        end

        metadataFilename = @metadataFolder.gsub('/*', "/#{guid}")
        if File.extname(metadataFilename) != ".json"
            metadataFilename += '.json'
        end

        {
            :source => sourceFilename,
            :target => targetFilename,
            :metadata => metadataFilename
        }
    end

    def results
        @results
    end
end
