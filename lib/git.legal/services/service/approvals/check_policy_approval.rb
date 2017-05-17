require 'micro_service'
class Service::Approvals::CheckPolicyApproval < ::MicroService
  attribute :policy
  attribute :license_types

  def call
    # for now, assume that multiple licenses are OR'd
    license_types.any? do |lt|
      policy.allow_permissive? && lt.permissive? ||
      policy.allow_weak_copyleft? && lt.weak_copyleft? ||
      policy.allow_strong_copyleft? && lt.strong_copyleft? ||
      policy.allow_affero_copyleft? && lt.affero_copyleft?
    end
  end
end
