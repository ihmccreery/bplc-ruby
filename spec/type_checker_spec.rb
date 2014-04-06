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

    # TODO
    ###########
    # LitExps #
    ###########
  end
end
