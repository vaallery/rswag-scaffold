# frozen_string_literal: true

# require "rails/generators/generated_attribute.rb"

module Rails
  module Generators
    module PrependGeneratedAttribute
      ARRAY_OPTIONS = %w(array)

      def initialize(name, type = nil, index_type = false, attr_options = {})
        super
        @has_array = ARRAY_OPTIONS.include?(index_type)
      end
    end

    class GeneratedAttribute
      prepend PrependGeneratedAttribute

      def has_array?
        @has_array
      end
    end
  end
end
