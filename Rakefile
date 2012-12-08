require "bundler"
Bundler.setup

gemspec = eval(File.read("provise.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["provise.gemspec"] do
  system "gem build provise.gemspec"
end
