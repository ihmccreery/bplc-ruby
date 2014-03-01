module Parsers
  # a simple Parser that takes in a Scanner and builds a tree out of the successive tokens
  class RecursiveDescentParser
    def initialize(source)
      configure_source(source)
    end

    def parse
      if @parse
        return @parse
      else
        next_token
        parse_type_specifier
      end
    end

    private

    def parse_type_specifier
      if current_token.is_type_specifier?
        return Parse::TypeSpecifier.new
      else
        raise SyntaxError, "expected type specifier, got #{current_token.type}"
      end
    end

    ###################
    # support methods #
    ###################

    # source must either
    #   be a Scanner
    #   respond to #next_token and #current_token
    def configure_source(source)
      @source = source
    end

    def next_token
      @source.next_token
    end

    def current_token
      @source.current_token
    end
  end
end
