#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';

class ListContent

    def initialize()
        puts
        puts "Querying iSite2 for list of document(s)...";
        puts "================================================="

        @cacheFile = "#{Settings.cache}/lightweight-list.json";

        if not File.file? @cacheFile
            # There's no local cache file so create the
            # file by querying iSite2 and saving the result
            cacheResults();
        end
    end

    def cacheResults()
        baseURI = URI.parse(Settings.lightweightListURL);

        # create the request
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
            # make the actual request
            response = http.request_get(baseURI.request_uri);

            if response.code === '200'
                results = JSON.parse(response.body);

                fh = FileHandler.new
                fh.create(@cacheFile, JSON.pretty_generate(results));
            end
        end
    end

    def extractGUIDs()
        guids = Array.new;

        results = JSON.parse(IO.read(@cacheFile));

        results["docs"].each do |doc|
            if doc["type"] === Settings.filetype && doc["deleted"] === false
                guids << doc["id"];
            end
        end

        puts " => #{guids.length.to_s} #{Settings.filetype} documents found"
        puts

        guids;
    end
end
