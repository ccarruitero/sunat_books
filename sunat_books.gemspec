# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name = "sunat_books"
  s.version = "0.1.1"
  s.summary = "A ruby gem to get accounting books for SUNAT"
  s.description = s.summary
  s.authors = ["César Carruitero"]
  s.email = ["cesar@mozilla.pe"]
  s.homepage = "https://github.com/ccarruitero/sunat_books"
  s.license = "MPL"

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency("activesupport")
  s.add_runtime_dependency("i18n", "~> 1.8")
  s.add_runtime_dependency("prawn", "~> 2.0")
  s.add_runtime_dependency("prawn-table", "~> 0.2")

  s.add_development_dependency("cutest", "~> 1.2")
  s.add_development_dependency("faker", "~> 2.2")
  s.add_development_dependency("pdf-inspector", "~> 1.3.0")
  s.add_development_dependency("pry", "~> 0.10")
  s.add_development_dependency("rubocop", "~> 1.9")

  s.required_ruby_version = ">= 2.5.0"
end
