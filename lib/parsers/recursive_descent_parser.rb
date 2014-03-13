module Parsers
  # a simple Parser
  class RecursiveDescentParser
    TYPE_SPECIFIERS = [:int, :void, :string].freeze
    ADD_OPS = [:plus, :minus].freeze
    MUL_OPS = [:asterisk, :slash, :percent].freeze

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
      while is_type_specifier?(current_token)
        d << declaration
      end
      return d
    end

    def declaration
      t = type_specifier
      if current_token.type == :asterisk
        eat(:asterisk)
        d = PointerDeclaration.new(t, id)
        eat(:semicolon)
      else
        i = id
        if current_token.type == :l_bracket
          eat(:l_bracket)
          d = ArrayDeclaration.new(t, i, num)
          eat(:r_bracket)
          eat(:semicolon)
        elsif current_token.type == :l_paren
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
      if current_token.type == :void
        eat(:void)
        return []
      else
        p = [param]
        while current_token.type == :comma
          eat(:comma)
          p << param
        end
        return p
      end
    end

    def param
      t = type_specifier
      if current_token.type == :asterisk
        eat(:asterisk)
        p = PointerParam.new(t, id)
      else
        i = id
        if current_token.type == :l_bracket
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
      while is_type_specifier?(current_token)
        d << local_declaration
      end
      return d
    end

    def local_declaration
      t = type_specifier
      if current_token.type == :asterisk
        eat(:asterisk)
        d = PointerDeclaration.new(t, id)
        eat(:semicolon)
      else
        i = id
        if current_token.type == :l_bracket
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
      # XXX let's check for things, not for absence of things
      while !([:r_brace, :eof].include? current_token.type)
        s << statement
      end
      return s
    end

    # TODO unfinished
    def statement
      if current_token.type == :l_brace
        return compound_statement
      elsif current_token.type == :if
        return if_statement
      elsif current_token.type == :while
        return while_statement
      else
        return expression_statement
      end
    end

    def expression_statement
      if current_token.type == :semicolon
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
      if current_token.type == :else
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
      while is_add_op?(current_token)
        r = E.new(add_op, r, t)
      end
      return r
    end

    def t
      r = T.new(nil, nil, f)
      while is_mul_op?(current_token)
        r = T.new(mul_op, r, f)
      end
      return r
    end

    def f
      if current_token.type == :minus
        eat(:minus)
        return MinusF.new(f)
      elsif current_token.type == :ampersand
        eat(:ampersand)
        return AddressF.new(factor)
      elsif current_token.type == :asterisk
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
      if current_token.type == :l_paren
        eat(:l_paren)
        f = ExpressionFactor.new(expression)
        eat(:r_paren)
        return f
      elsif current_token.type == :read
        f = ReadFactor.new(read)
        eat(:l_paren)
        eat(:r_paren)
        return f
      elsif current_token.type == :num
        return NumFactor.new(num)
      elsif current_token.type == :str
        return StrFactor.new(str)
      else
        i = id
        if current_token.type == :l_bracket
          eat(:l_bracket)
          f = ArrayFactor.new(i, expression)
          eat(:r_bracket)
          return f
        elsif current_token.type == :l_paren
          return FunCallFactor.new(i, args)
        else
          return SimpleFactor.new(i)
        end
      end
    end

    def args
      eat(:l_paren)
      if current_token.type == :r_paren
        eat(:r_paren)
        return []
      else
        p = [expression]
        while current_token.type == :comma
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
      if is_type_specifier?(current_token)
        return TypeSpecifier.new(eat_token)
      else
        raise SyntaxError, "expected type_specifier, got #{current_token.type.to_s}"
      end
    end

    def add_op
      if is_add_op?(current_token)
        return AddOp.new(eat_token)
      else
        raise SyntaxError, "expected add_op, got #{current_token.type.to_s}"
      end
    end

    def mul_op
      if is_mul_op?(current_token)
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
      if current_token.type == type
        eat_token
      else
        raise SyntaxError, "expected #{type.to_s}, got #{current_token.type.to_s}"
      end
    end

    def is_type_specifier?(token)
      TYPE_SPECIFIERS.include? token.type
    end

    def is_add_op?(token)
      ADD_OPS.include? token.type
    end

    def is_mul_op?(token)
      MUL_OPS.include? token.type
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
