require "bundler/gem_tasks"
require "rake/testtask"
require "yard"

# Configure standard test task
Rake::TestTask.new do |t|
  t.test_files = FileList.new(File.join("test", "**", "*_spec.rb"))
end

# Use YARD"s own Rake task to build documentation
YARD::Rake::YardocTask.new do |t|
  t.files   = [File.join("lib", "**", "*.rb"), "-", "README.md", "LICENSE.txt"]
  t.options = ["--main", "README.md", "--output-dir", "doc/html", "--title", "Rwtocore Documentation"]
end