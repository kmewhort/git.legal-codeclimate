class Service::CodeClimate::LoadLicensePolicy < ::MicroService

  def call
    ::Policy.new(policy_hash)
  end

  private
  def policy_hash
    settings = Service::CodeClimate::GetEngineConfig.call
    policy = settings['config'] || {}

    policy.slice!(*community_version_allowed_keys) unless product_license && !product_license.expired?
    policy
  end

  def community_version_allowed_keys
    %w(allow_affero_copyleft allow_strong_copyleft)
  end

  def product_license
    @product_license ||= Service::LoadProductLicense.call
  end
end
