#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

#
require_relative 'lib/file-handler'
require_relative 'lib/xml-handler'

#
require_relative 'lib/transform'

# Apply XSL transform <xslFile> to all XML documents in <inPath> and place output in <outPath>
def applyTransform(inPath, outPath, xslFile)
    puts "Applying #{xslFile} to XML in #{inPath}"

    tc = Transform.new(xslFile);

    tc.update(
        "#{inPath}/*.xml",
        "#{outPath}/:guid.xml",
    );

    puts "Transformed XML output path: #{outPath}"
end

# Apply a series of XSL transforms <xslFile> to all XML documents in <inPath> and place output in <outPath>
def applyTransforms()
    sortedXslFiles = Dir.glob("#{Settings.xslpath}/*.xsl").sort

    inPath = "#{Settings.inputpath}"
    outPath = ""

    sortedXslFiles.each do |xslFile|
        outPath = "#{Settings.outputpath}/#{File.basename(xslFile, '.xsl')}-out"
        applyTransform inPath, outPath, xslFile
        inPath = outPath
    end

    # Move all output from last transform into #{Settings.outputpath} and remove dir
    puts "Moving XML from #{outPath} to #{Settings.outputpath} and deleting #{outPath}"
    FileUtils.mv(Dir.glob("#{outPath}/*.xml"), Settings.outputpath);
    FileUtils.remove_dir(outPath);
end

def applyTransformOrTransforms()
    if File.directory? Settings.xslpath
        applyTransforms()
    else
        applyTransform Settings.inputpath, Settings.outputpath, Settings.xslpath
    end
end

applyTransformOrTransforms()
