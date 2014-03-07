module Parsers
  # a simple Parser
  class RecursiveDescentParser
    TYPE_SPECIFIERS = [:int, :void, :string].freeze

    def initialize(source)
      @source = source
      next_token
    end

    def parse
      if @parse
        return @parse
      else
        return @parse = program
      end
    end

    private

    #################
    # parse methods #
    #################

    def program
      p = Program.new(declaration_list)
      eof
      return p
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
      if is_type_specifier?(current_token)
        return TypeSpecifier.new(consume_token)
      else
        raise SyntaxError, "expected type_specifier, got #{current_token.type.to_s}"
      end
    end

    def id
      if current_token.type == :id
        return Id.new(consume_token)
      else
        raise SyntaxError, "expected id, got #{current_token.type.to_s}"
      end
    end

    def semicolon
      if current_token.type == :semicolon
        consume_token
      else
        raise SyntaxError, "expected semicolon, got #{current_token.type.to_s}"
      end
    end

    def eof
      if current_token.type == :eof
        consume_token
      else
        raise SyntaxError, "expected eof, got #{current_token.type.to_s}"
      end
    end

    ###################
    # support methods #
    ###################

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
