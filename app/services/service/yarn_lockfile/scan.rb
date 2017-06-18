class Service::YarnLockfile::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_npm".to_sym
  end

  protected
  def library_identifiers
    Service::YarnLockfile::Parse.call(file_contents)
  end

  def library_class
    'JsLibrary'
  end
end
