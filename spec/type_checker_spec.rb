require 'spec_helper'

describe TypeChecker do
  describe "#initialize" do
    it "can be constructed from an Ast" do
      expect(TypeChecker.new(resolve("int x; void main(void) { x; }"))).to be_a TypeChecker
    end
  end

  describe "#type_check" do

    ########
    # main #
    ########

    describe "the main function" do
      it "raises a BplTypeError for a non-void type or args" do
        expect_type_error("main function must return void", 1) do
          type_check("int main(void) { }")
        end
        expect_type_error("main function must have void params", 1) do
          type_check("void main(int x) { }")
        end
      end
    end

    #########
    # Stmts #
    #########

    # no need to type-check the nodes below:
    # - CompoundStmt
    # - ExpStmt
    # - Return
    # - WritelnStmt

    describe "ConditionalStmt" do
      it "raises a BplTypeError for a non-int condition" do
        ['&x', '"a"', 'y', 'z', 'w'].each do |condition|
          expect_type_error("condition must be int", 2) do
            type_check("int x; string y; int *z; int w[2]; \n void main(void) { if(#{condition}) ; }")
          end
          expect_type_error("condition must be int", 2) do
            type_check("int x; string y; int *z; int w[2]; \n void main(void) { while(#{condition}) ; }")
          end
        end
      end
    end

    describe "WriteStmt" do
      it "raises a BplTypeError for a non-int, non-string value" do
        ['&x', '&y', 'z', 'w'].each do |value|
          expect_type_error("can only write int or string", 2) do
            type_check("int x; string y; int z[2]; string w[2]; \n void main(void) { write(#{value}); }")
          end
        end
      end
    end

    ########
    # Exps #
    ########

    describe "AssignmentExp" do
      it "are type-checked as int" do
        a = type_check("int x; int *y; int z[2]; void main(void) { x = 5; x = *y = z[0] = 10; x = *y; *y = z[1]; z[0] = x; }")

        body = a.declarations[3].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:int)
        end
      end

      it "are type-checked as string" do
        a = type_check('string x; string *y; string z[2]; void main(void) { x = "a"; x = *y = z[0] = "b"; x = *y; *y = z[1]; z[0] = x; }')

        body = a.declarations[3].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:string)
        end
      end

      it "are type-checked as pointer_int" do
        a = type_check("int x; int *y; int z[2]; int *w; void main(void) { y = &x; y = &z[0]; y = w = &z[1]; }")

        body = a.declarations[4].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:pointer_int)
        end
      end

      it "are type-checked as pointer_string" do
        a = type_check("string x; string *y; string z[2]; string *w; void main(void) { y = &x; y = &z[0]; y = w = &z[1]; }")

        body = a.declarations[4].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:pointer_string)
        end
      end

      it "raises a BplTypeError for array_int and array_string lhss" do
        expect_type_error("invalid assignment: cannot assign to array_int", 2) do
          type_check("int x[1]; int y[5]; \n void main(void) { x = y; }")
        end
        expect_type_error("invalid assignment: cannot assign to array_string", 2) do
          type_check("string x[1]; string y[5]; \n void main(void) { x = y; }")
        end
      end

      it "raises a BplTypeError if operands do not match" do
        expect_type_error("invalid assignment: cannot assign int to string", 2) do
          type_check("string x; \n void main(void) { x = 5; }")
        end
        expect_type_error("invalid assignment: cannot assign pointer_int to int", 2) do
          type_check("int x; int *y; \n void main(void) { x = y; }")
        end
      end
    end

    describe "RelExp" do
      it "are type-checked as int" do
        a = type_check("int x; int *y; void main(void) { x > 5; 5 == *y; -x != *y; x > -x % *y; }")

        body = a.declarations[2].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:int)
        end
      end

      it "raises a BplTypeError if bad operands are used" do
        expect_type_error("invalid lhs: cannot lt string", 2) do
          type_check("string x; \n void main(void) { x < 5; }")
        end
        expect_type_error("invalid rhs: cannot eq pointer_int", 2) do
          type_check("int x; \n void main(void) { 5 == &x; }")
        end
        expect_type_error("invalid rhs: cannot neq array_int", 2) do
          type_check("int x[10]; \n void main(void) { 2 != x; }")
        end
      end
    end

    describe "ArithmeticExp" do
      it "are type-checked as int" do
        a = type_check("int x; int *y; void main(void) { x + 5; 5 * *y; -x; x + -x % *y; }")

        body = a.declarations[2].body
        body.stmts.each do |s|
          expect(s.exp.type).to eq(:int)
        end
      end

      it "raises a BplTypeError if bad operands are used" do
        expect_type_error("invalid lhs: cannot plus string", 2) do
          type_check("string x; \n void main(void) { x + 5; }")
        end
        expect_type_error("invalid rhs: cannot slash pointer_int", 2) do
          type_check("int x; \n void main(void) { 5 / &x; }")
        end
        expect_type_error("invalid exp: cannot minus array_int", 2) do
          type_check("int x[10]; \n void main(void) { -x; }")
        end
      end
    end

    ###########
    # VarExps #
    ###########

    # Since the type checker is organized to handle different VarExps by their
    # *declaration's* type, not *their* type, the specs are organized the same
    # way.

    describe "SimpleDeclaration" do
      it "assigns the correct type" do
        a = type_check("int x; string y; void main(void) { x; y; &x; &y; }")

        body = a.declarations[2].body
        expect(body.stmts[0].exp.type).to eq(:int)
        expect(body.stmts[1].exp.type).to eq(:string)
        expect(body.stmts[2].exp.type).to eq(:pointer_int)
        expect(body.stmts[3].exp.type).to eq(:pointer_string)
      end

      it "raises a BplTypeError if bad operators are used" do
        expect_type_error("cannot dereference int", 2) do
          type_check("int x; \n void main(void) { *x; }")
        end
        expect_type_error("cannot index int", 2) do
          type_check("int x; \n void main(void) { x[1]; }")
        end
        expect_type_error("cannot index int", 2) do
          type_check("int x; \n void main(void) { &x[1]; }")
        end
      end
    end

    describe "PointerDeclaration" do
      it "assigns the correct type" do
        a = type_check("int *x; void main(void) { x; *x; }")

        body = a.declarations[1].body
        expect(body.stmts[0].exp.type).to eq(:pointer_int)
        expect(body.stmts[1].exp.type).to eq(:int)
      end

      it "raises a BplTypeError if bad operators are used" do
        expect_type_error("cannot reference pointer_int", 2) do
          type_check("int *x; \n void main(void) { &x; }")
        end
        expect_type_error("cannot index pointer_int", 2) do
          type_check("int *x; \n void main(void) { x[1]; }")
        end
        expect_type_error("cannot index pointer_int", 2) do
          type_check("int *x; \n void main(void) { &x[1]; }")
        end
      end
    end

    describe "ArrayDeclaration" do
      it "assigns the correct type" do
        a = type_check("int x[2]; void main(void) { x; x[1]; &x[1]; }")

        body = a.declarations[1].body
        expect(body.stmts[0].exp.type).to eq(:array_int)
        expect(body.stmts[1].exp.type).to eq(:int)
        expect(body.stmts[2].exp.type).to eq(:pointer_int)
      end

      it "raises a BplTypeError if bad operators are used" do
        expect_type_error("cannot dereference array_int", 2) do
          type_check("int x[2]; \n void main(void) { *x; }")
        end
        expect_type_error("cannot reference array_int", 2) do
          type_check("int x[2]; \n void main(void) { &x; }")
        end
      end
    end

    describe "FunctionDeclaration" do
      it "assigns the correct type" do
        a = type_check("int f(void) { } string g(void) { } void h(void) { } void main(void) { f(); g(); h(); }")

        body = a.declarations[3].body
        expect(body.stmts[0].exp.type).to eq(:int)
        expect(body.stmts[1].exp.type).to eq(:string)
        expect(body.stmts[2].exp.type).to eq(:void)
      end

      it "raises a BplTypeError if the wrong number of args is used" do
        expect_type_error("wrong number of arguments in call to f", 2) do
          type_check("int f(int x) { } \n void main(void) { f(); }")
        end
        expect_type_error("wrong number of arguments in call to f", 2) do
          type_check("int f(int x) { } \n void main(void) { f(5, 6); }")
        end
      end

      it "raises a BplTypeError if bad args are used" do
        expect_type_error("bad argument type in call to f: expected int, got string", 2) do
          type_check("int f(int x, string *y, int z[]) { } \n void main(void) { int x; string *y; int z[5]; f(\"hi\", y, z); }")
        end

        expect_type_error("bad argument type in call to f: expected pointer_string, got string", 2) do
          type_check("int f(int x, string *y, int z[]) { } \n void main(void) { int x; string *y; int z[5]; f(x, *y, z); }")
        end

        expect_type_error("bad argument type in call to f: expected array_int, got int", 2) do
          type_check("int f(int x, string *y, int z[]) { } \n void main(void) { int x; string *y; int z[5]; f(x, y, z[0]); }")
        end
      end
    end

    ###########
    # LitExps #
    ###########

    describe "LitExp" do
      it "assigns the correct type" do
        a = type_check('void main(void) { 2; "a"; read(); }')

        body = a.declarations[0].body
        expect(body.stmts[0].exp.type).to eq(:int)
        expect(body.stmts[1].exp.type).to eq(:string)
        expect(body.stmts[2].exp.type).to eq(:int)
      end
    end
  end
end
