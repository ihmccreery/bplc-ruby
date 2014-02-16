require 'stringio'

class Scanner
  # takes `source` as an argument
  def initialize(source)
    @source = configure_source(source)
  end

  private

  # source must either
  #   be a String (in which case we construct a StringIO object)
  #   be a File (in which case we construct an IO object)
  #   respond to #getc
  def configure_source(source)
    if source.is_a? String
      StringIO.new(source)
    elsif source.is_a? File
      open(source)
    else
      source
    end
  end
end
