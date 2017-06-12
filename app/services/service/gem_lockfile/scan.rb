class Service::GemLockfile::Scan < Service::ScanManifestBase
  protected
  def library_identifiers
    Service::GemLockfile::Parse.call(file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
