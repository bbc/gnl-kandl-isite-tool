#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'nokogiri';

require_relative 'file-handler'
require_relative 'xml-handler'

class Transform
    attr_reader :xslpath

    def initialize(xslPath = '')
        puts "Preparing to transform documents..."
        puts "================================================="

        if not File.exists? xslPath
            $stderr.puts " => ERROR: File or directory '#{xslPath}' does not exist."
            exit 1
        else
            @xslPath = xslPath
        end
    end

    def update(source, destination)
        if File.directory? @xslPath
            xsls = Dir.glob("#{@xslPath}/*.xsl").sort

            if xsls.empty?
                $stderr.puts " => ERROR: No XSL transforms found in '#{@xslPath}'."
                exit 1
            end

            fh = FileHandler.new
            destinationDir = File.dirname(destination)
            Dir.glob(source).each do |sourceFile|
                fh.copy(sourceFile, destinationDir + "/" + File.basename(sourceFile))
            end

            xsls.each do |xsl|
                applyTransform(destinationDir + "/*.xml", destination, xsl)
            end
        else
            applyTransform(source, destination, @xslPath)
        end
    end

    def applyTransform(source, destination, xslPath)
        puts " => using xsl: #{xslPath}"
        xsl = IO.read(xslPath);

        Dir.glob(source) do |sourceFile|
            xh = XmlHandler.new
            xh.init(IO.read(sourceFile));
            xh.applyTransformation(xsl);

            guid = File.basename(sourceFile, '.xml');
            destinationPath = destination.gsub(':guid', guid);

            fh = FileHandler.new
            fh.create(destinationPath, xh.asString());
        end
    end
end
