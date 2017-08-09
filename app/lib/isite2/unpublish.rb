#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';

require_relative '../file-handler'

class ISiteAPI
    def unpublish(guids)
        createJSON(guids);
        unpublishDocuments();
    end

    def createJSON(guids)
        puts "#{guids.length} documents to be un-published";
        batches = guids.each_slice(100)

        batchTotal = batches.count;
        batchCount = 0;

        batches.each { |batch|
            batchCount += 1;

            jsonData = {
                :description => "Unpublishing documents prior to deleting them",
                :documents => []
            };

            batch.each { |guid|
                # Open the metadata file
                # JSON.parse(IO.read(cacheFile));
                metadataJSON = JSON.parse(IO.read("#{Settings.cache}/metadata/#{guid}.json"));

                # Determine which version is published
                if metadataJSON['publishedVersion'].to_s.nil? || metadataJSON['publishedVersion'].to_s.empty?
                    # There is no published version so do nothing
                else
                    jsonData[:documents] << {
                        :id => metadataJSON['id'],
                        :version => metadataJSON['publishedVersion']
                    }
                end
            }

            fh = FileHandler.new
            fh.create("#{Settings.cache}/published-version/batch#{batchCount}.json", JSON.pretty_generate(jsonData));
        }
    end

    def unpublishDocuments()
        baseURI = URI.parse(Settings.unPublishURL);

        Net::HTTP.start(
            baseURI.host,
            baseURI.port,
            :use_ssl => true,
            :cert => OpenSSL::X509::Certificate.new(Settings.pemFile),
            :key => OpenSSL::PKey::RSA.new(Settings.pemFile),
            :verify_mode => OpenSSL::SSL::VERIFY_NONE
        ) do |http|
            batchTotal = Dir["#{Settings.cache}/published-version/*.json"].length
            batchCount = 0;

            Dir.glob("#{Settings.cache}/published-version/*.json") do |jsonFile|
                batchCount += 1;

                unpublishJSON = JSON.parse(IO.read(jsonFile));

                # make the actual request
                response = http.send_request(
                    'PUT',
                    baseURI.request_uri,
                    JSON.pretty_generate(unpublishJSON),
                    {'Content-Type' =>'application/json'}
                );

                puts "Unpublishing batch number #{batchCount} of #{batchTotal}";
                if response.code === '200'
                    # responseJSON = JSON.parse(response.body);
                    puts " => Success";
                else
                    #puts JSON.generate(json).to_s
                    #puts response.body
                    puts " => Error, response code #{response.code}."
                end
            end
        end
    end

    def delete(guids)
        puts "DELETE"

        baseURI = URI.parse(Settings.latestContentURL);

        queue = Queue.new
        guids.map { |guid| queue << guid }

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
                    while !queue.empty? && guid = queue.pop

                        deleteURI = baseURI.request_uri.gsub(':guid', guid);
                        permDeleteURI = "#{deleteURI}?permanent=true";

                        # make the request
                        response = http.send_request('DELETE', deleteURI);

                        if response.code === '200'
                            puts " => Success. Deleted #{guid}.";
                            permResponse = http.send_request('DELETE', permDeleteURI);

                            if permResponse.code === '200'
                                puts " => Success. Permanently deleted #{guid}.";
                                http.send_request('DELETE', permDeleteURI);
                            else
                                puts "Unable to permanently delete #{guid}";
                            end
                        else
                            puts "Unable to delete #{guid}";
                        end
                    end
                end
            end
        end

        threads.each(&:join)
    end
end
