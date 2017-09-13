require 'lib/content-transformer'

describe 'Transform Content' do
    it 'should feedback on the number of documents processed' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document(s) were transformed"\
                         "\n    => 1 document(s) passed validation"\
                         "\n    => 0 document(s) failed validation\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml'
        }];

        config = {};
        config[:xsl] = './spec/fixtures/xml-handler/valid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', console);
        expect {
            transformations.process();
        }.to output(expectedOutput).to_stdout_from_any_process;
    end

    it 'should feedback on the number of documents that failed validation' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document(s) were transformed"\
                         "\n    => 0 document(s) passed validation"\
                         "\n    => 1 document(s) failed validation"\
                         "\n      => ./data/local-environment/some-type/.logs/transforms.log has more detailed information.\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml'
        }];

        config = {};
        config[:environment] = 'local';
        config[:filetype] = 'some-type';
        config[:xsl] = './spec/fixtures/xml-handler/invalid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', console);
        expect {
            transformations.process();
        }.to output(expectedOutput).to_stdout_from_any_process;
    end

    it 'should not output any feedback to console if the silent flag is used' do
        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document(s) were transformed"\
                         "\n    => 0 document(s) passed validation"\
                         "\n    => 1 document(s) failed validation"\
                         "\n      => ./data/-environment//.logs/transforms.log has more detailed information.\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml'
        }];

        config = {};
        config[:xsl] = './spec/fixtures/xml-handler/valid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', Logger.new(nil));
        expect {
            transformations.process();
        }.to_not output.to_stdout;
    end
end
