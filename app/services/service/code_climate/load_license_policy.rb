class Service::CodeClimate::LoadLicensePolicy < ::MicroService

  def call
    ::Policy.new(policy_hash)
  end

  private
  def policy_hash
    settings = Service::CodeClimate::GetEngineConfig.call
    settings['config']
  end
end
