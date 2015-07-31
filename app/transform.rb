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

# Apply the XSL to each XML document
tc = Transform.new(Settings.xslpath);

# Update the 'Live' documents
tc.update(
    "#{Settings.inputpath}/*.xml",
    "#{Settings.outputpath}/:guid.xml",
);