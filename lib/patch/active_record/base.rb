require_relative 'concerns/swagger_schema'

class ActiveRecord::Base
  include SwaggerSchema

  def self.dump_fixture
    fixture_file = "#{Rails.root}/spec/fixtures/#{table_name}.yml"
    File.open(fixture_file, "a+") do |f|
      self.all.each do |row|
        f.puts({ "#{table_name.singularize}_#{row.id}" => row.attributes }.to_yaml.sub!(/---\s?/, "\n"))
      end
    end
    fixture_file
  end

  def self.dictionaries
    @dictionaries ||= ActiveRecord::Base.connection.tables.map{|t| /dictionary_(.*)/.match(t)&.[](1)}.compact.map(&:classify)
  end

  def self.dictionary_models
    dictionaries.map{|d| "Dictionary::#{d}".constantize}
  end

  def self.dump_dictionary_fixtures
    dictionary_models.map { |model| model.dump_fixture }
  end

  # Для вставки в метод контроллера
  # TODO отрефакторить
  def self.references
    str = "{\n"
    str += ActiveRecord::Base.connection.tables.map{|t| /dictionary_(.*)/.match(t)&.[](1)}.compact.reduce(''){|h,t| h + "  #{t}: #{t.classify}.all.as_json,\n"}
    str += "}\n"
    str
  end

  # Для вставки в тест метода
  # TODO отрефакторить
  def references_schema
    ActiveRecord::Base.connection.tables.map{|t| /dictionary_(.*)/.match(t)&.[](1)}.compact.reduce(''){|h,t| h + "  #{t}: {\"$ref\": \"#/components/schemas/Dictionary\"},\n"}
  end

  def self.swagger_schema_content
    schema = ''
    schema += "    #{name}:\n"
    schema += "      required: [#{columns.select{|i| !i.null}.map(&:name).join(',')}]\n"
    schema += "      properties:\n"
    columns.each do |c|
      schema += "        #{c.name}:\n"
      schema += "          description: '#{c.comment}'\n"
      schema += "          readOnly: true\n" if c.name == 'id' or c.name.end_with? "_at"
      schema += "          type: #{swagger_schema_type(c)}\n" unless c.array
      schema += "          format: #{swagger_schema_format(c)}\n" if swagger_schema_format(c)&&!c.array
      schema += "          type: array\n" if c.array
      schema += "          items:\n" if c.array
      schema += "            type: #{swagger_schema_type(c)}\n" if c.array
      schema += "            format: #{swagger_schema_format(c)}\n" if swagger_schema_format(c)&&c.array
    end
    schema
  end

  private

  def self.swagger_schema_type(column)
    type = case column.type.to_sym
           when :uuid, :string, :date, :datetime
             'string'
           when :integer, :float
             'number'
           when :boolean
             'boolean'
           when :jsonb
             'object'
           else
             column.type.to_s
           end
    type = "[#{type},null]" if column.null
    type
  end

  def self.swagger_schema_format(column)
    case column.type.to_sym
    when :uuid, :date
      column.type.to_s
    when :datetime
      'date-time'
    else
      nil
    end
  end

end
