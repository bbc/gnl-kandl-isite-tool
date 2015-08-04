#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

require_relative 'lib/transform'

# Apply the XSL transform(s) to each XML document
tc = Transform.new(Settings.xslpath);

# Apply the transform(s) to XML documents in <inputpath>, place output in <outputpath>
tc.update(
    "#{Settings.inputpath}/*.xml",
    "#{Settings.outputpath}/:guid.xml",
);