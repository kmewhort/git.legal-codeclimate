class Service::PhpComposerLock::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_packagist".to_sym
    self.follow_dependencies = false
    super
  end

  protected
  def library_identifiers
    Service::PhpComposerLock::Parse.call(file_contents: file_contents)
  end

  def library_class
    'PhpLibrary'
  end
end
