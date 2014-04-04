require 'spec_helper'

describe TypeChecker do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(TypeChecker.new(resolve("int x; void main(void) { x; }"))).to be_a TypeChecker
    end
  end
end
