module Delayed
  class PerformableMethod
    attr_accessor :object, :method_name, :args
    attr_writer :kwargs

    def initialize(object, method_name, args, kwargs = {})
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

    def kwargs
      # Default to a hash so that we can handle deserializing jobs that were
      # created before kwargs was available.
      @kwargs || {}
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

    definition = RUBY_VERSION >= '2.7' ? '...' : '*args, &block'
    module_eval <<-RUBY, __FILE__, __LINE__ + 1
      def method_missing(#{definition})
        object.send(#{definition})
      end
    RUBY
    # rubocop:enable MethodMissing

    def respond_to?(symbol, include_private = false)
      super || object.respond_to?(symbol, include_private)
    end

    private

    def ruby2_perform
      # In ruby 2, rely on the implicit conversion from a hash to kwargs
      return unless object
      if kwargs.present?
        object.send(method_name, *args, kwargs)
      else
        object.send(method_name, *args)
      end
    end

    def ruby3_perform
      # In ruby 3 we need to explicitly separate regular args from the keyword-args.
      object.send(method_name, *args, **kwargs) if object
    end
  end
end
