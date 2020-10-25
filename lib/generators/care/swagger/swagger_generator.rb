# frozen_string_literal: true

require 'rswag/route_parser'
require 'rails/generators'

module Care
  class SwaggerGenerator < ::Rails::Generators::NamedBase
    include Rails::Generators::ResourceHelpers

    source_root File.expand_path('templates', __dir__)

    def create_spec_file
      template 'spec.rb.erb', File.join('spec', 'requests', "#{plural_file_name}_spec.rb")
    end

    private

    def controller_path
      file_path.chomp('_controller')
    end
  end
end
