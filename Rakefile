require "orderly_garden"
OrderlyGarden.init!

require "bundler/gem_tasks"

require "rake/testtask"
Rake::TestTask.new(:test) do |test|
  test.libs << "lib" << "test"
  test.pattern = "test/**/test_*.rb"
  test.verbose = true
end

lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

task_dir        = File.expand_path("../tasks", __FILE__)
raw_task_files  = FileList["#{task_dir}/**/*.rake"] +
                  FileList["tasks/**/*.rake"]
raw_task_files
  .map { |fname| File.expand_path(fname) }
  .sort
  .each do |fname|
    load fname
  end

# Define a task named `name` that runs all tasks under an identically
# named `namespace`.
def parent_task(name)
  task name do
    ::Rake::Task
      .tasks
      .select { |t| t.name =~ /^#{name}:/ }
      .sort { |a, b| a.name <=> b.name }
      .each(&:execute)
  end
end

desc "Open a Ruby console to Pry."
task :console do
  # rubocop:disable Lint/Debugger
  require "pry"
  binding.pry
  # rubocop:enable Lint/Debugger
end

namespace :lint do
  desc "Run Rubocop against the codebase."
  task :rubocop do
    require "yaml"
    sh "rubocop --display-cop-names"
  end

  desc "Run bundler-audit against the Gemfile."
  task :'bundler-audit' do
    require "bundler/audit/cli"

    %w(update check).each do |command|
      Bundler::Audit::CLI.start [command]
    end
  end

  have_cloc = `which cloc`.strip != ""
  if have_cloc
    desc "Show LOC metrics for project using cloc."
    task :cloc do
      sh "cloc . --exclude-dir=pkg,.bundle,tmp"
    end
  end

  desc "Check for outdated gems."
  task :bundler do
    # Don't error-out if this fails, since we may not be able to update some
    # deps.
    sh "bundle outdated || true"
  end
end

desc "Run all lint checks against the code."
parent_task :lint

task default: [:test, :lint]
