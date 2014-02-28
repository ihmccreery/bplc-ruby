module Parsers
  # a simple Parser that takes in a Scanner and builds a tree out of the successive tokens
  class RecursiveDescentParser

    def initialize(source)
      configure_source(source)
    end

    private

    ###################
    # support methods #
    ###################

    # source must either
    #   be a Scanner
    #   respond to #next_token and #current_token
    def configure_source(source)
      @source = source
    end

    def next_token
      @source.next_token
    end

    def current_token
      @source.current_token
    end
  end
end
