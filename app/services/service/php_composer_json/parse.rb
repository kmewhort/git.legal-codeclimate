class Service::PhpComposerJson::Parse < Service::JsonParseBase
  protected
  def dependency_json_key
    'require'
  end
end

