#!/usr/bin/env ruby

module Settings
  @filetype = nil;
  @environment = nil;
  @project = nil;
  @xslpath = nil;
  @threads = 20;
  @pemFile = '/etc/pki/klunified.pem';
  @proxyHost = nil;
  @proxyPort = nil;

  def self.setProxy()
    if File.exist? '/var/tmp/reithproxies'
      if File.read('/var/tmp/reithproxies').include? 'on'
          @proxyHost = 'www-cache.reith.bbc.co.uk';
          @proxyPort = 80;
      end
    end
  end

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

  def self.pemFile=(v)
    @pemFile=File.read(v);
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

  def self.pemFile
    return File.read(@pemFile);
  end

  def self.proxyHost
    return @proxyHost;
  end

  def self.proxyPort
    return @proxyPort;
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
    return "./data/#{@environment}-environment/#{self.filetype}";
  end

  def self.lightweightListURL
    return sprintf(
        'https://api.%s.bbc.co.uk/isite2-api/project/%s/content/lightweight-list',
        self.environment,
        self.project
    );
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

  def self.parseOptions
    optparse = OptionParser.new do |opts|
      opts.on("-e", "--environment ENVIRONMENT", "The environment to update") do |environment|
        self.environment = environment
      end

      opts.on("-p", "--project PROJECT", "The iSite2 project to query") do |project|
        self.project = project
      end

      opts.on("-f", "--filetype FILETYPE", "The iSite2 file type to update") do |filetype|
        self.filetype = filetype
      end

      opts.on('-x', '--xslpath PATH TO XSL', "Path of the XSL file to use for transforms") do |xslpath|
        self.xslpath = xslpath
      end

      opts.on('-t', '--threads NUMBER', Integer, "The number of threads to use (default #{Settings.threads})") do |threads|
        self.threads = threads
      end

      opts.on('-h', '--help', 'Display this screen') do
        puts opts
        exit
      end
    end

    begin
      optparse.parse!
      mandatory = ['environment', 'project', 'filetype', 'xslpath'];
      # Enforce the presence of the -e, -p and -f switches
      missing = mandatory.select{ |param| Settings.module_eval(param).nil? }
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
  end

end




# automatically pick up the reithproxy settings from the sandbox
Settings.setProxy();
