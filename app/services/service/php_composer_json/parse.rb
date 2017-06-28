class Service::PhpComposerJson::Parse < Service::JsonParseBase
  def call
    result = super

    # filter out core libs (all without an organization in the name)
    result.select {|lib| lib[:name] =~ /\// }
  end

  protected
  def dependency_json_key
    'require'
  end
end

