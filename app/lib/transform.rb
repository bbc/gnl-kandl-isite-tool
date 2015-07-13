#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'nokogiri';

require_relative 'file-handler'

class Transform
    attr_reader :xsl

    def initialize(xslFile = '')
        puts "Preparing to transform documents..."
        puts "================================================="

        if not File.exists? xslFile
            $stderr.puts " => ERROR: File '#{xslFile}' does not exist."
            exit 1
        else
            puts " => using xsl: #{xslFile}"
            @xsl = IO.read(xslFile);
        end
    end

    def update(source, destination)
        Dir.glob(source) do |sourceFile|
            guid = File.basename(sourceFile, '.xml');

            xh = XmlHandler.new
            xh.init(IO.read(sourceFile));
            xh.applyTransformation(@xsl);

            destinationPath = destination.gsub(':guid', guid);

            fh = FileHandler.new
            fh.create(destinationPath, xh.asString());
        end
    end
end
