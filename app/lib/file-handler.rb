#!/usr/bin/env ruby
# -*- encoding : utf-8 -*-
require 'fileutils'

class FileHandler
  def create(path, contents)
    # Ensure directory exists before attempting to write to it
    directory = File.dirname(path);
    FileUtils.mkdir_p(directory) unless File.exists?(directory)

    # Create file
    open(path ,"wb") { |file|
        file.write(contents)
    }
  end

  def copy(source, destination)
    # Ensure directory exists before attempting to write to it
    directory = File.dirname(destination);
    FileUtils.mkdir_p(directory) unless File.exists?(directory)

    # Create file
    FileUtils.cp(source, destination);
  end
end
