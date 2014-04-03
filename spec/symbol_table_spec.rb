describe SymbolTable do
  let(:g) { SymbolTable.new(nil) }

  context "with no parent SymbolTable" do
    describe "#initialize" do
      it "is a SymbolTable" do
        expect(g).to be_a SymbolTable
      end
    end

    describe "#parent" do
      it "returns nil" do
        expect(g.parent).to be_nil
      end
    end
  end

  context "with a parent SymbolTable" do
    let(:s) { SymbolTable.new(g) }

    describe "#initialize" do
      it "is a SymbolTable" do
        expect(s).to be_a SymbolTable
      end
    end

    describe "#parent" do
      it "returns the parent" do
        expect(s.parent).to eq(g)
      end
    end
  end

  describe "#add_symbol" do
    it "adds a symbol" do
      g.add_symbol("a", :a)
      expect(g.get_symbol("a")).to eq(:a)
    end

    it "throws an error if we try to add another symbol with the same name" do
      g.add_symbol("a", :a)
      expect{g.add_symbol("a", :t)}.to raise_error(SyntaxError, "a has already been declared")
    end

    it "does not throw an error if we try to add another symbol with the same name as one in a parent" do
      g.add_symbol("a", :a)
      s = SymbolTable.new(g)
      expect{s.add_symbol("a", :a)}.not_to raise_error
    end
  end

  describe "#get_symbol" do
    it "gets a symbol" do
      g.add_symbol("a", :a)
      expect(g.get_symbol("a")).to eq(:a)
    end

    it "raises an error if a symbol is not declared" do
      expect{g.get_symbol("a")}.to raise_error(SyntaxError, "undeclared variable a")
    end

    it "gets a symbol from the parent" do
      g.add_symbol("a", :a)
      s = SymbolTable.new(g)
      expect(s.get_symbol("a")).to eq(:a)
    end

    it "gets a symbol from the parent's parent" do
      g.add_symbol("a", :a)
      s = SymbolTable.new(g)
      t = SymbolTable.new(s)
      expect(t.get_symbol("a")).to eq(:a)
    end
  end

  describe "#add_fsymbol" do
    it "adds a fsymbol" do
      g.add_fsymbol("a", :a)
      expect(g.get_fsymbol("a")).to eq(:a)
    end

    it "throws an error if we try to add another fsymbol with the same name" do
      g.add_fsymbol("a", :a)
      expect{g.add_fsymbol("a", :t)}.to raise_error(SyntaxError, "a has already been declared")
    end

    it "does not throw an error if we try to add another fsymbol with the same name as one in a parent" do
      g.add_fsymbol("a", :a)
      s = SymbolTable.new(g)
      expect{s.add_fsymbol("a", :a)}.not_to raise_error
    end
  end

  describe "#get_fsymbol" do
    it "gets a fsymbol" do
      g.add_fsymbol("a", :a)
      expect(g.get_fsymbol("a")).to eq(:a)
    end

    it "raises an error if a fsymbol is not declared" do
      expect{g.get_fsymbol("a")}.to raise_error(SyntaxError, "undeclared function a")
    end

    it "gets a fsymbol from the parent" do
      g.add_fsymbol("a", :a)
      s = SymbolTable.new(g)
      expect(s.get_fsymbol("a")).to eq(:a)
    end

    it "gets a fsymbol from the parent's parent" do
      g.add_fsymbol("a", :a)
      s = SymbolTable.new(g)
      t = SymbolTable.new(s)
      expect(t.get_fsymbol("a")).to eq(:a)
    end
  end
end
