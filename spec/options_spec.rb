require 'lib/options'

YAML_TEST_FILE = './spec/fixtures/test_config.yaml'
VALID_PROJ_ARG = ['-p', 'education']
VALID_ENV_ARG = ['-e', 'test']
VALID_FILETYPE_ARG = ['-f', 'sg-study-guide']
VALID_TN_ARG = ['-t', '001']


describe 'getting config from command line' do

    context 'for project' do

        let(:other_required_args) {
            VALID_ENV_ARG + VALID_FILETYPE_ARG + VALID_TN_ARG
        }

        it 'should abort with error message if project not set' do
            stub_args(other_required_args)
            expect_project_error()
        end

        it 'should reject invalid project name' do
            stub_args(['-p', 'invalid-proj'], other_required_args)
            expect_project_error()
        end

        where(:project) do
            [
                ['education'],
                ['guides'],
                ['blocks'],
                ['blocks-bitesize'],
                ['blocks-food'],
                ['blocks-terrific-scientific']
            ]
        end

        with_them do
            it 'should set the project in config' do
                stub_args(['-p', project], other_required_args)
                config = ConfigLoader.get_config_from_command_line()
                expect(config[:project]).to eq project
            end
        end

    end

    context 'for environment' do

        let(:other_required_args) {
            VALID_PROJ_ARG + VALID_FILETYPE_ARG + VALID_TN_ARG
        }

        it 'should abort with error message if environment not set' do
            stub_args(other_required_args)
            expect_environment_error()
        end

        it 'should reject invalid environment name' do
            stub_args(['-e', 'invalid_env'], other_required_args)
            expect_environment_error()
        end

        where(:env) do
            [
                ['test'],
                ['stage'],
                ['live']
            ]
        end

        with_them do
            it 'should set the environment in config' do
                stub_args(['-e', env], other_required_args)
                config = ConfigLoader.get_config_from_command_line()
                expect(config[:environment]).to eq env

            end
        end

    end

    context 'for filetype' do

        let(:other_required_args) {
            VALID_PROJ_ARG + VALID_ENV_ARG + VALID_TN_ARG
        }

        it 'should abort with error message if filetype not set' do
            stub_args(other_required_args)
            expect_filetype_error()
        end

        it 'should set the filetype in config' do
            stub_args(VALID_FILETYPE_ARG, other_required_args)
            config = ConfigLoader.get_config_from_command_line()
            expect(config[:filetype]).to eq 'sg-study-guide'
        end

    end

    context 'for transformation number' do

        let(:other_required_args) {
            VALID_PROJ_ARG + VALID_ENV_ARG + VALID_FILETYPE_ARG
        }

        it 'should abort if transformation number not set' do
            stub_args(other_required_args)
            expect_transformation_number_error()
        end

        it 'should abort if transformation number is not a number' do
            stub_args(['-t', 'one'], other_required_args)
            expect_transformation_number_error()
        end

        where(:invalid_input) do
            [
                ['0'],
                ['-1']
            ]
        end

        with_them do
            it 'should abort if transformation is less than one' do
                stub_args(['-t', invalid_input], other_required_args)
                expect_transformation_number_error()
            end
        end

        where(:number, :expected) do
            [
                ['1', 1],
                ['01', 1],
                ['010', 10]
            ]
        end

        with_them do
            it 'should set the transformation number in config' do
                stub_args(['-t', number], other_required_args)
                config = ConfigLoader.get_config_from_command_line()
                expect(config[:transformation]).to eq expected
            end
        end

    end

    private
    def stub_args(*opts)
        args = *opts.reduce([], :concat)
        stub_const('ARGV', args)
    end

    private
    def expect_project_error
        expect {
          ConfigLoader.get_config_from_command_line()
        }.to raise_error(SystemExit, /Project must be curriculum, guides or a Blocks project\./)
    end

    private
    def expect_filetype_error
        expect {
          ConfigLoader.get_config_from_command_line()
        }.to raise_error(SystemExit, /You must specify a filetype\./)
    end

    private
    def expect_environment_error
        expect {
          ConfigLoader.get_config_from_command_line()
        }.to raise_error(SystemExit, /Environment must be one of test, stage or live\./)
    end

    private
    def expect_transformation_number_error
        expect {
          ConfigLoader.get_config_from_command_line()
        }.to raise_error(SystemExit, /Transformation number must be specified\./)
    end

end


describe 'getting config from yaml file' do
    BAD_YAML_TEST_FILE = './spec/fixtures/test_config_bad.yaml'

    it 'should abort with error message if the config cannot be read as YAML' do
        expect {
            ConfigLoader.get_yaml(BAD_YAML_TEST_FILE)
        }.to raise_error(SystemExit, /Could not parse YAML:/)
    end

    it 'should return the YAML configuration as a dictionary' do
        EXPECTED = {
          "source" => "/:environment/:filetype/extracted/**/*.xml",
          "target" => "/:environment/:filetype/transformed/**/*.xml"
        }
        actual = ConfigLoader.get_yaml(YAML_TEST_FILE)
        expect(actual).to include EXPECTED
    end
