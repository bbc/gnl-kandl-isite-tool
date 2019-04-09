#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'net/http';
require 'json';
require 'logger';
require 'thread'  # for Mutex


# Currently the lightweight-list endpoint is broken because of the number
# of files within the education project, so this class now uses paginated
# results from the content-reader API to determine which files to reference.
class ListContent
    def initialize()
        @pageSize = 40
        @totalResults = 0;
        @guids = []

        puts "Build lightweight-list data file...";
        puts "================================================="

        @sslCert = OpenSSL::X509::Certificate.new(Settings.pemFile)
        @sslKey = OpenSSL::PKey::RSA.new(Settings.pemFile)

        fetchPage(getApiURL(1), true);

        numberOfPages = (@totalResults/@pageSize).ceil

        if numberOfPages > 1
            urls = []

            2.upto(numberOfPages){ |i|
                urls << getApiURL(i)
            }

            fastFetch(urls)
        end

        puts " => #{@totalResults.to_i} #{Settings.filetype} documents are listed"
        puts " => #{@guids.length} GUIDs have been extracted"
        puts
    end

    def getApiURL(page)
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-content-reader/content/type?allowNonLive=true&project=%s&type=%s&page=%s&pageSize=%s',
            Settings.environment,
            Settings.project,
            Settings.filetype,
            page,
            @pageSize
        );
    end

    def fastFetch(urls)
        mutex = Mutex.new

        Settings.threads.times.map {
            Thread.new(urls) do |urls|
                while url = mutex.synchronize { urls.pop }
                    fetchPage(url, false)
                end
            end
        }.each(&:join)
    end

    def fetchPage(url, setTotal)
        baseURI = URI.parse(url);

        Net::HTTP.start(
            baseURI.host,
            baseURI.port,
            :use_ssl => true,
            :cert => @sslCert,
            :key => @sslKey,
            :verify_mode => OpenSSL::SSL::VERIFY_NONE
        ) do |http|
            request = http.request_get(baseURI.request_uri)

            responseXml = request.body.force_encoding('UTF-8')

            doc = Nokogiri::XML(responseXml)

            if setTotal === true
                @totalResults = doc.at_xpath('/xmlns:search/xmlns:metadata/xmlns:totalResults').content.to_f
            end

            if Settings.lastModifiedSince
                mergeGuids(
                    doc.xpath(sprintf('//r:result/r:metadata[number(translate(substring(child::r:modifiedDateTime, 0, 11), "-", ""))>=%s]/r:guid/text()', Settings.lastModifiedSince), 'r' => 'https://production.bbc.co.uk/isite2/contentreader/xml/result')
                )
            else
                mergeGuids(
                    doc.xpath('//r:result/r:metadata/r:guid/text()', 'r' => 'https://production.bbc.co.uk/isite2/contentreader/xml/result')
                )
            end
        end
    end

    def mergeGuids(guids)
        (@guids << guids).flatten!
    end

    def extractGUIDs()
        @guids
    end
end
