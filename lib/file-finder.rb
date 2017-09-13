#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

class FileFinder
    def initialize(source=nil, target=nil, console)
        @source = source
        @target = target
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
        fileExtension = File.extname(sourceFilename)
        guid = File.basename(sourceFilename, fileExtension)
        parentDirectory = File.basename(File.dirname(sourceFilename))

        targetFilename = @target.gsub('/**', "/#{parentDirectory}")
        targetFilename = targetFilename.gsub('/*', "/#{guid}")

        if File.extname(targetFilename) != fileExtension
            targetFilename += fileExtension
        end

        {
            :source => sourceFilename,
            :target => targetFilename
        }
    end

    def results
        @results
    end
end