end


describe 'providing variable names in the configuration' do

    it('should substitute them with values from the yaml') do
      yaml = {
          'path': '/dev/:environment/for/:filetype/script',
          'thing': 'whatever'
      }
      config = {
          :filetype => 'study-guide',
          :environment => 'test',
      }
      expected = {
          :filetype => 'study-guide',
          :environment => 'test',
          :path => '/dev/test/for/study-guide/script',
          :thing => 'whatever'
      }
      actual = ConfigLoader.substitute_yaml_variables(yaml, config)
      expect(actual).to eq expected
    end
end


describe 'getting subdirectories' do
    it 'should return a list of directory names' do
        path = './spec/fixtures/subdirectories'
        expected = ['directory_1', 'directory_2', 'directory_3']
        expect(ConfigLoader.get_subdirectories(path)).to eq expected
    end
end


describe 'getting a validated configuration' do

    it 'should abort if there is no matching transformation directory' do
        config = {
          :project => 'education',
          :filetype => 'this-will-not-exist',
          :transformation => 1
        }
        path = "../kandlcurriculum/isite2/templates/migrations/this-will-not-exist/"
        expect {
            ConfigLoader.add_transformation_paths_to_config(config)
        }.to raise_error(
            SystemExit,
            /Could not find transformation number 1 in directory #{path}/
        )
    end

    context 'using mocked subdirectories' do

        where(:project, :project_path) do
            [
                ['education', 'kandlcurriculum'],
                ['guides', 'kandlguides']
            ]
        end

        with_them do
            it 'should return the full paths to the transformation files' do
                config = {
                  :project => project,
                  :filetype => 'sg-study-guide',
                  :transformation => 1
                }
                patch_project_subdirectories()
                ConfigLoader.add_transformation_paths_to_config(config)
                expect(config[:path]).to eq "../#{project_path}/isite2/templates/migrations/sg-study-guide/001-transform"
                expect(config[:yaml]).to eq "../#{project_path}/isite2/templates/migrations/sg-study-guide/001-transform/transform.yml"
                expect(config[:xsl]).to eq "../#{project_path}/isite2/templates/migrations/sg-study-guide/001-transform/transform.xsl"
                expect(config[:xsd]).to eq "../#{project_path}/isite2/templates/migrations/sg-study-guide/001-transform/schema.xsd"
            end
        end

        it 'should abort if there are multiple matching migrations' do
            config = {
                :project => 'education',
                :filetype => 'sg-study-guide',
                :transformation => 2
              }
              patch_project_subdirectories()
              path = "../kandlcurriculum/isite2/templates/migrations/sg-study-guide/"
              expect {
                  ConfigLoader.add_transformation_paths_to_config(config)
              }.to raise_error(
                  SystemExit,
                  /Multiple migrations with transformation number 2 in directory #{path}/)
        end

    end

    private
        def patch_project_subdirectories()
            allow(ConfigLoader).to receive(:get_subdirectories).and_return(
                ["000_red_herring", "001-transform", "002-transform", "002-duplicate-transform"]
            )
        end
end


describe 'getting the tranformation configuration' do

    it 'should combine the command-line options with the configuration file' do
      stub_const('ARGV',
          VALID_ENV_ARG +
          VALID_PROJ_ARG +
          VALID_TN_ARG +
          VALID_FILETYPE_ARG
      )
      allow(ConfigLoader).to receive(:get_subdirectories).and_return(["001-transform"])
      allow(ConfigLoader).to receive(:get_yaml).and_return(ConfigLoader.get_yaml(YAML_TEST_FILE))

      expected = {
          :project => 'education',
          :filetype => 'sg-study-guide',
          :environment => 'test',
          :transformation => 1,
          :path => "../kandlcurriculum/isite2/templates/migrations/sg-study-guide/001-transform",
          :yaml => "../kandlcurriculum/isite2/templates/migrations/sg-study-guide/001-transform/transform.yml",
          :xsl => "../kandlcurriculum/isite2/templates/migrations/sg-study-guide/001-transform/transform.xsl",
          :xsd => "../kandlcurriculum/isite2/templates/migrations/sg-study-guide/001-transform/schema.xsd",
          :source => "/test/sg-study-guide/extracted/**/*.xml",
          :target => "/test/sg-study-guide/transformed/**/*.xml"
      }
      config = ConfigLoader.get_transform_config()
      expect(config).to eq expected
    end

end
