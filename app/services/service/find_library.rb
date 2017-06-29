class Service::FindLibrary < ::MicroService
  attribute :name
  attribute :version
  attribute :type
  attribute :version_must_match, Boolean, default: false

  def call
    if version_must_match && !version.blank?
      Library.where(name: name, type: type, version: version).first
    else
      Library.where(name: name, type: type).order(version: :desc).first
    end
  end
end
