# frozen_string_literal: true

require "i18n"

I18n.load_path << "#{File.dirname(__FILE__)}/locales/es.yml"
I18n.default_locale = :es
