#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'set';

require_relative '../file-handler'

# WARNING
# Be really sure that you want to delete files from iSite before calling this.
# The use case for this class is that you're moving documents from one
# environment to another and you need to clean the target environment first.
class DeleteContent
    def initialize(guids)
        @deleteGUIDs = guids;
    end

    def delete()
        puts "Preparing to delete documents..."
        puts "================================================="
        puts " => #{@deleteGUIDs.length.to_s} document(s) marked for deletion"

        baseURI = URI.parse(Settings.latestContentURL);

        successCount = 0;
        failureCount = 0;

        queue = Queue.new
        @deleteGUIDs.map { |guid| queue << guid }

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
                    :cert => OpenSSL::X509::Certificate.new(Settings.pemFile),
                    :key => OpenSSL::PKey::RSA.new(Settings.pemFile),
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && guid = queue.pop
                        deleteURI = baseURI.request_uri.gsub(':guid', guid);

                        # make the request
                        response = http.send_request('DELETE', deleteURI);

                        if response.code === '200'
                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/deleted/#{guid}.json",
                                response.body
                            );

                            successCount += 1;
                        else
                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/deleted-error/#{guid}.json",
                                response.body
                            );

                            failureCount += 1;
                        end
                    end
                end
            end
        end

        threads.each(&:join);

        puts "    => #{successCount.to_s} document(s) successfully deleted";
        puts "    => #{failureCount.to_s} document(s) were not deleted";
    end

    def permanent()
        puts "Preparing to permanently delete documents..."
        puts "================================================="
        puts " => #{@deleteGUIDs.length.to_s} document(s) marked for deletion"

        baseURI = URI.parse(Settings.deletePermanentlyURL);

        successCount = 0;
        failureCount = 0;

        queue = Queue.new
        @deleteGUIDs.map { |guid| queue << guid }

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
                    :cert => OpenSSL::X509::Certificate.new(Settings.pemFile),
                    :key => OpenSSL::PKey::RSA.new(Settings.pemFile),
                    :verify_mode => OpenSSL::SSL::VERIFY_NONE
                ) do |http|
                    while !queue.empty? && guid = queue.pop
                        deleteURI = baseURI.request_uri.gsub(':guid', guid);

                        # make the request
                        response = http.send_request('DELETE', deleteURI);

                        if response.code === '200'
                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/permanent/#{guid}.json",
                                response.body
                            );

                            successCount += 1;
                        else
                            fh = FileHandler.new;
                            fh.create(
                                "#{Settings.cache}/permanent-error/#{guid}.json",
                                response.body
                            );

                            failureCount += 1;
                        end
                    end
                end
            end
        end

        threads.each(&:join);

        puts "    => #{successCount.to_s} document(s) successfully deleted";
        puts "    => #{failureCount.to_s} document(s) were not deleted";
    end
end
