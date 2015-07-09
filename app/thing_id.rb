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
require_relative 'lib/isite2/list'
require_relative 'lib/isite2/metadata'
require_relative 'lib/isite2/unpublish'
require_relative 'lib/isite2/delete'
require_relative 'lib/isite2/upload'
require_relative 'lib/isite2/publish'

#
require_relative 'lib/education/thing_id'
require_relative 'lib/transform'


Settings.parseOptions

topicOfStudyXPath = nil;
thingIdXPath = nil;

if Settings.filetype === 'sg-study-guide'
    topicOfStudyXPath = '/xmlns:study-guide/xmlns:topic-of-study';
    thingIdXPath = '/xmlns:study-guide/xmlns:thing-id';
elsif Settings.filetype === 'learning-clip'
    topicOfStudyXPath = '/xmlns:learning-clip/xmlns:details/xmlns:topic-of-study';
    thingIdXPath = '/xmlns:learning-clip/xmlns:details/xmlns:thing-id';
end;

# Determine the Thing Id to use for each document
# and update the XML with that Thing Id
tids = ThingId.new
tids.parseXmlForTopicOfStudyIds(
    "#{Settings.data}/transformed/**/*.xml",
    topicOfStudyXPath,
    thingIdXPath
);

    # Add the Thing Id to the 'Live' documents
    tids.updateXML(
        "#{Settings.data}/transformed/live/*.xml",
        "#{Settings.data}/updated/live/:guid.xml"
    );

    # Add the Thing Id to the 'In-Progress' documents
    tids.updateXML(
        "#{Settings.data}/transformed/in-progress/*.xml",
        "#{Settings.data}/updated/in-progress/:guid.xml"
    );
