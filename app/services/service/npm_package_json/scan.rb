class Service::NpmPackageJson::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_npm".to_sym
    self.follow_dependencies = true
    super
  end

  protected
  def library_identifiers
    Service::NpmPackageJson::Parse.call(file_contents: file_contents)
  end

  def library_class
    'JsLibrary'
  end
end
