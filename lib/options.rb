# Pass in command-line parameters
options = {}
OptionParser.new do |opts|
    opts.banner = "Usage: transform.rb [options]"

    opts.on("-e", "--environment ENVIRONMENT", "The Forge environment to target") do |v|
        options[:environment] = v
    end

    opts.on("-c", "--config CONFIG", "The path to the migration config file") do |v|
        options[:configFile] = v
    end
end.parse!


# Ensure the command-line options are appropriate
begin
    unless /(test|stage|live)/.match(options[:environment])
        abort('Environment must be one of test, stage or live.')
    end

    unless !options[:configFile].nil? && File.file?(options[:configFile])
        abort("You must specify a YAML config file")
    end
end


# Read in the config file
@config = begin
    YAML.load(IO.read(options[:configFile]))
rescue ArgumentError => e
    puts "Could not parse YAML: #{e.message}"
end


# Add environment to options so all variables contained
# in one object
@config["environment"] = options[:environment]


# YAML values can contain references to variables, so update these
@config.each { |k,v|
    substitute = v
    substitute = substitute.gsub(':filetype', @config['filetype'])
    substitute = substitute.gsub(':environment', @config['environment'])

    @config[k] = substitute
}
