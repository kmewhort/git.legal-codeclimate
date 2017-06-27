class Service::PythonRequirementsTxt::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_pypi".to_sym
    self.follow_dependencies = false
    super
  end

  protected
  def library_identifiers
    Service::PythonRequirementsTxt::Parse.call(file_contents: file_contents)
  end

  def library_class
    'PythonLibrary'
  end
end
