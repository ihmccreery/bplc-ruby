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
      return DeclarationList.new(nil, declaration)
    end

    def declaration
      return Declaration.new(type_specifier, id)
    end

    def type_specifier
      return TypeSpecifier.new(next_token)
    end

    def id
      return Id.new(next_token)
    end

    private

    def next_token
      @source.next_token
    end
  end
end
