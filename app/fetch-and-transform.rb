#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

require 'optparse';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

# Settings for updating the 'Live' documents
Settings.xslpath = "transforms"
Settings.inputpath = "#{Settings.data}/extracted/live";
Settings.outputpath = "#{Settings.data}/transformed/live";

require_relative 'fetch.rb'
require_relative 'transform.rb'

# Update the 'In-Progress' documents
Settings.inputpath = "#{Settings.data}/extracted/in-progress";
Settings.outputpath = "#{Settings.data}/transformed/in-progress";
applyTransformOrTransforms()
