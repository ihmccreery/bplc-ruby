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

    # TODO?
    #########
    # Stmts #
    #########

    # TODO
    ########
    # Exps #
    ########

    # TODO
    ###########
    # VarExps #
    ###########

    it "assigns SimpleDeclarations the correct type" do
      a = type_check('int x; void main(void) { x; &x; }')

      body = a.declarations[1].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:pointer_int)
    end

    it "raises a SyntaxError if bad operators are used on SimpleDeclarations" do
      expect{type_check('int x; void main(void) { *x; }')}.to raise_error(SyntaxError, "cannot dereference int")
      expect{type_check('int x; void main(void) { x[1]; }')}.to raise_error(SyntaxError, "cannot index int")
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

    # TODO errors for wrong types

    # FunCallExp

    ###########
    # LitExps #
    ###########

    it "assigns LitExps the correct type" do
      a = type_check('void main(void) { 2; "a"; read(); }')

      body = a.declarations[0].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:str)
      expect(body.stmts[2].exp.type).to eq(:int)
    end
  end
end
