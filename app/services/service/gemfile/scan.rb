class Service::Gemfile::Scan < Service::ScanManifestBase
  def call
    self.follow_dependencies = true
    super
  end

  protected
  def library_identifiers
    Service::Gemfile::Parse.call(file_contents: file_contents)
  end

  def library_class
    'GemLibrary'
  end
end
