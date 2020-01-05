require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "ext"
  t.libs << "lib"
  t.test_files = FileList["test/*_test.rb", "test/layers_test/*_test.rb"]
end

task :build_rb_stb_image do
  sh "cd ext/rb_stb_image; ruby extconf.rb; make"
end

task :clean_rb_stb_image do
  sh "cd ext/rb_stb_image; make clean; unlink Makefile"
end

task :default => [:test, :build_rb_stb_image]

task :doc do
  src_list = Dir["lib/dnn.rb"]
  src_list += Dir["lib/dnn/core/*.rb"]
  src_list += Dir["lib/dnn/core/layers/*.rb"]
  src_list += Dir["lib/dnn/*.rb"]
  sh "yardoc #{src_list.join(' ')}"
end
