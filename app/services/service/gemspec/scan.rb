class Service::Gemfile::Scan < Service::ScanFileBase
  protected
  def library_identifiers
    Service::Gemspec::Parse.call(file_contents: file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
