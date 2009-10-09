# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{loom-exceptions-rails-plugin}
  s.version = "2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex R. Young"]
  s.date = %q{2009-07-18}
  s.description = %q{Loom is a helpdesk web app which supports exception handling and notifications.}
  s.email = %q{alex@alexyoung.org}
  s.files = ["init.rb", "install.rb", "lib", "lib/loom.rb", "lib/loom_exception.rb", "loom-exceptions-rails-plugin.gemspec", "MIT-LICENSE", "Rakefile", "README.textile", "tasks", "tasks/loom_tasks.rake", "test", "test/exception_test.rb", "test/loom_test.rb", "uninstall.rb"]
  s.has_rdoc = false
  s.homepage = %q{http://loomapp.com}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.0}
  s.summary = %q{This gem provides exception notification handling for your Rails applications.}
end

