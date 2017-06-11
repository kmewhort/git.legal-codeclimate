class Service::YarnLockfile::Parse < ::MicroService
  attribute :lockfile_path

  def call
    library_data.map do |lib_fullname, lib_data|
      lib_name, fuzzy_version = lib_fullname.split('@')

      lib_data.with_indifferent_access.merge({
        name: lib_name,
        line_number: find_line_number(lib_name)
      })
    end
  end

  private
  def library_data
    # our yarn parser is in JS, as it re-uses the hand-written Yarn parser from the yarn library
    json_result = `node #{Rails.root.join('lib','yarn_parser')} #{lockfile_path}`
    JSON.parse json_result
  end

  def find_line_number(library_name)
    line_number = lockfile_contents.each_line.find_index do |line_iter|
      line_iter.gsub(/^\"/, '').start_with? "#{library_name}@"
    end

    line_number+1
  end

  def lockfile_contents
    IO.read lockfile_path
  end
end
