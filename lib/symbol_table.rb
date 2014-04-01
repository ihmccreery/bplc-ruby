class SymbolTable
  attr_accessor :parent

  def initialize(parent)
    @parent = parent
    @symbols = {}
  end

  def add_symbol(name, declaration)
    unless @symbols[name]
      @symbols[name] = declaration
    else
      raise SyntaxError, "#{name} is already declared"
    end
  end

  def get_symbol(name)
    if @symbols[name]
      return @symbols[name]
    elsif @parent
      return parent.get_symbol(name)
    else
      return nil
    end
  end
end
