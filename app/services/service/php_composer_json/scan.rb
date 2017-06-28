class Service::PhpComposerJson::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_packagist".to_sym
    self.follow_dependencies = true
    super
  end

  protected
  def library_identifiers
    Service::PhpComposerJson::Parse.call(file_contents: file_contents)
  end

  def library_class
    'PhpLibrary'
  end
end
