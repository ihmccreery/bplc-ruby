require 'spec_helper'

describe Resolver do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Indexer.new(type_check("int x; void main(void) { x; }"))).to be_a Indexer
    end
  end
end
