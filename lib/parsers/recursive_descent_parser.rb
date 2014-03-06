module Parsers
  # a simple Parser
  class RecursiveDescentParser

    TYPE_SPECIFIERS = [:int, :void, :string].freeze

    def initialize(source)
      @source = source
      next_token
    end

    def parse
      return Program.new(declaration_list)
    end

    def declaration_list
      d = DeclarationList.new(nil, declaration)
      while is_type_specifier?(current_token)
        d = DeclarationList.new(d, declaration)
      end
      return d
    end

    def declaration
      d = Declaration.new(type_specifier, id)
      semicolon
      return d
    end

    def type_specifier
      return TypeSpecifier.new(consume_token)
    end

    def id
      return Id.new(consume_token)
    end

    def semicolon
      consume_token
    end

    private

    def is_type_specifier?(token)
      TYPE_SPECIFIERS.include? token.type
    end

    def consume_token
      t = current_token
      next_token
      return t
    end

    def current_token
      @source.current_token
    end

    def next_token
      @source.next_token
    end
  end
end
