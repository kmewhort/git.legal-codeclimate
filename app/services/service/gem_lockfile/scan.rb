class Service::GemLockfile::Scan < Service::ScanFileBase
  protected
  def library_identifiers
    Service::GemLockfile::Parse.call(file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
