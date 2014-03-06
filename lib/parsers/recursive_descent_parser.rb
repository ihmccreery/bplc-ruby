module Parsers
  # a simple Parser
  class RecursiveDescentParser
    def initialize(source)
      @source = source
    end

    def parse
      return Program.new(declaration_list)
    end

    def declaration_list
      return DeclarationList.new
    end
  end
end
