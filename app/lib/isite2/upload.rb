#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'set';

require_relative '../file-handler'

class UploadContent

    def process(directory)
        files = Array.new

        Dir.glob("#{directory}") do |filename|
            files << filename
        end

        puts "Preparing to upload documents..."
        puts "================================================="
        puts " => #{files.length.to_s} document(s) to be uploaded"

        # Divide the files up into smaller groups to allow for more control of
        # the upload and ensure that the upload is staggered, rather than
        # hammering the API
        filesPerGroup = 400;
        groups = files.each_slice(filesPerGroup)

        groupCount = 0;

        groups.each { |group|
            groupCount += 1;

            # Process this batch of files
            groupStart = ((groupCount-1)*filesPerGroup) + 1;
            groupEnd = (groupStart - 1) + group.length;

            puts " => uploading documents #{groupStart}-#{groupEnd} of #{files.length.to_s}"
            send(group);

            # Avoid spamming iSite with hundreds file files without a break
            sleep(3);
        }

        puts
    end

    private
    def send(files)
        baseURI = URI.parse(Settings.latestContentURL);

        successCount = 0;
        failureCount = 0;

        queue = Queue.new
        files.map { |filename| queue << filename }

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
                    while !queue.empty? && filename = queue.pop
                        guid = File.basename(filename, '.xml');

                        fileContents = IO.read(filename);

                        if File.file? "#{Settings.cache}/metadata/#{guid}.json"
                            action = 'PUT'
                        else
                            action = 'POST'
                        end

                        # try to upload the file
                        response = http.send_request(
                            action,
                            baseURI.request_uri.gsub(':guid', guid),
                            fileContents
                        );

                        if action === 'POST' && response.code === '201'
                            successCount += 1;

                            results = JSON.parse(response.body);

                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/upload/#{guid}.json",
                                JSON.pretty_generate(results)
                            );
                        elsif response.code === '200'
                            successCount += 1;

                            results = JSON.parse(response.body);

                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/upload/#{guid}.json",
                                JSON.pretty_generate(results)
                            );
                        else
                            failureCount += 1;

                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/upload-error/#{guid}.json",
                                response.body
                            );
                        end
                    end
                end
            end
        end

        threads.each(&:join);

        puts "    => #{successCount.to_s} document(s) were uploaded";
        if failureCount > 0
            puts "    => #{failureCount.to_s} document(s) failed to upload";
        end
    end
end
