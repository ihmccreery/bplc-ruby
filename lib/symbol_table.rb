class SymbolTable
  attr_accessor :parent

  # @param parent [SymbolTable]
  def initialize(parent)
    @parent = parent
    @symbols = {}
    @fsymbols = {}
  end

  # @param name [String]
  # @param declaration [Declaration]
  def add_symbol(name, declaration)
    unless @symbols[name]
      @symbols[name] = declaration
    else
      raise SyntaxError, "#{name} has already been declared"
    end
  end

  # @param name [String]
  def get_symbol(name)
    if @symbols[name]
      return @symbols[name]
    elsif @parent
      return parent.get_symbol(name)
    else
      raise SyntaxError, "undeclared variable #{name}"
    end
  end

  # @param name [String]
  # @param declaration [Declaration]
  def add_fsymbol(name, declaration)
    unless @fsymbols[name]
      @fsymbols[name] = declaration
    else
      raise SyntaxError, "#{name} has already been declared"
    end
  end

  # @param name [String]
  def get_fsymbol(name)
    if @fsymbols[name]
      return @fsymbols[name]
    elsif @parent
      return parent.get_fsymbol(name)
    else
      raise SyntaxError, "undeclared function #{name}"
    end
  end
end
