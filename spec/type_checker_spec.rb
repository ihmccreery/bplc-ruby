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

    # TODO y and z
    it "assigns VarExps the correct type" do
      a = type_check('int x; int *y; int z[2]; void main(void) { x; y; z; }')

      body = a.declarations[3].body
      expect(body.stmts[0].exp.type).to eq(:int)
      expect(body.stmts[1].exp.type).to eq(:pointer_int)
      expect(body.stmts[2].exp.type).to eq(:array_int)
    end

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
