#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'set';

require_relative '../file-handler'

class FilterContent
    def initialize(live, inProgress, exportDirectory = '')
        @liveDocuments = live;
        @inProgressDocuments = inProgress;

        @downloadLiveDocuments = Array.new;
        @downloadInProgressDocuments = Array.new;

        (@liveDocuments & @inProgressDocuments).each {|guid|
            @downloadLiveDocuments << guid
        }

        puts "Preparing to extract documents..."
        puts "================================================="

        if (not exportDirectory.empty?) && File.directory?(exportDirectory)
            puts " => using export directory: #{exportDirectory}";
            @exportDirectory = exportDirectory;
        else
            puts " => no export directory specified (all documents will be downloaded)";
            @exportDirectory = '';
        end
        puts
    end

    def cleanDirectory(destination)
        FileUtils.rm_rf(destination);
    end

    def extractLiveDocuments(destination)
        puts "Extracting 'Live' documents..."
        puts "================================================="

        @liveDocuments.each { |guid|
            exportedFile = "#{@exportDirectory}/#{guid}.xml"

            if @downloadLiveDocuments.include? guid
                # The file has been marked as being 'in-progess' and 'live'
                # whereas an export will only contain the 'in-progress' copy of
                # the document, so ignore this GUID as it's already marked as to
                # be downloaded directly from iSite
            elsif File.file?(exportedFile)
                # A file with the same GUID exists in the export directory
                # so copy it into the destination directory
                destinationPath = destination.gsub(':guid', guid);

                # Copy the exported file into the specified directory
                fh = FileHandler.new
                fh.copy(exportedFile, destinationPath);
            else
                # As there's no copy of the file in the export directory
                # download the file directly from iSite
                @downloadLiveDocuments << guid;
            end
        }

        destinationDirectory = File.dirname(destination);
        fileCount = Dir["#{destinationDirectory}/*.xml"].length;

        puts " => #{fileCount.to_s} exported document(s) moved to the 'Live' directory";
        puts " => #{@downloadLiveDocuments.length.to_s} document(s) need to be downloaded from iSite";
        puts

        if not @downloadLiveDocuments.empty?
            puts "Downloading 'Live' documents..."
            puts "================================================="

            downloadDocuments(
                Settings.publishedContentURL,
                @downloadLiveDocuments,
                destination
            );
        end
    end

    def extractInProgressDocuments(destination)
        puts "Extracting 'In-Progress' documents..."
        puts "================================================="

        @inProgressDocuments.each { |guid|
            exportedFile = "#{@exportDirectory}/#{guid}.xml"

            if File.file?(exportedFile)
                # A file with the same GUID has been found in the export
                # directory so copy it into the destination directory
                destinationPath = destination.gsub(':guid', guid);

                # Copy the exported file into the specified directory
                fh = FileHandler.new
                fh.copy(exportedFile, destinationPath);
            else
                # As there's no copy of the file in the export directory
                # download the file directly from iSite
                @downloadInProgressDocuments << guid;
            end
        }

        destinationDirectory = File.dirname(destination);
        fileCount = Dir["#{destinationDirectory}/*.xml"].length;

        puts " => #{fileCount.to_s} exported document(s) moved to the 'In-Progress' directory";
        puts " => #{@downloadInProgressDocuments.length.to_s} document(s) need to be downloaded from iSite";
        puts

        if not @downloadInProgressDocuments.empty?
            puts "Downloading 'In-Progress' documents..."
            puts "================================================="

            downloadDocuments(
                Settings.latestContentURL,
                @downloadInProgressDocuments,
                destination
            );
        end
    end

    def downloadDocuments(url, guids, destination)
        baseURI = URI.parse(url)

        sslCert = OpenSSL::X509::Certificate.new(Settings.pemFile)
        sslKey = OpenSSL::PKey::RSA.new(Settings.pemFile)

        queue = Queue.new
        guids.map { |guid| queue << guid }

        successCount = 0;
        failureCount = 0;

        threads = Settings.threads.times.map do
            Thread.new do
                # prepare the request
                Net::HTTP.start(
                    baseURI.host,
                    baseURI.port,
                    :use_ssl => true,
                    :cert => sslCert,
                    :key => sslKey,
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && guid = queue.pop
                        guidURL = url.gsub(':guid', guid);
                        uri = URI.parse(guidURL);

                        # Request the (XML) file
                        response = http.request_get(uri.request_uri)

                        if response.code === '200'
                            # As handling XML data ensure that it's treated
                            # as UTF-8 so that the data is preserved correctly
                            responseXml = response.body.force_encoding('UTF-8')

                            # When downloading a 'live' file there are some
                            # additional XML elements added to the document by the
                            # content reader, so strip them out
                            xh = XmlHandler.new
                            xh.init(responseXml);
                            xh.stripReaderXml();

                            successCount += 1;

                            destinationPath = destination.gsub(':guid', guid);

                            # Save the XML file
                            fh = FileHandler.new
                            fh.create(destinationPath, xh.asString());
                        else
                            failureCount += 1;
                            puts " => Unable to download (Error: #{response.code}): #{guid}"
                        end
                    end
                end
            end
        end

        threads.each(&:join)

        puts " => #{successCount.to_s} document(s) successfully downloaded"
        puts
    end
end
