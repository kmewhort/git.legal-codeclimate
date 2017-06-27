class Service::PythonRequirementsTxt::Parse < ::MicroService
  attribute :file_contents

  def call
    line_number = 1
    results = []

    file_contents.each_line do |line_iter|
      name, version = line_iter.split /\W\=/
      results << {
        name: name,
        version: version,
        line: line_number
      }
      line_number +=1
    end

    results
  end
end
