module Delayed
  class PerformableMethod
    attr_accessor :object, :method_name, :args, :kwargs

    def initialize(object, method_name, args = nil, kwargs = nil)
      raise NoMethodError, "undefined method `#{method_name}' for #{object.inspect}" unless object.respond_to?(method_name, true)

      if object.respond_to?(:persisted?) && !object.persisted?
        raise(ArgumentError, "job cannot be created for non-persisted record: #{object.inspect}")
      end

      self.object       = object
      self.args         = args
      self.kwargs       = kwargs
      self.method_name  = method_name.to_sym
    end

    def display_name
      if object.is_a?(Class)
        "#{object}.#{method_name}"
      else
        "#{object.class}##{method_name}"
      end
    end

    def perform
      if RUBY_VERSION >= '3.0'
        ruby3_perform
      else
        ruby2_perform
      end
    end

    def method(sym)
      object.method(sym)
    end

    method_def = []
    location = caller_locations(1, 1).first
    file = location.path
    line = location.lineno
    definition = RUBY_VERSION >= '2.7' ? '...' : '*args, &block'
    method_def <<
      "def method_missing(#{definition})" \
      "  object.send(#{definition})" \
      'end'
    module_eval(method_def.join(';'), file, line)
    # rubocop:enable MethodMissing

    def respond_to?(symbol, include_private = false)
      super || object.respond_to?(symbol, include_private)
    end

    private

    def ruby2_perform
      return unless object

      if args && !args.empty?
        object.send(method_name, *args, kwargs)
      elsif kwargs && !kwargs.empty?
        object.send(method_name, kwargs)
      else
        object.send(method_name)
      end
    end

    def ruby3_perform
      object.send(method_name, *args, **kwargs) if object
    end
  end
end
