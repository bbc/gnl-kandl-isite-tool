require 'fileutils'
require 'logger'
require 'lib/xml-handler'

describe 'XML Handler' do
    it 'should successfully load the XML file' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')

        expect(handler.save()).to eq("<?xml version=\"1.0\"?>\n<foo>bar</foo>")
    end

    it 'should abort if the XML file does not exist' do
        handler = XmlHandler.new

        expect {
            handler.read('./spec/fixtures/xml-handler/missing.xml')
        }.to raise_error(SystemExit)
    end

    it 'should successfully transform the XML using the supplied XSL' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')
        handler.transform('./spec/fixtures/xml-handler/valid.xsl')

        expect(handler.save()).to eq("<?xml version=\"1.0\"?>\n<boo>bar</boo>")
    end

    it 'should abort if the XSL file does not exist' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')

        expect {
            handler.transform('./spec/fixtures/xml-handler/missing.xsl')
        }.to raise_error(SystemExit)
    end

    it 'should validate the XML using the supplied XSD' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')
        handler.validate('./spec/fixtures/xml-handler/valid.xsd')

        expect(handler.save()).to eq("<?xml version=\"1.0\"?>\n<foo>bar</foo>")
    end

    it 'should abort if the XSD file does not exist' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')

        expect {
            handler.validate('./spec/fixtures/xml-handler/missing.xsd')
        }.to raise_error(SystemExit)
    end

    it 'should detail all errors encountered when validating the XML' do
        logDirectory = './spec/temp'
        FileUtils.mkdir_p(logDirectory) unless File.exists?(logDirectory)
        logFile = "#{logDirectory}/transform.log"

        log = Logger.new(logFile)
        log.formatter = proc do |severity, datetime, progname, msg|
            date_format = datetime.strftime("%Y-%m-%d %H:%M:%S")
            "[#{date_format}] #{severity} #{msg}\n"
        end

        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')
        handler.transform('./spec/fixtures/xml-handler/invalid.xsl')
        handler.validate('./spec/fixtures/xml-handler/valid.xsd')
        handler.logErrors(log, 'Rspec Test')

        # Close the logger so that it can be cleaned up
        log.close

        # Ensure the log file is created
        expect(File).to exist(logFile)

        # Also ensure the contents are as expected
        expect(IO.read(logFile)).to include("Element 'boo': 'bar-none' is not a valid value")
    end

    it 'should still output the transformed XML if it fails the validation' do
        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/invalid.xml')
        handler.validate('./spec/fixtures/xml-handler/valid.xsd')

        expect(handler.save()).to eq("<?xml version=\"1.0\"?>\n<foo>bar-none</foo>")
    end

    it 'should be able to save the resultant XML out to a file' do
        outputFile = './spec/fixtures/temp/new-file.xml'

        handler = XmlHandler.new
        handler.read('./spec/fixtures/xml-handler/source.xml')
        handler.transform('./spec/fixtures/xml-handler/valid.xsl')
        handler.saveAsFile(outputFile)

        # Ensure the file itself is created
        expect(File).to exist(outputFile)

        # Also ensure the contents are as expected
        expect(IO.read(outputFile)).to eq "<?xml version=\"1.0\"?>\n<boo>bar</boo>"
    end
end
