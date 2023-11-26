# backtick_javascript: true
# use_strict: true

class Enumerator
  class Yielder
    def initialize(&block)
      @block = block
      # rubocop:disable Lint/Void
      self
      # rubocop:enable Lint/Void
    end

    def yield(*values)
      %x{
        var value = Opal.yieldX(#{@block}, values);

        if (value && value.$thrower_type == "break") {
          throw value;
        }

        return value;
      }
    end

    def <<(value)
      self.yield(value)

      self
    end

    def to_proc
      proc do |*values|
        self.yield(*values)
      end
    end
  end
end
