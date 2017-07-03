require 'micro_service'
class Service::Approvals::CheckPolicyApproval < ::MicroService
  attribute :policy
  attribute :license_types

  def call
    # for now, assume that multiple licenses are OR'd
    license_types.any? do |lt|
      (license_category_permitted?(lt) || whitelisted?(lt)) && !blacklisted?(lt)
    end
  end

  private
  def license_category_permitted?(lt)
    policy.allow_permissive? && lt.permissive? ||
    policy.allow_weak_copyleft? && lt.weak_copyleft? ||
    policy.allow_strong_copyleft? && lt.strong_copyleft? ||
    policy.allow_affero_copyleft? && lt.affero_copyleft?
  end

  def whitelisted?(lt)
    policy.whitelist.any?{|whitelisted_lt| lt == whitelisted_lt}
  end

  def blacklisted?(lt)
    policy.blacklist.any?{|blacklisted_lt| lt == blacklisted_lt}
  end
end
