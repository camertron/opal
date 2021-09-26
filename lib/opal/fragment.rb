# frozen_string_literal: true

module Opal
  # A fragment holds a string of generated javascript that will be written
  # to the destination. It also keeps hold of the original sexp from which
  # it was generated. Using this sexp, when writing fragments in order, a
  # mapping can be created of the original location => target location,
  # aka, source-maps!
  #
  # These are generated by nodes, so will not have to create directly.
  class Fragment
    # String of javascript this fragment holds
    # @return [String]
    attr_reader :code

    # Create fragment with javascript code and optional original [Opal::Sexp].
    #
    # @param code [String] javascript code
    # @param sexp [Opal::Sexp] sexp used for creating fragment
    def initialize(code, scope, sexp = nil)
      @code = code.to_s
      @sexp = sexp
      @scope = scope
    end

    # Inspect the contents of this fragment, f("fooo")
    def inspect
      "f(#{@code.inspect})"
    end

    def source_map_name_for(sexp)
      case sexp.type
      when :top
        case sexp.meta[:kind]
        when :require
          '<top (required)>'
        when :eval
          '(eval)'
        when :main
          '<main>'
        end
      when :begin, :newline, :js_return
        source_map_name_for(@scope.sexp) if @scope
      when :iter
        scope = @scope
        iters = 1
        while scope
          if scope.class == Nodes::IterNode
            iters += 1
            scope = scope.parent
          else
            break
          end
        end
        level = " (#{iters} levels)" if iters > 1
        "block#{level} in #{source_map_name_for(scope.sexp)}"
      when :self
        'self'
      when :module
        const, = *sexp
        "<module:#{source_map_name_for(const)}>"
      when :class
        const, = *sexp
        "<class:#{source_map_name_for(const)}>"
      when :const
        scope, name = *sexp
        if !scope || scope.type == :cbase
          name.to_s
        else
          "#{source_map_name_for(scope)}::#{name}"
        end
      when :int
        sexp.children.first
      when :def
        sexp.children.first
      when :defs
        sexp.children[1]
      when :send
        sexp.children[1]
      when :lvar, :lvasgn, :lvdeclare, :ivar, :ivasgn, :gvar, :cvar, :cvasgn, :gvars, :gvasgn, :arg
        sexp.children.first
      when :str, :xstr # Inside xstr - JS calls
        source_map_name_for(@scope.sexp)
      else
        # nil
      end
    end

    def source_map_name
      return nil unless @sexp

      source_map_name_for(@sexp)
    end

    def location
      case
      when !@sexp
        nil
      when @sexp.type == :send
        loc = @sexp.loc
        if loc.respond_to? :dot # a>.b || a>+b / >a / a>[b]
          loc.dot || loc.selector
        elsif loc.respond_to? :operator # a >|= b
          loc.operator
        else
          @sexp
        end
      when @sexp.type == :iter
        @sexp.loc.begin # [1,2].each >{ }
      else
        @sexp
      end
    end

    # Original line this fragment was created from
    # @return [Integer, nil]
    def line
      location&.line
    end

    # Original column this fragment was created from
    # @return [Integer, nil]
    def column
      location&.column
    end

    def skip_source_map?
      @sexp == false
    end
  end
end
