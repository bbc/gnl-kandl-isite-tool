#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-

require 'optparse';

# This object is populated with default values for the command-line options,
# which can then be over-ridden if the user specifies these values.
require_relative 'config/settings.rb'

# Required: -e, -p, -f

Settings.xslpath = "transforms"
Settings.inputpath = "#{Settings.data}/extracted/live";
Settings.outputpath = "#{Settings.data}/transformed/live";

require_relative 'fetch.rb'
require_relative 'transform.rb'

