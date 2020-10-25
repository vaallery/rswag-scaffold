# frozen_string_literal: true

require 'rails/generators'
require 'patch/rails/generators/generated_attribute'
require 'patch/factory_bot/generators/model_generator'

module Care
  class ScaffoldGenerator < Rails::Generators::NamedBase # :nodoc:
    include Rails::Generators::ResourceHelpers
    include Rails::Generators::AppName

    source_root File.expand_path('../templates', __FILE__)

    check_class_collision suffix: "Controller"

    class_option :orm, banner: "NAME", type: :string, required: true,
                       desc: "ORM to generate the controller for"

    def create_controller_files
      template("finder.rb.erb", File.join("app/finders", controller_class_path, "#{controller_file_name}_finder.rb"))
      template("serializer.rb.erb", File.join("app/serializers", controller_class_path, "#{file_name}_serializer.rb"))
      template("api_controller.rb.erb", File.join("app/controllers", controller_class_path, "#{controller_file_name}_controller.rb"))
      insert_into_file("spec/support/#{app_name}.yml", schema_content, after: "schemas:\n")
      route("resources :#{plural_name}")
    end

    def install_components
      generate 'factory_bot:model', class_name, *attrs
    end

    private
    def attributes_names # :doc:
      @attributes_names ||= get_model_attributes.each_with_object([]) do |a, names|
        names << a.column_name
        names << "password_confirmation" if a.password_digest?
        names << "#{a.name}_type" if a.polymorphic?
      end
    end

    def permitted_params
      attachments, others = attributes_names.partition { |name| attachments_or_array?(name) }
      params = others.map { |name| ":#{name}" }
      params += attachments.map { |name| "#{name}: []" }
      params.join(", ")
    end

    def attachments_or_array?(name)
      attribute = @attributes.find { |attr| attr.name == name }
      attribute&.attachments? || attribute&.has_array?
    end

    def attrs
      # don't edit id, foreign keys (*_id), timestamps (*_at)
      @attrs ||= model.columns.reject do |a|
        n = a.name
        n == "id" or n.end_with? "_at" # or n.end_with? "_id"
      end .map do |a|
        # name:type just like command line
        # name:type:array just like command line
        attr = [a.name,a.type.to_s]
        attr << 'array' if a.array
        attr.join(':')
      end
    end

    def model
      class_name.to_s.constantize
    end

    def model_name
      model.name
    end

    def schema_content
      schema = ''
      schema += "    #{model.name}:\n"
      schema += "      properties:\n"
      model.columns.each do |c|
        schema += "        #{c.name}:\n"
        schema += "          description: '#{c.comment}'\n"
        schema += "          readOnly: true\n" if c.name == 'id' or c.name.end_with? "_at"
        schema += "          type: #{schema_type(c)}\n" unless c.array
        schema += "          format: #{schema_format(c)}\n" if schema_format(c)&&!c.array
        schema += "          type: array\n" if c.array
        schema += "          items:\n" if c.array
        schema += "            type: #{schema_type(c)}\n" if c.array
        schema += "            format: #{schema_format(c)}\n" if schema_format(c)&&c.array
      end
      schema
    end

    def schema_type(column)
      type = case column.type.to_sym
             when :uuid, :string, :date, :datetime
               'string'
             when :integer, :float
               'number'
             when :boolean
               'boolean'
             else
               column.type.to_s
             end
      type = "[#{type},null]" if column.null
      type
    end

    def schema_format(column)
      case column.type.to_sym
      when :uuid, :date
        column.type.to_s
      when :datetime
        'date-time'
      else
        nil
      end
    end

    def get_model_attributes
      @attributes = attrs.map { |attr| Rails::Generators::GeneratedAttribute.parse(attr) }
    rescue => ex
      puts ex
      puts "problem with model #{class_name}"
      return nil
    end
  end
end
