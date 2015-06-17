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
require_relative 'lib/isite2/filter'
require_relative 'lib/isite2/list'
require_relative 'lib/isite2/metadata'
require_relative 'lib/isite2/unpublish'
require_relative 'lib/isite2/delete'
require_relative 'lib/isite2/upload'
require_relative 'lib/isite2/publish'

#
require_relative 'lib/education/transform'
require_relative 'lib/education/thing_id'


byGuideId = {}
byTopicOfstudyId = {}

puts
puts "Find iWonder Guide references within Study Guide Lists"
puts "======================================================"
directory = "./data/#{Settings.environment}-environment/sg-study-guide-list"
Dir.glob("#{directory}/extracted/**/*.xml") do |filename|
    doc = Nokogiri::XML(IO.read(filename))
    doc.remove_namespaces!

    link_elements = doc.xpath('//iwonder-guides/iwonder-guide/link-url');

    if link_elements.count > 0
        tosId = doc.xpath('//details/topic-of-study').text

        doc.xpath('//iwonder-guides/iwonder-guide/link-url').each do |node|
            zedIds = /\/(z[yv3bgrc49k8dwjq72mx6thpnsf]{6})/.match(node.text);

            if !zedIds.nil?
                guideId = zedIds[1];

                if not byGuideId.has_key?(guideId)
                    byGuideId[guideId] = []
                end
                byGuideId[guideId] << tosId

                if not byTopicOfstudyId.has_key?(tosId)
                    byTopicOfstudyId[tosId] = []
                end
                byTopicOfstudyId[tosId] << guideId
            end
        end
    end
end

# Extract out all the Topic Of Study Ids into a simple array
# so that it can be determined if it has a Thing Id
tosIds = []
byTopicOfstudyId.each do |(a,b)|
    tosIds << a
end

# Determine the Thing Id to use for each document
# and update the XML with that Thing Id
tids = ThingId.new();
tids.cacheThingIds(tosIds);

puts
puts "Adding Topic of Study Information to Guides XML"
puts "==============================================="
directory = "./data/#{Settings.environment}-environment/guide"
Dir.glob("#{directory}/transformed/**/*.xml") do |filename|
    doc = Nokogiri::XML(IO.read(filename));

    guideId = doc.xpath('//xmlns:guide/xmlns:summary/xmlns:id').text

    if !guideId.empty? && byGuideId.has_key?(guideId)
        curriculum_topics = doc.xpath('//xmlns:curriculum-topics');

        if curriculum_topics.count > 0
            curriculum_topics_element = doc.xpath('//xmlns:curriculum-topics')[0];
            curriculum_topics_element.children.remove

            byGuideId[guideId].each do |tosId|
                curriculum_topic = Nokogiri::XML::NodeSet.new(doc)

                topic_element = Nokogiri::XML::Node.new('curriculum-topic', doc);

                tos_element = Nokogiri::XML::Node.new('topic-of-study', doc);
                tos_element.content = tosId;

                thingId = IO.read("#{Settings.cache}/thing-id/#{tosId}");

                thing_element = Nokogiri::XML::Node.new('thing-id', doc);
                thing_element.content = thingId.strip;

                topic_element << tos_element;
                topic_element << thing_element;
                curriculum_topic << topic_element;

                curriculum_topics_element <<  curriculum_topic;
            end

            fh = FileHandler.new
            fh.create(
                filename.gsub('/transformed/', '/modified/'),
                doc.to_xml(:indent => 2).to_s.strip
            );
        end
    end
end

puts
puts "Formatting Guides XML files"
puts "=========================================="
Dir.glob("#{directory}/modified/**/*.xml") do |filename|
    document = Nokogiri.XML(IO.read(filename)) do |config|
      config.default_xml.noblanks
    end

    content = document.to_xml(:indent => 2)

    fh = FileHandler.new
    fh.create(
        filename.gsub('/modified/', '/upload/'),
        content.to_s.strip
    );
end
