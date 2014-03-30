module Parsers
  # a simple Parser
  class RecursiveDescentParser
    TYPE_SPECIFIERS = [:int, :void, :string].freeze
    REL_OPS = [:leq, :lt, :eq, :neq, :gt, :geq].freeze
    ADD_OPS = [:plus, :minus].freeze
    MUL_OPS = [:asterisk, :slash, :percent].freeze
    FIRST_OF_LIT_EXP = [:read, :num, :str].freeze
    FIRST_OF_VAR_EXP = [:ampersand, :asterisk, :id].freeze
    FIRST_OF_STATEMENT = [:semicolon, :id, :asterisk, :minus, :ampersand,
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
          d = ArrayDeclaration.new(t, i, num_lit_exp)
          eat(:r_bracket)
          eat(:semicolon)
        elsif at? :l_paren
          eat(:l_paren)
          p = params
          eat(:r_paren)
          d = FunctionDeclaration.new(t, i, p, compound_stmt)
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

    #########
    # stmts #
    #########

    def compound_stmt
      eat(:l_brace)
      c = CompoundStmt.new(local_declarations, stmts)
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
          d = ArrayDeclaration.new(t, i, num_lit_exp)
          eat(:r_bracket)
          eat(:semicolon)
        else
          d = SimpleDeclaration.new(t, i)
          eat(:semicolon)
        end
      end
      return d
    end

    def stmts
      s = []
      while at? FIRST_OF_STATEMENT
        s << stmt
      end
      return s
    end

    def stmt
      if at? :l_brace
        return compound_stmt
      elsif at? :if
        return if_stmt
      elsif at? :while
        return while_stmt
      elsif at? :return
        return return_stmt
      elsif at? :write
        return write_stmt
      elsif at? :writeln
        return writeln_stmt
      else
        return exp_stmt
      end
    end

    def exp_stmt
      if at? :semicolon
        s = ExpStmt.new(nil)
      else
        s = ExpStmt.new(exp)
      end
      eat(:semicolon)
      return s
    end

    def if_stmt
      eat(:if)
      eat(:l_paren)
      c = exp
      eat(:r_paren)
      b = stmt
      if at? :else
        eat(:else)
        return IfStmt.new(c, b, stmt)
      else
        return IfStmt.new(c, b, nil)
      end
    end

    def while_stmt
      eat(:while)
      eat(:l_paren)
      c = exp
      eat(:r_paren)
      return WhileStmt.new(c, stmt)
    end

    def return_stmt
      eat(:return)
      if at? :semicolon
        eat(:semicolon)
        return ReturnStmt.new(nil)
      else
        e = exp
        eat(:semicolon)
        return ReturnStmt.new(e)
      end
    end

    def write_stmt
      eat(:write)
      eat(:l_paren)
      c = exp
      eat(:r_paren)
      eat(:semicolon)
      return WriteStmt.new(c)
    end

    def writeln_stmt
      eat(:writeln)
      eat(:l_paren)
      eat(:r_paren)
      eat(:semicolon)
      return WritelnStmt.new
    end

    ########
    # exps #
    ########

    def exp
      e = rel_exp
      if at? :gets
        return assignment_exp(e)
      else
        return e
      end
    end

    def assignment_exp(e)
      if e.is_a? AssignableVarExp
        eat(:gets)
        return AssignmentExp.new(e, exp)
      else
        raise SyntaxError, "lhs not assignable"
      end
    end

    def rel_exp
      e = add_exp
      if at? REL_OPS
        return RelExp.new(eat_token, e, add_exp)
      else
        return e
      end
    end

    def add_exp
      e = mul_exp
      while at? ADD_OPS
        e = AddExp.new(eat_token, e, mul_exp)
      end
      return e
    end

    def mul_exp
      e = neg_exp
      while at? MUL_OPS
        e = MulExp.new(eat_token, e, neg_exp)
      end
      return e
    end

    def neg_exp
      if at? :minus
        eat(:minus)
        return NegExp.new(neg_exp)
      else
        return factor_exp
      end
    end

    def factor_exp
      if at? FIRST_OF_LIT_EXP
        return lit_exp
      elsif at? FIRST_OF_VAR_EXP
        return var_exp
      elsif at? :l_paren
        eat(:l_paren)
        e = exp
        eat(:r_paren)
        return e
      else
        raise SyntaxError, "expected expression, got #{current_token.type.to_s}"
      end
    end

    ############
    # var_exps #
    ############

    def var_exp
      if at? :ampersand
        eat(:ampersand)
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          n = exp
          eat(:r_bracket)
          return AddrArrayVarExp.new(i, n)
        else
          return AddrVarExp.new(i)
        end
      elsif at? :asterisk
        eat(:asterisk)
        return PointerVarExp.new(id)
      else
        i = id
        if at? :l_bracket
          eat(:l_bracket)
          n = exp
          eat(:r_bracket)
          return ArrayVarExp.new(i, n)
        elsif at? :l_paren
          eat(:l_paren)
          a = args
          eat(:r_paren)
          return FunCallExp.new(i, a)
        else
          return SimpleVarExp.new(i)
        end
      end
    end

    def args
      if at? :r_paren
        return []
      else
        a = [exp]
        while at? :comma
          eat(:comma)
          a << exp
        end
        return a
      end
    end

    ############
    # lit_exps #
    ############

    def lit_exp
      if at? :read
        return read_lit_exp
      elsif at? :num
        return num_lit_exp
      else
        return str_lit_exp
      end
    end

    def read_lit_exp
      r = eat(:read)
      eat(:l_paren)
      eat(:r_paren)
      return ReadLitExp.new(r)
    end

    def num_lit_exp
      return NumLitExp.new(eat(:num))
    end

    def str_lit_exp
      return StrLitExp.new(eat(:str))
    end

    #########################
    # type_specifier and id #
    #########################

    def type_specifier
      if at? TYPE_SPECIFIERS
        return TypeSpecifier.new(eat_token)
      else
        raise SyntaxError, "expected type_specifier, got #{current_token.type.to_s}"
      end
    end

    def id
      Id.new(eat(:id))
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
