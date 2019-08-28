require 'lib/file-finder'

describe 'File Finder' do
    it 'should find all matching files within a directory' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/live/*.xml',
            './spec/fixtures/file-finder/processed/*',
            './spec/fixtures/file-finder/.cache/*.json',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results).to match_array([
            {
                :source => "./spec/fixtures/file-finder/live/00a710e9-4106-567c-856d-36e36f321c70.xml",
                :target => "./spec/fixtures/file-finder/processed/00a710e9-4106-567c-856d-36e36f321c70.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/00a710e9-4106-567c-856d-36e36f321c70.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :target => "./spec/fixtures/file-finder/processed/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0a735b6a-a672-455e-9cff-05823f5685a7.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0ae317ec-c561-5649-a707-f6732bd37d00.xml",
                :target => "./spec/fixtures/file-finder/processed/0ae317ec-c561-5649-a707-f6732bd37d00.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0ae317ec-c561-5649-a707-f6732bd37d00.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0b2c57a5-497a-52d2-b741-4107f1ed6811.xml",
                :target => "./spec/fixtures/file-finder/processed/0b2c57a5-497a-52d2-b741-4107f1ed6811.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0b2c57a5-497a-52d2-b741-4107f1ed6811.json",
            },
    ])
    end

    it 'should find all matching files within mutiple directories' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/**/*',
            './spec/fixtures/file-finder/processed/*',
            './spec/fixtures/file-finder/.cache/*',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results).to match_array([
            {
                :source => "./spec/fixtures/file-finder/in-progress/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :target => "./spec/fixtures/file-finder/processed/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0a735b6a-a672-455e-9cff-05823f5685a7.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/00a710e9-4106-567c-856d-36e36f321c70.xml",
                :target => "./spec/fixtures/file-finder/processed/00a710e9-4106-567c-856d-36e36f321c70.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/00a710e9-4106-567c-856d-36e36f321c70.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :target => "./spec/fixtures/file-finder/processed/0a735b6a-a672-455e-9cff-05823f5685a7.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0a735b6a-a672-455e-9cff-05823f5685a7.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0ae317ec-c561-5649-a707-f6732bd37d00.xml",
                :target => "./spec/fixtures/file-finder/processed/0ae317ec-c561-5649-a707-f6732bd37d00.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0ae317ec-c561-5649-a707-f6732bd37d00.json",
            },
            {
                :source => "./spec/fixtures/file-finder/in-progress/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml",
                :target => "./spec/fixtures/file-finder/processed/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.json",
            },
            {
                :source => "./spec/fixtures/file-finder/live/0b2c57a5-497a-52d2-b741-4107f1ed6811.xml",
                :target => "./spec/fixtures/file-finder/processed/0b2c57a5-497a-52d2-b741-4107f1ed6811.xml",
                :metadata => "./spec/fixtures/file-finder/.cache/0b2c57a5-497a-52d2-b741-4107f1ed6811.json",
            },
        ])
    end

    it 'should ignore any filetypes that do not match the source specified' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/**/*.xml',
            '',
            './spec/fixtures/file-finder/.cache/*',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(6)
    end

    it 'should abort if the specified directory does not exist' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/foo/*.xml',
            '',
            './spec/fixtures/file-finder/.cache/*',
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
            './spec/fixtures/file-finder/.cache/',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results.count).to eq(1)
    end

    it 'should raise an exception if the specified source file does not exist' do
        documents = FileFinder.new(
            './spec/fixtures/file-finder/live/bar.xml',
            '',
            './spec/fixtures/file-finder/.cache/*',
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
        @expectedMetaFile = "./spec/fixtures/file-finder/.cache/#{@guid}.json"

        expectedFileDetails = {
            :source => @expectedSource,
            :target => @expectedTarget,
            :metadata => @expectedMetaFile
        }

        documents = FileFinder.new(
            @expectedSource,
            @expectedTarget,
            @expectedMetaFile,
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results[0]).to eq(expectedFileDetails)
    end

    it 'should return details of all matching files' do
        expectedResults = [{
            :source => './spec/fixtures/file-finder/in-progress/0a735b6a-a672-455e-9cff-05823f5685a7.xml',
            :target => './spec/fixtures/file-finder/output/0a735b6a-a672-455e-9cff-05823f5685a7.xml',
            :metadata => './spec/fixtures/file-finder/.cache/0a735b6a-a672-455e-9cff-05823f5685a7.json'
        },
        {
            :source => './spec/fixtures/file-finder/in-progress/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml',
            :target => './spec/fixtures/file-finder/output/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.xml',
            :metadata => './spec/fixtures/file-finder/.cache/0be088bf-7f2f-5e96-9153-9bdc0e1a7764.json'
        }]

        documents = FileFinder.new(
            './spec/fixtures/file-finder/in-progress/*.xml',
            './spec/fixtures/file-finder/output/*',
            './spec/fixtures/file-finder/.cache/*.json',
            Logger.new(nil)
        )
        documents.process()

        expect(documents.results).to eq(expectedResults)
    end
end

