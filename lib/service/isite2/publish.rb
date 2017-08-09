#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
class PublishService
    def initialize(config=nil, console, log)
        @config = config
        @console = console
        @log = log
        @src = nil
        @guids = Array.new
        @successCount = 0
        @failureCount = 0
    end

    def source(src=nil)
        @src = src
    end

    def guids
        @guids
    end

    def start()
        @console.info "Find documents to publish..."
        @console.info "================================================="

        if !Dir.glob(@src).empty?
            Dir.glob(@src) do |filename|
                @guids << File.basename(filename, '.xml')
            end
        elsif File.file?(@src)
            @guids << File.basename(@src, '.xml')
        else
            abort(" => Unable to find specified source: #{@src}")
        end

        # Provide some feedback to the user in case the number don't
        # match what they expect
        if @guids.length == 1
            @console.info " => #{@guids.length.to_s} document to be published"
        else
            @console.info " => #{@guids.length.to_s} documents to be published"
        end
    end

    def prepareRequests()
        mutex = Mutex.new

        threadCount = 5 # Settings.threads

        @successCount = 0
        @failureCount = 0

        threadCount.times.map {
            Thread.new(@guids) do |guids|
                while guid = mutex.synchronize { guids.pop }
                    publishDocument(guid)
                end
            end
        }.each(&:join)

        @console.info "    => #{@successCount.to_s} document(s) successfully published"
        @console.info "    => #{@failureCount.to_s} document(s) were not published"
    end

    def publishDocument(guid)
        baseURI = URI.parse(@config.publishURL)

        connection = Net::HTTP.new(baseURI.host, baseURI.port)
        connection.use_ssl = true

        unless Settings.pemFile.nil?
            connection.cert = OpenSSL::X509::Certificate.new(Settings.pemFile)
            connection.key = OpenSSL::PKey::RSA.new(Settings.pemFile)
            connection.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end

        connection.start do |http|
            # the publish api expects to be passed json
            # detailing the file(s) to be published
            version = getDocumentVersion(guid)

            publishData = getPublishData(guid, version)

            # make the actual request
            response = http.send_request(
                'PUT',
                baseURI.request_uri,
                publishData.to_s,
                {'Content-Type' =>'application/json'}
            )

            if response.code === '200'
                @successCount += 1

                @log.info "Published guid: #{guid}, version: #{version}"
            else
                @failureCount += 1

                @log.info "Failed to publish guid: #{guid}, version: #{version}, HTTP Response => #{response.code}"
            end

            # We have been asked (by the LDP team) to rate limit
            # the number of requests to approx 120 requests per minute.
            # A sleep of 1 second after each request in conjunction with using
            # 5 threads appears to achieve this
            sleep(1)
        end
    end

    def getDocumentVersion(guid)
        # Assume that it's a new file to start with,
        # so set its version number to one.
        version = 1

        # The iSite2 metadata file contains a heap of information about the document
        # such as its status and version history
        metadataFile = "#{@config.cache}/upload/#{guid}.json"

        # If the metadata file exists then the document exists in iSite2
        # and the version information should be extracted from the metadata file
        if File.exists? metadataFile
            metadataJSON = JSON.parse(IO.read(metadataFile))

            if !metadataJSON['version'].to_s.nil? && !metadataJSON['version'].to_s.empty?
                version = metadataJSON['version']
            end
        end

        version
    end

    def getPublishData(guid, version)
        {
            :description => "Published by the Education Development Team as part of a data migration task",
            :documents => [{
                :id => guid,
                :version => getDocumentVersion(guid)
            }]
        }
    end
end
