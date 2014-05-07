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

    it "labels IfStmts" do
      a = label('void main(void) { int x; if(x == x) { 5 < 3; } if(x < 5) { } }')
      body = a.declarations[0].body
      expect(body.stmts[0].else_label).to eq(".if0else")
      expect(body.stmts[0].follow_label).to eq(".if0follow")
      expect(body.stmts[1].else_label).to eq(".if1else")
      expect(body.stmts[1].follow_label).to eq(".if1follow")
    end

    it "labels WhileStmts" do
      a = label('void main(void) { int x; while(x == x) { x = 1; } while(x < 5) { } }')
      body = a.declarations[0].body
      expect(body.stmts[0].condition_label).to eq(".while0condition")
      expect(body.stmts[0].follow_label).to eq(".while0follow")
      expect(body.stmts[1].condition_label).to eq(".while1condition")
      expect(body.stmts[1].follow_label).to eq(".while1follow")
    end

    it "computes offsets for Params" do
      a = label('int f(int x, int y, string z) { }')
      params = a.declarations[0].params
      expect(params[0].offset).to eq(24)
      expect(params[1].offset).to eq(32)
      expect(params[2].offset).to eq(40)
    end

    describe "local variable offset computation" do
      it "computes local variable offsets" do
        a = label('void main(void) { int x; int y[5]; string z; }')
        declarations = a.declarations[0].body.variable_declarations
        expect(declarations[0].offset).to eq(-8)
        expect(declarations[1].offset).to eq(-48)
        expect(declarations[2].offset).to eq(-56)
      end

      it "correctly nests offsets" do
        a = label('void main(void) { int x; int y[5]; string z; if(1 < 2) { int a; string b; while(x) { int s; int t; } } }')
        main_body = a.declarations[0].body
        if_body = main_body.stmts[0].body
        while_body = if_body.stmts[0].body

        expect(main_body.variable_declarations[0].offset).to eq(-8)
        expect(main_body.variable_declarations[1].offset).to eq(-48)
        expect(main_body.variable_declarations[2].offset).to eq(-56)

        expect(if_body.variable_declarations[0].offset).to eq(-64)
        expect(if_body.variable_declarations[1].offset).to eq(-72)

        expect(while_body.variable_declarations[0].offset).to eq(-80)
        expect(while_body.variable_declarations[1].offset).to eq(-88)

        expect(a.declarations[0].local_variable_allocation).to eq(88)
      end

      it "correctly nests offsets at the same level and don't interfere with each other" do
        a = label('void main(void) { int x; int y[5]; string z; if(1 < 2) { int a; string b; int c; } while(x) { int r; int s; int t; } }')
        main_body = a.declarations[0].body
        if_body = main_body.stmts[0].body
        while_body = main_body.stmts[1].body

        expect(main_body.variable_declarations[0].offset).to eq(-8)
        expect(main_body.variable_declarations[1].offset).to eq(-48)
        expect(main_body.variable_declarations[2].offset).to eq(-56)

        expect(if_body.variable_declarations[0].offset).to eq(-64)
        expect(if_body.variable_declarations[1].offset).to eq(-72)
        expect(if_body.variable_declarations[2].offset).to eq(-80)

        expect(while_body.variable_declarations[0].offset).to eq(-64)
        expect(while_body.variable_declarations[1].offset).to eq(-72)
        expect(while_body.variable_declarations[2].offset).to eq(-80)

        expect(a.declarations[0].local_variable_allocation).to eq(80)
      end
    end
  end
end
