require 'spec_helper'

describe TypeChecker do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(TypeChecker.new(resolve("int x; void main(void) { x; }"))).to be_a TypeChecker
    end
  end

  describe "#type_check" do

    # TODO?
    ###########
    # Program #
    ###########

    # TODO?
    ################
    # Declarations #
    ################

    # TODO?
    ##########
    # Params #
    ##########

    # TODO
    #########
    # Stmts #
    #########

    ########
    # Exps #
    ########

    it "assigns AssignmentExps the correct type" do
      a = type_check('int x; int *y; int z[2]; void main(void) { x = 5; x = *y = z[0] = 10; x = *y; *y = z[1]; z[0] = x; }')

      body = a.declarations[3].body
      body.stmts.each do |s|
        expect(s.exp.type).to eq(:int)
      end
    end

    it "raises a SyntaxError if operands in AssignmentExps do not match" do
      expect{type_check('string x; void main(void) { x = 5; }')}.to raise_error(SyntaxError, "invalid assignment: cannot assign int to string")
      expect{type_check('int x; int *y; void main(void) { x = y; }')}.to raise_error(SyntaxError, "invalid assignment: cannot assign pointer_int to int")
    end

    it "assigns RelExps the correct type" do
      a = type_check('int x; int *y; void main(void) { x > 5; 5 == *y; -x != *y; x > -x % *y; }')

      body = a.declarations[2].body
      body.stmts.each do |s|
        expect(s.exp.type).to eq(:int)
      end
    end

    it "raises a SyntaxError if bad operands are used in RelExps" do
      expect{type_check('string x; void main(void) { x < 5; }')}.to raise_error(SyntaxError, "invalid lhs: cannot lt string")
      expect{type_check('int x; void main(void) { 5 == &x; }')}.to raise_error(SyntaxError, "invalid rhs: cannot eq pointer_int")
      expect{type_check('int x[10]; void main(void) { 2 != x; }')}.to raise_error(SyntaxError, "invalid rhs: cannot neq array_int")
    end

    it "assigns ArithmeticExps the correct type" do
      a = type_check('int x; int *y; void main(void) { x + 5; 5 * *y; -x; x + -x % *y; }')

      body = a.declarations[2].body
      body.stmts.each do |s|
        expect(s.exp.type).to eq(:int)
      end
    end

    it "raises a SyntaxError if bad operands are used in ArithmeticExps" do
      expect{type_check('string x; void main(void) { x + 5; }')}.to raise_error(SyntaxError, "invalid lhs: cannot plus string")
      expect{type_check('int x; void main(void) { 5 / &x; }')}.to raise_error(SyntaxError, "invalid rhs: cannot slash pointer_int")
      expect{type_check('int x[10]; void main(void) { -x; }')}.to raise_error(SyntaxError, "invalid exp: cannot minus array_int")
    end

    ###########
    # VarExps #
    ###########

    it "assigns SimpleDeclarations the correct type" do
      a = type_check('int x; string y; void main(void) { x; y; &x; &y; }')

      body = a.declarations[2].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:string)
      expect(body.stmts[2].exp.type).to eq(:pointer_int)
      expect(body.stmts[3].exp.type).to eq(:pointer_string)
    end

    it "raises a SyntaxError if bad operators are used on SimpleDeclarations" do
      expect{type_check('int x; void main(void) { *x; }')}.to raise_error(SyntaxError, "cannot dereference int")
      expect{type_check('int x; void main(void) { x[1]; }')}.to raise_error(SyntaxError, "cannot index int")
      expect{type_check('int x; void main(void) { &x[1]; }')}.to raise_error(SyntaxError, "cannot index int")
    end

    it "assigns PointerDeclarations the correct type" do
      a = type_check('int *x; void main(void) { x; *x; }')

      body = a.declarations[1].body
      expect(body.stmts[0].exp.type).to eq(:pointer_int)
      expect(body.stmts[1].exp.type).to eq(:int)
    end

    it "raises a SyntaxError if bad operators are used on PointerDeclarations" do
      expect{type_check('int *x; void main(void) { &x; }')}.to raise_error(SyntaxError, "cannot reference pointer_int")
      expect{type_check('int *x; void main(void) { x[1]; }')}.to raise_error(SyntaxError, "cannot index pointer_int")
      expect{type_check('int *x; void main(void) { &x[1]; }')}.to raise_error(SyntaxError, "cannot index pointer_int")
    end

    it "assigns ArrayDeclarations the correct type" do
      a = type_check('int x[2]; void main(void) { x; x[1]; &x[1]; }')

      body = a.declarations[1].body
      expect(body.stmts[0].exp.type).to eq(:array_int)
      expect(body.stmts[1].exp.type).to eq(:int)
      expect(body.stmts[2].exp.type).to eq(:pointer_int)
    end

    it "raises a SyntaxError if bad operators are used on ArrayDeclarations" do
      expect{type_check('int x[2]; void main(void) { *x; }')}.to raise_error(SyntaxError, "cannot dereference array_int")
      expect{type_check('int x[2]; void main(void) { &x; }')}.to raise_error(SyntaxError, "cannot reference array_int")
    end

    it "assigns FunctionDeclarations the correct type" do
      a = type_check('int f(void) { } string g(void) { } void h(void) { } void main(void) { f(); g(); h(); }')

      body = a.declarations[3].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:string)
      expect(body.stmts[2].exp.type).to eq(:void)
    end

    ###########
    # LitExps #
    ###########

    it "assigns LitExps the correct type" do
      a = type_check('void main(void) { 2; "a"; read(); }')

      body = a.declarations[0].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:string)
      expect(body.stmts[2].exp.type).to eq(:int)
    end
  end
end
