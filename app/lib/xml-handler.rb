#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'nokogiri';

class XmlHandler
    attr_reader :content, :document;

    def init(xmlStr)
        @document = Nokogiri.XML(xmlStr) do |config|
          config.default_xml.noblanks
        end

        @content = '';
    end

    def applyTransformation(xsl)
        # Specify the XSLT file to use
        xslt  = Nokogiri::XSLT(xsl);

        # Apply the XSLT transformation
        transformed = xslt.transform(@document);
        @content = transformed.to_xml(:indent => 2);
    end

    def stripReaderXml()
        targetNode = @document.xpath("/xmlns:result/xmlns:document/*")
        if targetNode.empty?
          # Assuming this is not a Content Reader document
          @content = @document.to_xml(:indent => 2);
        else
          @content = '<?xml version="1.0" encoding="UTF-8"?>' + "\n";
          @content << targetNode.to_xml(:indent => 2);
        end
    end

    def updateContent(xPathExpression, newValue)
        document.at_xpath(
            xPathExpression
        ).content = newValue;
    end

    def getXPathValue(query)
        @document.xpath(query).to_s;
    end

    def getXPathText(query)
        @document.xpath("#{query}/text()").to_s;
    end

    def asString()
        if @content.empty?
            @content = @document.to_xml(:indent => 2);
        end

        @content.to_s.strip;
    end
end
