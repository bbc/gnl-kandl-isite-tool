require 'lib/file-finder'

describe 'File Finder' do
    it 'should find all matching files within a directory' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/live/*',
            '',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(4)
    end

    it 'should find all matching files within mutiple directories' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/**/*',
            '',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(7)
    end

    it 'should ignore any filetypes that do not match the source specified' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/**/*.xml',
            '',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(6)
    end

    it 'should abort if the specified directory does not exist' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/foo/*.xml',
            '',
            Logger.new(nil)
        )

        expect {
            documents.process()
        }.to raise_error(ArgumentError)
    end

    it 'should be able to accept a single file as the source' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/live/0ae317ec-c561-5649-a707-f6732bd37d00.xml',
            '',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(1)
    end

    it 'should raise an exception if the specified source file does not exist' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/live/bar.xml',
            '',
            Logger.new(nil)
        )

        expect {
            documents.process()
        }.to raise_error(ArgumentError)
    end

    it 'should return details of a particular file' do
        @guid = '00a710e9-4106-567c-856d-36e36f321c70'
        @expectedSource = "./spec/fixtures/file-finder/live/#{@guid}.xml"
        @expectedTarget = "./spec/fixtures/file-finder/example/#{@guid}.xml"

        expectedFileDetails = {
            :source => @expectedSource,
            :target => @expectedTarget
        }

        documents = FileFinder.new(
            @expectedSource,
            @expectedTarget,
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results[0]).to eq(expectedFileDetails)
    end

    it 'should return details of all matching files' do
        expectedResults = [{
            :source => './spec/fixtures/file-finder/in-progress/0a735b6a-a672-455e-9cff-05823f5685a7.xml',
            :target => './spec/fixtures/file-finder/output/0a735b6a-a672-455e-9cff-05823f5685a7.xml'
        },
        {
            :source => './spec/fixtures/file-finder/in-progress/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml',
            :target => './spec/fixtures/file-finder/output/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml'
        }]

        documents = FileFinder.new(
            './spec/fixtures/file-finder/in-progress/*.xml',
            './spec/fixtures/file-finder/output/*',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results).to eq(expectedResults)
    end
end

