class Service::CodeClimate::LoadLicensePolicy < ::MicroService
  CODECLIMATE_CONFIG_FILE_PATH = '/config.json'

  def call
    ::Policy.new(policy_hash)
  end

  private
  def policy_hash
    settings = JSON.parse IO.read(CODECLIMATE_CONFIG_FILE_PATH)
    settings['config'] || {}
  end
end
