class Service::YarnLockfile::Scan < ::MicroService
  attribute :lockfile_path

  def call
    libs_by_line_number.each do |line_number, lib_json|
      Service::AnalyzeLibrary.call(
        name: 'TODO',
        version: 'TODO',
        file: 'Gemfile.lock',
        line_number: line_number
      )
    end
  end

  private
  def specs_by_line_number
    Service::YarnLockfile::Parse.call(lockfile_contents)
  end

  def lockfile_contents
    IO.read lockfile_path
  end
end
