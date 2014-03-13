module Parsers
  # a simple Parser
  class RecursiveDescentParser
    TYPE_SPECIFIERS = [:int, :void, :string].freeze
    ADD_OPS = [:plus, :minus].freeze
    MUL_OPS = [:asterisk, :slash, :percent].freeze
    FIRST_OF_STATEMENTS = [:semicolon, :id, :asterisk, :minus, :ampersand,
                           :l_paren, :read, :num, :str, :l_brace, :if,
                           :while, :return, :write, :writeln].freeze

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

    ###########
    # program #
    ###########

    def program
      p = Program.new(declarations)
      eat(:eof)
      return p
    end

    ################
    # declarations #
    ################

    def declarations
      d = [declaration]
      while at? TYPE_SPECIFIERS
        d << declaration
      end
      return d
    end

    def declaration
      t = type_specifier
      if at? :asterisk
        eat(:asterisk)
        d = PointerDeclaration.new(t, id)
        eat(:semicolon)
      else
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          d = ArrayDeclaration.new(t, i, num)
          eat(:r_bracket)
          eat(:semicolon)
        elsif at? :l_paren
          eat(:l_paren)
          p = params
          eat(:r_paren)
          d = FunctionDeclaration.new(t, i, p, compound_statement)
        else
          d = SimpleDeclaration.new(t, i)
          eat(:semicolon)
        end
      end
      return d
    end

    ##########
    # params #
    ##########

    def params
      if at? :void
        eat(:void)
        return []
      else
        p = [param]
        while at? :comma
          eat(:comma)
          p << param
        end
        return p
      end
    end

    def param
      t = type_specifier
      if at? :asterisk
        eat(:asterisk)
        p = PointerParam.new(t, id)
      else
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          eat(:r_bracket)
          p = ArrayParam.new(t, i)
        else
          p = SimpleParam.new(t, i)
        end
      end
      return p
    end

    ##############
    # statements #
    ##############
def compound_statement
      eat(:l_brace)
      c = CompoundStatement.new(local_declarations, statements)
      eat(:r_brace)
      return c
    end

    def local_declarations
      d = []
      while at? TYPE_SPECIFIERS
        d << local_declaration
      end
      return d
    end

    def local_declaration
      t = type_specifier
      if at? :asterisk
        eat(:asterisk)
        d = PointerDeclaration.new(t, id)
        eat(:semicolon)
      else
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          d = ArrayDeclaration.new(t, i, num)
          eat(:r_bracket)
          eat(:semicolon)
        else
          d = SimpleDeclaration.new(t, i)
          eat(:semicolon)
        end
      end
      return d
    end

    def statements
      s = []
      while at? FIRST_OF_STATEMENTS
        s << statement
      end
      return s
    end

    def statement
      if at? :l_brace
        return compound_statement
      elsif at? :if
        return if_statement
      elsif at? :while
        return while_statement
      elsif at? :return
        return return_statement
      elsif at? :write
        return write_statement
      elsif at? :writeln
        return writeln_statement
      else
        return expression_statement
      end
    end

    def expression_statement
      if at? :semicolon
        s = ExpressionStatement.new(nil)
      else
        s = ExpressionStatement.new(expression)
      end
      eat(:semicolon)
      return s
    end

    def if_statement
      eat(:if)
      eat(:l_paren)
      c = expression
      eat(:r_paren)
      b = statement
      if at? :else
        eat(:else)
        return IfStatement.new(c, b, statement)
      else
        return IfStatement.new(c, b, nil)
      end
    end

    def while_statement
      eat(:while)
      eat(:l_paren)
      c = expression
      eat(:r_paren)
      return WhileStatement.new(c, statement)
    end

    def return_statement
      eat(:return)
      if at? :semicolon
        eat(:semicolon)
        return ReturnStatement.new(nil)
      else
        e = expression
        eat(:semicolon)
        return ReturnStatement.new(e)
      end
    end

    def write_statement
      eat(:write)
      eat(:l_paren)
      c = expression
      eat(:r_paren)
      eat(:semicolon)
      return WriteStatement.new(c)
    end

    def writeln_statement
      eat(:writeln)
      eat(:l_paren)
      eat(:r_paren)
      eat(:semicolon)
      return WritelnStatement.new
    end

    ###############
    # expressions #
    ###############

    # TODO unfinished
    def expression
      return SimpleExpression.new(e)
    end

    ##############
    # arithmetic #
    ##############

    def e
      r = E.new(nil, nil, t)
      while at? ADD_OPS
        r = E.new(add_op, r, t)
      end
      return r
    end

    def t
      r = T.new(nil, nil, f)
      while at? MUL_OPS
        r = T.new(mul_op, r, f)
      end
      return r
    end

    def f
      if at? :minus
        eat(:minus)
        return MinusF.new(f)
      elsif at? :ampersand
        eat(:ampersand)
        return AddressF.new(factor)
      elsif at? :asterisk
        eat(:asterisk)
        return PointerF.new(factor)
      else
        return SimpleF.new(factor)
      end
    end

    ###########
    # factors #
    ###########

    def factor
      if at? :l_paren
        eat(:l_paren)
        f = ExpressionFactor.new(expression)
        eat(:r_paren)
        return f
      elsif at? :read
        f = ReadFactor.new(read)
        eat(:l_paren)
        eat(:r_paren)
        return f
      elsif at? :num
        return NumFactor.new(num)
      elsif at? :str
        return StrFactor.new(str)
      else
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          f = ArrayFactor.new(i, expression)
          eat(:r_bracket)
          return f
        elsif at? :l_paren
          return FunCallFactor.new(i, args)
        else
          return SimpleFactor.new(i)
        end
      end
    end

    def args
      eat(:l_paren)
      if at? :r_paren
        eat(:r_paren)
        return []
      else
        p = [expression]
        while at? :comma
          eat(:comma)
          p << expression
        end
        eat(:r_paren)
        return p
      end
    end

    #####################
    # general terminals #
    #####################

    def type_specifier
      if at? TYPE_SPECIFIERS
        return TypeSpecifier.new(eat_token)
      else
        raise SyntaxError, "expected type_specifier, got #{current_token.type.to_s}"
      end
    end

    def add_op
      if at? ADD_OPS
        return AddOp.new(eat_token)
      else
        raise SyntaxError, "expected add_op, got #{current_token.type.to_s}"
      end
    end

    def mul_op
      if at? MUL_OPS
        return MulOp.new(eat_token)
      else
        raise SyntaxError, "expected mul_op, got #{current_token.type.to_s}"
      end
    end

    def id
      Id.new(eat(:id))
    end

    def num
      Num.new(eat(:num))
    end

    def str
      Str.new(eat(:str))
    end

    def read
      Read.new(eat(:read))
    end

    ###################
    # support methods #
    ###################

    def eat(type)
      if at? type
        eat_token
      else
        raise SyntaxError, "expected #{type.to_s}, got #{current_token.type.to_s}"
      end
    end

    def at?(type)
      if type.is_a? Array
        return type.include? current_token.type
      else
        return current_token.type == type
      end
    end

    def eat_token
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
