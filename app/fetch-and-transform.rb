#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'optparse';
require 'set';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

require_relative 'fetch.rb'
require_relative 'lib/transform'

# Apply the XSL transform(s) to each XML document
tc = Transform.new(Settings.xslpath);

# Update the 'Live' documents
puts "Updating 'Live' documents..."
tc.update(
    "#{Settings.data}/extracted/live/*.xml",
    "#{Settings.data}/transformed/live/:guid.xml",
);

# Update the 'In-Progress' documents
puts "Updating 'In-Progress' documents..."
tc.update(
    "#{Settings.data}/extracted/in-progress/*.xml",
    "#{Settings.data}/transformed/in-progress/:guid.xml",
);