class Service::Gemspec::Parse < ::MicroService
  attribute :file_contents

  def call
    parsed_dependencies.map do |dep|
      {
        name: dep.name,
        version: nil, # don't currently handle requirements/fuzzy dependencies
        line: dep.instance_variable_get(:@line)
      }
    end
  end

  private
  def parsed_dependencies
    Gemnasium::Parser.gemspec(file_contents).dependencies
  end
end
