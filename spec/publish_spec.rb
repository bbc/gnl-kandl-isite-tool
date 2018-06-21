require 'json'
require 'logger'

require 'lib/service/isite2/publish.rb'

module Settings
    @environment = nil

    def self.cache
        return "spec/fixtures/.cache"
    end

    def self.publishURL
        return 'https://api.other.bbc.co.uk/isite2-api/project/name/content/publish'
    end

    def self.pemFile
        @pemFile = nil
    end
end

describe 'Publishing in iSite2 via the API:' do
    it 'can be initiated' do
        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))

        expect(ps.guids).to match_array([])
    end

    it 'can use a single file as the source' do
        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))
        ps.source('spec/fixtures/upload/public/00460ae7-468e-509e-ab0e-3973da02e9cd.xml')
        ps.start()

        expect(ps.guids).to match_array(['00460ae7-468e-509e-ab0e-3973da02e9cd'])
    end

    it 'displays a warning if source file can not be found' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source('spec/fixtures/upload/public/_00460ae7-468e-509e-ab0e-3973da02e9cd.xml')

        expect {
            ps.start()
        }.to output(/WARNING: Unable to find specified source/).to_stdout_from_any_process
    end

    it 'can process all the files within a directory' do
        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))
        ps.source('spec/fixtures/upload/public/*.xml')
        ps.start()

        expect(ps.guids).to match_array([
            '0ed7cf93-acf7-4081-88ff-27ffe10ffc6c',
            '0f5782e6-5f32-4107-ac87-32aaeabd8967',
            '00460ae7-468e-509e-ab0e-3973da02e9cd'
        ])
    end

    it 'can process all the files within all sub-directories' do
        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))
        ps.source('spec/fixtures/upload/**/*.xml')
        ps.start()

        expect(ps.guids).to match_array([
            '0ed7cf93-acf7-4081-88ff-27ffe10ffc6c',
            '0f5782e6-5f32-4107-ac87-32aaeabd8967',
            '00460ae7-468e-509e-ab0e-3973da02e9cd',
            '670d0409-0219-5d54-8e20-efa81d250549'
        ])
    end

    it 'displays a warning if source directory can not be found' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source('spec/fixtures/upload/live/*.xml')

        expect {
            ps.start()
        }.to output(/WARNING: Unable to find specified source/).to_stdout_from_any_process
    end

    it 'informs the user how when there is a single document to be published' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source('spec/fixtures/upload/public/00460ae7-468e-509e-ab0e-3973da02e9cd.xml')

        expect {
            ps.start()
        }.to output(/1 document to be published/).to_stdout_from_any_process
    end

    it 'informs the user when there are multiple documents to be published' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source('spec/fixtures/upload/public/*.xml')

        expect {
            ps.start()
        }.to output(/3 documents to be published/).to_stdout_from_any_process
    end

    it 'creates valid JSON for a new file to pass with the publish request' do
        guid = '00460ae7-468e-509e-ab0e-3973da02e9cd'
        expected = {
            :description => "Published by the Education Development Team as part of a data migration task",
            :documents => [{
                :id => guid,
                :version => 1
            }]
        }

        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))
        version = ps.getDocumentVersion(guid)
        actual = ps.getPublishData(guid, version)

        expect(actual).to eq expected
    end

    it 'creates valid JSON for an existing file to pass with the publish request' do
        guid = '0ed7cf93-acf7-4081-88ff-27ffe10ffc6c'
        expected = {
            :description => "Published by the Education Development Team as part of a data migration task",
            :documents => [{
                :id => guid,
                :version => 12
            }]
        }

        ps = PublishService.new(Settings, Logger.new(nil), Logger.new(nil))
        version = ps.getDocumentVersion(guid)
        actual = ps.getPublishData(guid, version)

        expect(actual).to eq expected
    end

    it 'increments the success count when a document is successfully published' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        guid = '0ed7cf93-acf7-4081-88ff-27ffe10ffc6c'
        version = 12

        stub_request(:put, 'https://api.other.bbc.co.uk/isite2-api/project/name/content/publish')
            .with(:body => mockJson(guid, version).to_json, :headers => {'Content-Type'=>'application/json'})
            .to_return(:status => 200, :body => "", :headers => {})

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source("spec/fixtures/upload/public/#{guid}.xml")
        ps.start()

        expect {
            ps.prepareRequests()
        }.to output(/1 document\(s\) successfully published/).to_stdout_from_any_process
    end

    it 'increments the failure count when a document fails to publish' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        guid = '0ed7cf93-acf7-4081-88ff-27ffe10ffc6c'
        version = 12

        stub_request(:put, 'https://api.other.bbc.co.uk/isite2-api/project/name/content/publish')
            .with(:body => mockJson(guid, version).to_json, :headers => {'Content-Type'=>'application/json'})
            .to_return(:status => 500, :body => "", :headers => {})

        ps = PublishService.new(Settings, console, Logger.new(nil))
        ps.source("spec/fixtures/upload/public/#{guid}.xml")
        ps.start()

        expect {
            ps.prepareRequests()
        }.to output(/1 document failed to publish/).to_stdout_from_any_process
    end

    def mockJson(guid, version)
        expected = {
            :description => "Published by the Education Development Team as part of a data migration task",
            :documents => [{
                :id => guid,
                :version => version
            }]
        }
    end
end
