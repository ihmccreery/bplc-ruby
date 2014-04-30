require 'spec_helper'

describe CodeGenerator do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(CodeGenerator.new(label("int x; void main(void) { x; }"), StringIO.new)).to be_a CodeGenerator
    end
  end
end
