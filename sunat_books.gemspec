# frozen_string_literal: true
Gem::Specification.new do |s|
  s.name = "sunat_books"
  s.version = "0.0.1"
  s.summary = "SUNAT books"
  s.description = s.summary
  s.authors = ["César Carruitero"]
  s.email = ["cesar@mozilla.pe"]
  s.homepage = "https://github.com/ccarruitero/sunat_books"
  s.license = "MPL"

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency("prawn", "~> 2.0")
  s.add_runtime_dependency("prawn-table", "~> 0.2")
  s.add_runtime_dependency("i18n", "~> 0.7")
  s.add_runtime_dependency("activesupport", "> 4.1")

  s.add_development_dependency("cutest", "~> 1.2")
  s.add_development_dependency("pry", "~> 0.10")
  s.add_development_dependency("rubocop", "~> 0.48")
  s.add_development_dependency("pdf-inspector", "~> 1.2.0")
  s.add_development_dependency("faker", "~> 1.7")
end
