#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
class ContentTransformer
    def initialize(documents, config, log, console)
        @documents = documents
        @log = log
        @config = config
        @console = console

        @transformedCount = 0
        @validCount = 0
        @invalidCount = 0
    end

    def process()
        logFile = "./data/#{@config['environment']}-environment/#{@config['filetype']}/.logs/transforms.log"

        @console.info "Transforming documents..."
        @console.info "================================================="

        applyXsl()

        @console.info " => #{@transformedCount} document(s) were transformed"
        if @config.has_key?('xsd')
            @console.info "    => #{@validCount} document(s) passed validation"
            @console.info "    => #{@invalidCount} document(s) failed validation"
        end
        if @invalidCount > 0
            @console.info "      => #{logFile} has more detailed information."
        end
        @console.info ""
    end

    private
    def applyXsl()
        @documents.each { |document|
            documentXML = XmlHandler.new

            # Open the Source XML
            documentXML.read(document[:source])

            # Update the XML to the desired format
            documentXML.transform(@config['xsl'])

            if @config.has_key?('xsd')
                # Output details of any file that doesn't match the schema.
                # Note this doesn't stop the invalid xml file from being created but it does
                # provide detailed information about why the document isn't valid
                if !documentXML.validate(@config['xsd'])
                    documentXML.logErrors(
                        @log,
                        "XSD VALIDATION ERROR\n => #{document[:target]}"
                    )

                    @invalidCount += 1
                else
                    @validCount += 1
                end
            end

            # Save the transformed XML
            documentXML.saveAsFile(document[:target])

            @transformedCount += 1
        }
    end
end
