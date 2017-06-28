class Service::PhpComposerLock::Parse < Service::JsonParseBase
  def call
    library_data.map do |lib_data|
      {
        name: lib_data['name'],
        version: lib_data['version'],
        line: find_line_with_json_value(lib_data['name']),
      }
    end
  end

  protected
  def dependency_json_key
    'packages'
  end

  def find_line_with_json_value(library_name)
    line_number = file_contents.each_line.find_index do |line_iter|
      line_iter.gsub(/^.*\:\s*[\"\']/, '').start_with? library_name
    end

    line_number+1
  end
end

