class Service::YarnLockfile::Scan < Service::ScanManifestBase
  def call
    ActiveRecord::Base.establish_connection "#{Rails.env}_npm".to_sym
    super
  end

  protected
  def library_identifiers
    Service::YarnLockfile::Parse.call(lockfile_path: file_path)
  end

  def library_class
    'JsLibrary'
  end
end
