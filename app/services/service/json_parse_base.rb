class Service::JsonParseBase < ::MicroService
  attribute :file_contents

  def call
    library_data.map do |lib_name, lib_fuzzy_version|
      {
        name: lib_name,
        version: nil, # don't currently handle fuzzy dependency version numbers
        line: find_line_starting_with_key(lib_name),
      }
    end
  end

  protected
  def dependency_json_key
    raise "Pure virtual"
  end

  def library_data
    data = JSON.parse file_contents
    return [] unless data.has_key? dependency_json_key
    data[dependency_json_key]
  end

  def find_line_starting_with_key(library_name)
    line_number = file_contents.each_line.find_index do |line_iter|
      line_iter.gsub(/^\s*[\"\']/, '').start_with? library_name
    end

    line_number+1
  end
end
