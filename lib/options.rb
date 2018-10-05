module ConfigLoader

    def ConfigLoader.get_transform_config
        config = get_config_from_command_line()
        add_transformation_paths_to_config(config)
        substitute_yaml_variables(get_yaml(config[:yaml]), config)
        config
    end

    def ConfigLoader.substitute_yaml_variables(yaml, config)
        yaml.each { |k,v|
            substitute = v
            substitute = substitute.gsub(':filetype', config[:filetype])
            substitute = substitute.gsub(':environment', config[:environment])
            config[k.to_sym] = substitute
        }
        config
    end

    def ConfigLoader.get_config_from_command_line
        config = {}
        OptionParser.new do |opts|
            opts.banner = 'Usage: transform.rb [options]'

            opts.on('-p', '--project PROJECT', 'The iSite project to target.') do |v|
              config[:project] = v
            end

            opts.on('-e', '--environment ENVIRONMENT', 'The iSite environment to target') do |v|
                config[:environment] = v
            end

            opts.on('-f', '--filetype FILETYPE', 'The iSite filetype to migrate') do |v|
                config[:filetype] = v
            end

            opts.on(
                '-t',
                '--transformation TRANSFORMATION',
                'The number of the transformation to run'
            ) do |v|
                begin
                    config[:transformation] = Integer(v, 10)
                rescue ArgumentError => e
                    config[:transformation] = nil
                end
            end

        end.parse!

        # Ensure the command-line options are appropriate
        begin
            unless /^(education|guides|blocks(-[a-zA-Z0-9]+){0,})$/.match(config[:project])
                abort('Project must be curriculum, guides or a Blocks project.')
            end

            if config[:filetype].nil?
                abort('You must specify a filetype.')
            end

            unless /(test|stage|live)/.match(config[:environment])
                abort('Environment must be one of test, stage or live.')
            end

            if config[:transformation].nil? || config[:transformation] < 1
                abort('Transformation number must be specified.')
            end
        end

        config
    end

    def ConfigLoader.add_transformation_paths_to_config(config)
        project_dirs = {
            'education' => 'kandlcurriculum',
            'guides' => 'kandlguides'
        }

        if /^blocks(-[a-zA-Z0-9]+){0,}$/.match?(config[:project])
            project_dirs[config[:project]] = 'blocks'
        end

        base_path = "../#{project_dirs[config[:project]]}/isite2/templates/migrations/#{config[:filetype]}"

        subdirectories = get_subdirectories(base_path)
        matched_subdirectories = []

        subdirectories.each { |subdirectory|
            prefix = subdirectory.split('-')[0]
            begin
                transformation_number = Integer(prefix, 10)
            rescue ArgumentError => e
                transformation_number = nil
            end
            if transformation_number == config[:transformation]
                matched_subdirectories.push(subdirectory)
            end
        }

        if matched_subdirectories.empty?
            abort("Could not find transformation number #{config[:transformation]} in directory #{base_path}/")
        elsif matched_subdirectories.length > 1
            abort("Multiple migrations with transformation number #{config[:transformation]} in directory #{base_path}/")
        end

        config[:path] = "#{base_path}/#{matched_subdirectories[0]}"
        config[:yaml] = "#{config[:path]}/transform.yml"
        config[:xsl] = "#{config[:path]}/transform.xsl"
        config[:xsd] = "#{config[:path]}/schema.xsd"

    end

    def ConfigLoader.get_subdirectories(path)
        begin
            Dir.entries(path).select {|e|
                File.directory?("#{path}/#{e}") && !['.', '..'].include?(e)
            }.sort
        rescue
            []
        end
    end

    def ConfigLoader.get_yaml(filename)
        yaml = begin
            YAML.load(IO.read(filename))
        rescue StandardError => e
            abort("Could not parse YAML: #{e.message}")
        end
        yaml
    end

end
