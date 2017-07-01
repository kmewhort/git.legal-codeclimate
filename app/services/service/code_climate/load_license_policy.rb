class Service::CodeClimate::LoadLicensePolicy < ::MicroService

  def call
    policy = ::Policy.new(policy_hash)

    if pro_version?
      add_whitelist policy
      add_blacklist policy
    end

    policy
  end

  private
  def policy_hash
    hash = config.dup
    hash.slice!('license_whitelist', 'license_blacklist')
    hash.slice!(*community_version_allowed_keys) unless pro_version?

    hash
  end

  def add_whitelist
    return if config['license_whitelist'].blank?
    config['license_whitelist'].each do |identifier|
      policy.add_to_whitelist find_license_type!(identifier)
    end
  end

  def add_blacklist
    return if config['license_blacklist'].blank?

    config['license_blacklist'].each do |identifier|
      policy.add_to_blacklist find_license_type!(identifier)
    end
  end

  def community_version_allowed_keys
    %w(allow_affero_copyleft allow_strong_copyleft)
  end

  def product_license
    @product_license ||= Service::LoadProductLicense.call
  end

  def config
    @config ||= Service::CodeClimate::GetEngineConfig.call()['config'] || {}
  end

  def pro_version?
    product_license && !product_license.expired?
  end

  def find_license_type!(identifier)
    license_type = Service::LicenseTypes::FindByIdentifier.call(
      identifier: identifier,
      create_if_not_found: false).try(:first)
    )
    raise "Unknown license identifier in git.legal configuration" if license_type.nil?

    license_type
  end
end
