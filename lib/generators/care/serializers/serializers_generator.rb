# frozen_string_literal: true
# !!!!!!!!!WIP!!!!!!!!!!!!! 3
require 'rswag/route_parser'
require 'rails/generators'

module Care
  class SerializersGenerator < ::Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

  end
end
