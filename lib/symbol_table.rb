class SymbolTable
  attr_accessor :parent

  # @param parent [SymbolTable]
  def initialize(parent)
    @parent = parent
    @symbols = {}
  end

  # @param name [String]
  # @param declaration [Declaration]
  def add_symbol(name, declaration)
    unless @symbols[name]
      @symbols[name] = declaration
    else
      return false
    end
  end

  # @param name [String]
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
