class Service::CodeClimate::GetEngineConfig < ::MicroService
  CODECLIMATE_CONFIG_FILE_PATH = '/config.json'

  def call
    @@settings ||= begin
      if File.exist? Service::ScanProject::CODECLIMATE_CONFIG_FILE_PATH
        default_setttings.merge JSON.parse(IO.read(Service::ScanProject::CODECLIMATE_CONFIG_FILE_PATH))
      else
        default_settings
      end
    end
  end

  private
  def default_settings
    {
      config: {},
      include_paths: ['./']
    }
  end
end
