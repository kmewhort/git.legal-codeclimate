class Service::NpmPackageJson::Parse < Service::JsonParseBase
  protected
  def dependency_json_key
    'dependencies'
  end
end
