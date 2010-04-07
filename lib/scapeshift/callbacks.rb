module Scapeshift

  ##
  # Abstract module to be included in custom Crawler options classes.
  # Allows for easy integration of callback hooks.
  #
  # @author Josh Lindsey
  #
  # @since 0.3.0
  #
  module Callbacks
    @@callbacks = {}

    class << self
      def included klass
        klass.class_eval <<-CLASS
          def self.has_callback_hook name
            @@callbacks[name] = []

            instance_eval <<-INST
              def #{name}_add block
                @callbacks[#{name.to_sym}] << block
              end

              def #{name}
                @callbacks[#{name.to_sym}].each do |block|
                  block.call self
                end
              end
            INST
          end
        CLASS
      end
    end
  end
end

