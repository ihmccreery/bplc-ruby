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

    ###########
    # LitExps #
    ###########

    it "assigns LitExps the correct type" do
      a = resolve('void main(void) { 2; "a"; read(); }')

      body = a.declarations[0].body
      expect(body.stmts[0].exp.type).to eq(:num)
      expect(body.stmts[1].exp.type).to eq(:str)
      expect(body.stmts[2].exp.type).to eq(:num)
    end
  end
end
