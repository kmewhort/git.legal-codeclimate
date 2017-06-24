require 'stringio'

def capture_stdout
  new_std_out = StringIO.new
  original = $stdout

  $stdout = new_std_out
  yield
  $stdout = original

  new_std_out.string
end
