class Service::NpmPackageJson::Parse < ::MicroService
  attribute :file_contents

  def call
    library_data.map do |lib_name, lib_fuzzy_version|
      {
        name: lib_name,
        version: nil, # don't currently handle fuzzy dependency version numbers
        line: find_line_number(lib_name),
      }
    end
  end

  private
  def library_data
    data = JSON.parse file_contents
    return nil unless data.has_key? 'dependencies'
    data['dependencies']
  end

  def find_line_number(library_name)
    line_number = file_contents.each_line.find_index do |line_iter|
      line_iter.gsub(/^\s*[\"\']/, '').start_with? library_name
    end

    line_number+1
  end
end
