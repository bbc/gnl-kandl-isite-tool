#!/usr/bin/env ruby

module Settings
    @filetype = nil;
    @environment = nil;
    @project = nil;
    @xslpath = nil;
    @threads = 20;
    @inputpath = nil;
    @pemFile = '/etc/pki/certificate.pem';
    @lastModifiedSince = nil;

    def self.filetype=(v)
        @filetype=v;
    end

    def self.environment=(v)
        @environment=v;
    end

    def self.project=(v)
        @project=v;
    end

    def self.xslpath=(v)
        @xslpath=v
    end

    def self.threads=(v)
        @threads=v;
    end

    def self.inputpath=(v)
        @inputpath = v;
    end

    def self.outputpath=(v)
        @outputpath = v;
    end

    def self.pemFile=(v)
        @pemFile=File.read(v);
    end

    def self.lastModifiedSince=(v)
        @lastModifiedSince = v
    end

    def self.filetype
        return @filetype;
    end

    def self.environment
        return @environment;
    end

    def self.project
        return @project;
    end

    def self.xslpath
        return @xslpath
    end

    def self.threads
        return @threads;
    end

    def self.inputpath
        return @inputpath
    end

    def self.outputpath
        return @outputpath
    end

    def self.pemFile
        return File.read(@pemFile);
    end

    def self.lastModifiedSince
        return @lastModifiedSince;
    end

    def self.cache
        return "#{self.data}/.cache";
    end

    def self.log
        directory = "#{self.data}/.logs";
        FileUtils.mkdir_p(directory) unless File.exists?(directory)
        return directory;
    end

    def self.data
        return "./data/#{@environment}-environment/#{@project}/#{self.filetype}";
    end

    def self.metadataURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/:guid/meta',
            self.environment,
            self.project
        );
    end

    def self.latestContentURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/:guid',
            self.environment,
            self.project
        );
    end

    def self.publishedContentURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-content-reader/content?contentId=:guid',
            self.environment
        );
    end

    def self.deletePermanentlyURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/:guid?permanent=true',
            self.environment,
            self.project
        );
    end

    def self.publishURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/publish',
            self.environment,
            self.project
        );
    end

    def self.unPublishURL
        return sprintf(
            'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/unpublish',
            self.environment,
            self.project
        );
    end

    def self.thingIdURL
        return sprintf(
            'https://api.%s.bbc.co.uk/knowlearn-asset/topic-of-study/thing-id',
            self.environment
        );
    end
end


optparse = OptionParser.new do |opts|
    opts.on("-e", "--environment ENVIRONMENT", "The environment to update") do |environment|
        Settings.environment = environment
    end

    opts.on("-p", "--project PROJECT", "The iSite2 project to query") do |project|
        Settings.project = project
    end

    opts.on("-f", "--filetype FILETYPE", "The iSite2 file type to update") do |filetype|
        Settings.filetype = filetype
    end

    opts.on('-x', '--xslpath PATH TO XSL', "Path of the XSL file(s) to use for transforms") do |xslpath|
        Settings.xslpath = xslpath
    end

    opts.on('-t', '--threads NUMBER', Integer, "The number of threads to use (default #{Settings.threads})") do |threads|
        Settings.threads = threads
    end

    opts.on('-i', '--inputpath INPUTPATH', "Path containing XML documents to transform") do |inputpath|
        Settings.inputpath = inputpath
    end

    opts.on('-o', '--output OUTPUTPATH', "Output path for transformed XML documents") do |outputpath|
        Settings.outputpath = outputpath
    end

    opts.on('-m', '--modified MODIFIED', Integer, "Only fetch documents modified since YYYYMMDD") do |modified|
        Settings.lastModifiedSince = modified
    end

    opts.on('-c', '--certificate PATH', "Path to your certificate file") do |certpath|
        Settings.pemFile = certpath
    end

    opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit
    end
end

begin
    optparse.parse!

    mandatoryArgs = Hash.new
    mandatoryArgs['fetch'] = ['environment', 'project', 'filetype']
    mandatoryArgs['fetch-and-transform'] = ['environment', 'project', 'filetype', 'xslpath']
    mandatoryArgs['remove'] = mandatoryArgs['fetch']
    mandatoryArgs['transform'] = ['inputpath', 'outputpath', 'xslpath']
    mandatoryArgs['upload'] = mandatoryArgs['fetch']
    mandatoryArgs['filter'] = ['environment', 'project', 'filetype']
    mandatoryArgs['publish-only'] = ['environment', 'project', 'filetype']
    mandatoryArgs['unpublish'] = ['environment', 'project', 'filetype']

    command = File.basename($0, File.extname($0))

    mandatory = mandatoryArgs[command]
    # Enforce the presence of the -e, -p and -f switches
    missing = mandatory.select { |param| Settings.module_eval(param).nil? }
    unless missing.empty?
        puts "Missing options: #{missing.join(', ')}"
        puts optparse
        exit
    end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
    # Friendly output when parsing fails
    puts $!.to_s
    puts optparse
    exit
end
