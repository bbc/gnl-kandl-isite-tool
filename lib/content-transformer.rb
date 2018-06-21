#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'rainbow/refinement'
using Rainbow

class ContentTransformer
    def initialize(documents, config, log, console)
        @documents = documents
        @log = log
        @config = config
        @console = console

        @sourceValidCount = 0
        @sourceInvalidCount = 0
        @transformedCount = 0
        @validCount = 0
        @invalidCount = 0
    end

    def documentCase(documentCount)
        if documentCount == 1
            return "#{documentCount} document"
        end

        return "#{documentCount} documents"
    end

    def process()
        logFile = "./data/#{@config[:environment]}-environment/#{@config[:project]}/#{@config[:filetype]}/.logs/transforms.log"

        @console.info "Transforming documents..."
        @console.info "================================================="

        applyXsl()

        @console.info " => #{documentCase(@transformedCount)} transformed"
        if @config.has_key?(:xsd)
            @console.info "    => #{documentCase(@sourceValidCount)} passed validation before transformation"
            @console.info "    => #{documentCase(@sourceInvalidCount)} failed validation before transformation"
            @console.info "    => #{documentCase(@validCount)} passed validation after transformation".green
            if @invalidCount > 0
                @console.info "    => #{documentCase(@invalidCount)} failed validation after transformation".red
            end
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

            if @config.has_key?(:xsd)
                if documentXML.validate(@config[:xsd], @config[:project])
                    @sourceValidCount += 1
                else
                    @sourceInvalidCount += 1
                end
            end

            # Update the XML to the desired format
            documentXML.transform(@config[:xsl], @config[:project])

            if @config.has_key?(:xsd)
                # Output details of any file that doesn't match the schema.
                # Note this doesn't stop the invalid xml file from being created but it does
                # provide detailed information about why the document isn't valid
                if !documentXML.validate(@config[:xsd], @config[:project])
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
