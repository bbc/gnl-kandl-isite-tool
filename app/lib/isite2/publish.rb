#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'set';

require_relative '../file-handler'

class PublishContent

    def initialize(cacheDirectory)
        @guids = Array.new;
        @cache = cacheDirectory;
        @documentsPerPublishJob = 1;
    end

    def useGUIDs(guids)
        @guids = guids;
    end

    def useDirectory(directory)
        Dir.glob("#{directory}/*.xml") do |filename|
            @guids << File.basename(filename, '.xml');
        end
    end

    def start()
        puts "Preparing to publish documents..."
        puts "================================================="
        if @guids.length >= 1
            puts " => #{@guids.length.to_s} document(s) to be published"
            puts
            createPublishJobs();
            sendPublishJobs();
        else
            puts " => 0 documents specified for publishing"
        end

    end

    def createPublishJobs()
        # Each batch of documents to be published should be limited to 50
        # documents as iSite fails if you try to publish more than 50 at once.
        jobs = @guids.each_slice(@documentsPerPublishJob)

        batchTotal = jobs.count;
        batchCount = 0;

        puts " => Preparing #{batchTotal} publish jobs..."

        jobs.each { |batch|
            batchCount += 1;

            jsonData = {
                :description => "Publishing documents that have modified by the K&L Development Team",
                :documents => []
            };

            batch.each { |guid|
                # Open the metadata file
                # JSON.parse(IO.read(cacheFile));
                metadataJSON = JSON.parse(IO.read("#{@cache}/#{guid}.json"));

                # Determine which version is published
                if metadataJSON['version'].to_s.nil? || metadataJSON['version'].to_s.empty?
                    jsonData[:documents] << {
                        :id => metadataJSON['id'],
                        :version => 1
                    }
                else
                    jsonData[:documents] << {
                        :id => metadataJSON['id'],
                        :version => metadataJSON['version']
                    }
                end
            }

            fh = FileHandler.new
            fh.create("#{Settings.cache}/publish/batch#{batchCount}.json", JSON.pretty_generate(jsonData));
        }
    end

    def sendPublishJobs()
        baseURI = URI.parse(Settings.publishURL);

        queue = Queue.new;
        Dir.glob("#{Settings.cache}/publish/*.json") do |file|
            queue << file
        end

        @batchTotal = queue.length
        @batchCount = 0;

        threadCount = 5;

        threads = threadCount.times.map do
            Thread.new do
                # prepare the request
                Net::HTTP::Proxy(
                    Settings.proxyHost,
                    Settings.proxyPort
                ).start(
                    baseURI.host,
                    baseURI.port,
                    :use_ssl => true,
                    :cert => OpenSSL::X509::Certificate.new(Settings.pemFile),
                    :key => OpenSSL::PKey::RSA.new(Settings.pemFile),
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && jsonFile = queue.pop
                        @batchCount += 1;
                        batchFilename = File.basename(jsonFile, '.json');
                        publishJSON = JSON.parse(IO.read(jsonFile));

                        # make the actual request
                        response = http.send_request(
                            'PUT',
                            baseURI.request_uri,
                            JSON.pretty_generate(publishJSON),
                            {'Content-Type' =>'application/json'}
                        );

                        puts " => publishing job: #{@batchCount} of #{@batchTotal}......";
                        if response.code === '200'
                            results = JSON.parse(response.body);

                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/published-success/#{batchFilename}.json",
                                JSON.pretty_generate(results)
                            );

                            FileUtils.rm(jsonFile);
                        else
                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/published-error/#{batchFilename}.log",
                                response.body
                            );

                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/published-error/#{batchFilename}.json",
                                IO.read(jsonFile)
                            );

                            FileUtils.rm(jsonFile);

                            puts "    => Failure";
                        end

                        # We have been asked to rate limit (by the LDP team)
                        # the number of requests to approx 120 requests per minute.
                        # A sleep of 1 second after each request in conjunction with using
                        # 5 threads appears to achieve this
                        sleep(1);
                    end
                end
            end
        end

        threads.each(&:join);
    end
end
