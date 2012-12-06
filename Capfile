begin
  require "rubygems"
  require "bundler"
rescue LoadError
  raise "Could not load the bundler gem. Install it with `gem install bundler`."
end

begin
  ENV["BUNDLE_GEMFILE"] = File.expand_path("../Gemfile", __FILE__)
  Bundler.setup
  # require "bundler/capistrano"

rescue Bundler::GemNotFound
  raise RuntimeError, "Bundler couldn't find some gems. Did you run `bundle install`?"
end


# Autoload all tasks
Dir["lib/*.rb"].each { |f| require File.expand_path(File.join(File.dirname(__FILE__),f)) }
Dir["tasks/*.rb"].each { |f| load f }
load 'deploy'
