#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

class XmlHandler
    def initialize()
        @errors = nil
    end

    def setDocument(xmlStr=nil)
        @document = Nokogiri.XML(xmlStr) do |config|
            config.default_xml.noblanks
        end
    end

    def read(xmlSource=nil)
        if File.file?(xmlSource)
            setDocument(IO.read(xmlSource))
        else
            abort(" => Unable to read xml: #{xmlSource}")
        end
    end

    def transform(xslSource=nil, projectName=nil)
        if File.file?(xslSource)
            xsltContents = IO.read(xslSource)

            if !projectName.nil?
                xsltContents = xsltContents.gsub('/project/blocks/', "/project/#{projectName}/")
            end

            xslt = Nokogiri::XSLT(xsltContents)
        else
            abort(" => Unable to read xsl: #{xslSource}")
        end

        setDocument(
            xslt.transform(@document).to_s
        )
    end

    def validate(xsdSource=nil, projectName=nil)
        if File.file?(xsdSource)
            xsdContents = IO.read(xsdSource)

            if !projectName.nil?
                xsdContents = xsdContents.gsub('/project/blocks/', "/project/#{projectName}/")
                xsdContents = xsdContents.gsub('urn:isite:blocks:', "urn:isite:#{projectName}:")
            end

            xsd = Nokogiri::XML::Schema(xsdContents)
        elsif xsdSource.is_a? String
            abort(" => Unable to read xsd: #{xsdSource}")
        end

        if !xsd.valid?(@document)
            @errors = xsd.validate(@document)
        end

        xsd.valid?(@document)
    end

    def logErrors(log = '', title = '')
        message = title
        @errors.each do |error|
            message += "\n  => Line #{error.line}, #{error.message}"
        end

        if log.instance_of? Logger
            log.info message
        end
    end

    def save()
        @document.to_xml(:indent => 2).to_s.strip
    end

    def saveAsFile(targetFilename)
        # Ensure directory exists before attempting to write to it
        directory = File.dirname(targetFilename)
        FileUtils.mkdir_p(directory) unless File.exists?(directory)

        # Now create file
        open(targetFilename ,"wb") { |file|
            file.write(save())
        }
    end
end
