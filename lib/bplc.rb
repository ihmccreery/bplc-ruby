require 'errors'
require 'scanner'
require 'parser'
require 'resolver'
require 'type_checker'
require 'indexer'
require 'code_generator'

class Bplc
  def initialize(fname)
    @source = File.new(fname)
  end

  def compile(output)
    begin
      a = Parser.new(Scanner.new(@source)).parse
      Resolver.new(a).resolve
      TypeChecker.new(a).type_check
      CodeGenerator.new(a, output).generate
    rescue BplError => error
      puts formatted_error(error)
    end
  end

  private

  def formatted_error(error)
    return <<-message
#{error.class}: #{error.message} on line #{error.line}:

#{[*@source][error.line-1]}
message
  end
end
