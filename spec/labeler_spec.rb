require 'spec_helper'

describe Resolver do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Labeler.new(type_check("int x; void main(void) { x; }"))).to be_a Labeler
    end
  end

  describe "#label" do
    it "labels string literals" do
      a = label('void main(void) { "a"; write("hello"); } void f(void) { string x; x = "argh"; }')
      ["a", "hello", "argh"].each_with_index do |v, i|
        expect(a.str_lit_exps[i].value).to eq(v)
        expect(a.str_lit_exps[i].label).to eq(".str#{i}")
      end
    end
  end
end
