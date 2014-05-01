require 'spec_helper'

describe Labeler do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(Labeler.new(type_check("int x; void main(void) { x; }"))).to be_a Labeler
    end
  end

  describe "#label" do
    it "labels StrLitExps" do
      a = label('void main(void) { "a"; write("hello"); } void f(void) { string x; x = "argh"; }')
      ["a", "hello", "argh"].each_with_index do |v, i|
        expect(a.str_lit_exps[i].value).to eq(v)
        expect(a.str_lit_exps[i].label).to eq(".str#{i}")
      end
    end

    it "labels RelExps" do
      a = label('void main(void) { int x; x < 1; if(x == x) { 5 < 3; } }')
      body = a.declarations[0].body
      expect(body.stmts[0].exp.true_label).to eq(".rel0true")
      expect(body.stmts[0].exp.follow_label).to eq(".rel0follow")
      expect(body.stmts[1].condition.true_label).to eq(".rel1true")
      expect(body.stmts[1].condition.follow_label).to eq(".rel1follow")
      expect(body.stmts[1].body.stmts[0].exp.true_label).to eq(".rel2true")
      expect(body.stmts[1].body.stmts[0].exp.follow_label).to eq(".rel2follow")
    end
  end
end
