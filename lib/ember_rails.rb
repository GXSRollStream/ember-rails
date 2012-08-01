require 'ember/rails/version'
require 'ember/version'
require 'ember/handlebars/version'
require 'ember/rails/engine'

module Ember
  module Rails
    class Railtie < ::Rails::Railtie
      config.ember = ActiveSupport::OrderedOptions.new

      initializer "ember_rails.setup_vendor", :after => "ember_rails.setup", :group => :all do |app|
        # Add the gem's vendored ember to the end of the asset search path
        if variant = app.config.ember.variant
          ember_path = app.root.join("vendor/assets/ember/#{variant}")
          app.config.assets.paths.unshift(ember_path.to_s) if ember_path.exist?
        else
          warn "No ember.js variant was specified in your config environment."
          warn "You can set a specific variant in your application config in "
          warn "order for sprockets to locate ember's assets:"
          warn ""
          warn "    config.ember.variant = :development"
          warn ""
          warn "Valid values are :development and :production"
        end
      end

      initializer "ember_rails.find_ember", :after => "ember_rails.setup_vendor", :group => :all do |app|
        config.ember.ember_location = location_for(app, "ember.js")
        config.ember.handlebars_location = location_for(app, "handlebars.js")
      end

      def location_for(app, file)
        path = app.config.assets.paths.find do |dir|
          Pathname.new(dir).join(file).exist?
        end

        File.join(path, file) if path
      end
    end
  end
end
