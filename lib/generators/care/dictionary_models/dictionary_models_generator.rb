module Care
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../templates', __FILE__)

    def add_initializer
      ActiveRecord::Base.dictionaries.each do |dictionary|
        template("model.rb.tt", "models/dictionary/#{dictionary}.rb", context: {class_name: dictionary.classify})
      end
    end
  end
end
