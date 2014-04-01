require 'spec_helper'

describe Resolver do
  let(:r) { Resolver.new(parse_program("int x;")) }

  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(r).to be_a Resolver
    end
  end
end
