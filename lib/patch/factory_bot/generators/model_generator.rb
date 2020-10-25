# require 'factory_bot_rails'

require "generators/factory_bot"
require "factory_bot_rails"

# FactoryBot::Generators::Base

module FactoryBot
  module Generators
    module PrependModelGenerator
      def factory_attributes
        attributes.map do |attribute|
          # puts "#{attribute.name} : #{attribute.type} : #{attribute.has_array?}"
          if attribute.has_array?
            "#{attribute.name} { [#{attribute.default.inspect}] }"
          else
            "#{attribute.name} { #{attribute.default.inspect} }"
          end
        end.join("\n")
      end
    end

    class ModelGenerator < Base
      prepend PrependModelGenerator
    end
  end
end
