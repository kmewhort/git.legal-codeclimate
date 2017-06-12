class Service::YarnLockfile::Scan < Service::ScanManifestBase
  protected
  def library_identifiers
    Service::YarnLockfile::Parse.call(file_contents)
  end

  def library_class
    'JsLibrary'
  end
end
