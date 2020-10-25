# frozen_string_literal: true

require "rswag/scaffold/version"

require 'rswag/specs'
require 'rswag/api'
require 'rswag/ui'
require 'rails/generators'
require 'patch/active_record/base'
require 'patch/rails/generators/generated_attribute'
require "patch/factory_bot/generators/model_generator"

module Rswag
  module Scaffold
    class Error < StandardError; end
    # Your code goes here...
  end
end
