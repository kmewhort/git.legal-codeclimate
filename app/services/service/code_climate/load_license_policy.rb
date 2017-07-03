class Service::CodeClimate::LoadLicensePolicy < ::MicroService
  def call
    @@loaded_policy ||= begin
      policy = ::Policy.new(policy_hash)

      if pro_version?
        add_whitelists(policy)
        add_blacklists(policy)
      end

      policy
    end
  end

  private
  def policy_hash
    hash = config.dup
    hash = hash.except('license_whitelist', 'license_blacklist')
    hash.slice!(*community_version_allowed_keys) unless pro_version?

    hash
  end

  def add_whitelists(policy)
    return if config['license_whitelist'].blank?
    config['license_whitelist'].each do |identifier|
      find_license_types(identifier).each do |license_type|
        policy.add_to_whitelist license_type
      end
    end
  end

  def add_blacklists(policy)
    return if config['license_blacklist'].blank?

    config['license_blacklist'].each do |identifier|
      find_license_types(identifier).each do |license_type|
        policy.add_to_blacklist license_type
      end
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

  def find_license_types(identifier)
    license_types = Service::LicenseTypes::FindByIdentifier.call(
      identifier: identifier
    )
    raise "Unknown license identifier in git.legal configuration" if license_types.blank?

    license_types
  end
end
