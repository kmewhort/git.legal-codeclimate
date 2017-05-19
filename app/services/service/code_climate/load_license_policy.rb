class Service::CodeClimate::LoadLicensePolicy
  CODECLIMATE_CONFIG_FILE_PATH = '/config.json'

  def call
    Policy.new(config_hash['policy'])
  end

  private
  def config_hash
    JSON.parse IO.read(CODECLIMATE_CONFIG_FILE_PATH)
  end
end
