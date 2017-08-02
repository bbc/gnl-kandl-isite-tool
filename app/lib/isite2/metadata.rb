#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'set';

class ContentMetadata

    # loop over the guids and find any that are not cached
    # query isite for all non-cached guids and save as cached files
    # for each GUID then determine if it's 'in-progress' or 'published'
    def initialize(guids)
        @guids = guids;
        @published = Set.new;
        @progress = Set.new;

        puts "Querying metadata for each document...";
        puts "================================================="

        nonCachedGuids = getNonCachedGUIDs();

        if nonCachedGuids.length >= 1
            createCachedData(nonCachedGuids);
        end

        extractDocumentState();

        puts " => #{@published.size.to_s} documents are marked as 'published'"
        puts " => #{@progress.size.to_s} documents are marked as 'in progress'"
        puts
    end

    def getNonCachedGUIDs()
        nonCachedGuids = @guids.select {|guid|
            !File.file? getCacheFileName(guid)
        }
    end

    def getCacheFileName(guid)
        "#{Settings.cache}/metadata/#{guid}.json";
    end

    def createCachedData(nonCachedGuids)
        baseURI = URI.parse(Settings.metadataURL);

        sslCert = OpenSSL::X509::Certificate.new(Settings.pemFile)
        sslKey = OpenSSL::PKey::RSA.new(Settings.pemFile)

        queue = Queue.new;
        nonCachedGuids.map { |guid| queue << guid }

        threads = Settings.threads.times.map do
            Thread.new do
                # prepare the request
                Net::HTTP::Proxy(
                    Settings.proxyHost,
                    Settings.proxyPort
                ).start(
                    baseURI.host,
                    baseURI.port,
                    :use_ssl => true,
                    :cert => sslCert,
                    :key => sslKey,
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && guid = queue.pop
                        guidURL = Settings.metadataURL.gsub(':guid', guid);
                        uri = URI.parse(guidURL);

                        # make the actual request
                        response = http.request_get(uri.request_uri);

                        if response.code === '200'
                            results = JSON.parse(response.body);

                            fh = FileHandler.new;
                            fh.create(
                                getCacheFileName(guid),
                                JSON.pretty_generate(results)
                            );
                        else
                            results = '';
                            puts " => missing metadata: #{guidURL}";
                        end
                    end
                end
            end
        end

        threads.each(&:join);
    end

    def extractDocumentState()
        # loop over all the metadata files and determine whether the document
        # is 'in-progress', 'published', or both
        @guids.each { |guid|
            results = JSON.parse(
                IO.read(
                    getCacheFileName(guid)
                )
            );

            if !results.empty?
                if (results["live"] === true)
                    @published.add(guid);
                end

                if (results["status"] === 'In progress')
                    @progress.add(guid);
                end
            end
        };
    end

    def getPublishedDocuments()
        @published;
    end

    def getInProgressDocuments()
        @progress;
    end
end
