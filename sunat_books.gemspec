Gem::Specification.new do |s|
  s.name = "sunat_books"
  s.version = "0.0.1"
  s.summary = "SUNAT books"
  s.description = s.summary
  s.authors = ["César Carruitero"]
  s.email = ["cesar@mozilla.pe"]
  s.homepage = "https://github.com/ccarruitero/books"
  s.license = "MPL"

  s.files = `git ls-files`.split("\n")

  s.add_runtime_dependency "prawn"
  s.add_runtime_dependency "i18n"
  s.add_runtime_dependency "activesupport"

  s.add_development_dependency "cutest"
end
