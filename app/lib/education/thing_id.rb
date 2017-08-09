#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'logger';

class ThingId
    # Parse a number of documents, and extract out the Topic Of Study Ids
    # Call Thing Id Endpoint and cache responses against Topic Of Study Ids
    # Parse the XML and add Thing Ids
    def parseXmlForTopicOfStudyIds(source, xPathExpression, thingIdXPath)
        @topicOfStudyIdXPath = xPathExpression;
        @thingIdXPath = thingIdXPath;

        #
        log_file="#{Settings.log}/thing-id-errors.log"
        File.delete(log_file) if File.exist?(log_file)
        @LOG = Logger.new(log_file);

        puts
        puts "Associating Topics of Study with a Thing Id..."
        puts "================================================="

        topicofStudyIds = extractTopicOfStudyIds(source);
        setThingId(topicofStudyIds);
    end

    def cacheThingIds(topicOfStudyIds)
        # Multiple documents will share the same Topic Of Study Id, but only
        # need to retrieve Thing Id once per ToS Id so remove all duplicates.
        # Also remove empty matches (where ToS Id has not been added)
        uniqueIds = topicOfStudyIds.uniq.reject{ |e| e.empty? }
        puts "    => #{uniqueIds.length.to_s} Topic(s) of Study identified";

        # Identify any Topics Of Study that have not been cached locally
        nonCachedTopics = getNonCachedTopics(uniqueIds);

        # Fetch the Thing ids for the Topics Of Study that are not been cached
        # (thereby adding successful requests to the cache)
        if nonCachedTopics.length >= 1
            fetchThingIds(nonCachedTopics);
        end
    end

    def updateXML(source, destination)
        puts
        puts "Updating XML with Thing Id..."
        puts "================================================="

        updatedCount = 0;
        skippedCount = 0;

        Dir.glob(source) do |sourceFile|
            guid = File.basename(sourceFile, '.xml');

            xh = XmlHandler.new
            xh.init(IO.read(sourceFile));

            topicOfStudyId = xh.getXPathText(@topicOfStudyIdXPath);

            cacheFile = "#{Settings.cache}/thing-id/#{topicOfStudyId}";
            if File.file? cacheFile
                thingId = IO.read(cacheFile);

                xh.updateContent(@thingIdXPath, thingId.strip);

                updatedCount += 1;
            else
                skippedCount += 1;
            end

            destinationPath = destination.gsub(':guid', guid);

            fh = FileHandler.new
            fh.create(destinationPath, xh.asString());
        end

        puts "    => #{updatedCount.to_s} document(s) successfully updated";
        puts "    => #{skippedCount.to_s} document(s) were not updated";
    end

    private # all methods that follow will be made private
    def extractTopicOfStudyIds(sourceDirectory)
        topicOfStudyIds = Array.new;

        Dir.glob(sourceDirectory) do |sourceFile|
            xh = XmlHandler.new
            xh.init(IO.read(sourceFile));

            topicOfStudyIds << xh.getXPathText(@topicOfStudyIdXPath);
        end

        topicOfStudyIds;
    end

    def getNonCachedTopics(uniqueIds)
        nonCached = uniqueIds.select {|zedId|
            !File.file? getCacheFileName(zedId)
        }
    end

    def getCacheFileName(zedId)
        "#{Settings.cache}/thing-id/#{zedId}";
    end

    def fetchThingIds(topicOfStudyIds)
        baseURI = URI.parse(Settings.thingIdURL);

        queue = Queue.new;
        topicOfStudyIds.map { |topicOfStudyId| queue << topicOfStudyId }

        failureCount = 0;

        threads = Settings.threads.times.map do
            Thread.new do
                # prepare the request
                Net::HTTP.start(
                    baseURI.host,
                    baseURI.port,
                    :use_ssl => true,
                    :cert => OpenSSL::X509::Certificate.new(Settings.pemFile),
                    :key => OpenSSL::PKey::RSA.new(Settings.pemFile),
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && zedId = queue.pop
                        thingId = '';

                        response = http.request_post(
                            baseURI.request_uri,
                            "<topic-of-study><id>#{zedId}</id></topic-of-study>",
                            {'Content-Type' => 'application/xml'}
                        );

                        if response.code === '200'
                            doc = Nokogiri.XML(response.body);
                            thingId = doc.xpath("//thing-id/text()");
                        else
                            @LOG.error "No Thing Id found for Topic of Study: #{zedId}, encountered a #{response.code.to_s} response"
                        end

                        if thingId.empty?
                            failureCount += 1;
                        else
                            fh = FileHandler.new
                            fh.create(getCacheFileName(zedId), thingId);
                        end
                    end
                end
            end
        end

        threads.each(&:join);

        puts "    => #{failureCount.to_s} Topic(s) of Study didn't return a Thing Id";
    end
end
