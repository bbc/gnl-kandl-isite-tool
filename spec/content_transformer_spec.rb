require 'lib/content-transformer'

describe 'Transform Content' do
    it 'should feedback on the number of documents processed' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document transformed"\
                         "\n    => 0 documents passed validation before transformation"\
                         "\n    => 1 document failed validation before transformation"\
                         "\n\e[32m    => 1 document passed validation after transformation\e[0m\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml',
            :metadata => './spec/fixtures/.cache/metadata/0ed7cf93-acf7-4081-88ff-27ffe10ffc6c.json'
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
                         "\n => 1 document transformed"\
                         "\n    => 0 documents passed validation before transformation"\
                         "\n    => 1 document failed validation before transformation"\
                         "\n\e[32m    => 0 documents passed validation after transformation\e[0m"\
                         "\n\e[31m    => 1 document failed validation after transformation\e[0m"\
                         "\n      => ./data/local-environment/projectName/some-type/.logs/transforms.log has more detailed information.\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml',
            :metadata => './spec/fixtures/.cache/metadata/0ed7cf93-acf7-4081-88ff-27ffe10ffc6c.json'
        }];

        config = {};
        config[:project] = 'projectName';
        config[:environment] = 'local';
        config[:filetype] = 'some-type';
        config[:xsl] = './spec/fixtures/xml-handler/invalid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', console);
        expect {
            transformations.process();
        }.to output(expectedOutput).to_stdout_from_any_process;
    end

    it 'should ignore a missing metadata file' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document transformed"\
                         "\n    => 0 documents passed validation before transformation"\
                         "\n    => 1 document failed validation before transformation"\
                         "\n\e[32m    => 0 documents passed validation after transformation\e[0m"\
                         "\n\e[31m    => 1 document failed validation after transformation\e[0m"\
                         "\n      => ./data/local-environment/projectName/some-type/.logs/transforms.log has more detailed information.\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml',
            :metadata => './spec/fixtures/.cache/metadata/i-do-not-exist.json'
        }];

        config = {};
        config[:project] = 'projectName';
        config[:environment] = 'local';
        config[:filetype] = 'some-type';
        config[:xsl] = './spec/fixtures/xml-handler/invalid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', console);
        expect {
            transformations.process();
        }.to output(expectedOutput).to_stdout_from_any_process;
    end

    it 'should report the number of documents that were valid before transformation' do
        console = Logger.new(STDOUT)
        console.formatter = proc do |severity, datetime, progname, msg|
            "#{msg}\n"
        end

        expectedOutput = "Transforming documents..."\
                         "\n================================================="\
                         "\n => 1 document transformed"\
                         "\n    => 1 document passed validation before transformation"\
                         "\n    => 0 documents failed validation before transformation"\
                         "\n\e[32m    => 0 documents passed validation after transformation\e[0m"\
                         "\n\e[31m    => 1 document failed validation after transformation\e[0m"\
                         "\n      => ./data/local-environment/projectName/some-type/.logs/transforms.log has more detailed information.\n\n";

        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml',
            :metadata => './spec/fixtures/.cache/metadata/0ed7cf93-acf7-4081-88ff-27ffe10ffc6c.json'
        }];

        config = {};
        config[:project] = 'projectName';
        config[:environment] = 'local';
        config[:filetype] = 'some-type';
        config[:xsl] = './spec/fixtures/xml-handler/invalid.xsl';
        config[:xsd] = './spec/fixtures/xml-handler/only-source-valid.xsd';

        transformations = ContentTransformer.new(documents, config, '', console);
        expect {
            transformations.process();
        }.to output(expectedOutput).to_stdout_from_any_process;
    end

    it 'should not output any feedback to console if the silent flag is used' do
        documents = [{
            :source => './spec/fixtures/xml-handler/source.xml',
            :target => './spec/fixtures/temp/target.xml',
            :metadata => './spec/fixtures/.cache/metadata/0ed7cf93-acf7-4081-88ff-27ffe10ffc6c.json'
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
