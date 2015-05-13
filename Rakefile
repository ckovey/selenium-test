# encoding: UTF-8

require 'rubygems'
require 'rake/testtask'
require 'parallel'
require 'json'

@browsers = JSON.load(open('browsers.json'))
@test_folder = "tests/*.rb"
@parallel_limit = ENV["nodes"] || 1
@parallel_limit = @parallel_limit.to_i

task :test do
  current_browser = ""
  begin
    Parallel.map(@browsers, :in_threads => @parallel_limit) do |browser|
      current_browser = browser
      puts "Running with: #{browser.inspect}"
      ENV['SELENIUM_BROWSER'] = browser['browser']
      ENV['SELENIUM_VERSION'] = browser['browser_version']
      ENV['BS_AUTOMATE_OS'] = browser['os']
      ENV['BS_AUTOMATE_OS_VERSION'] = browser['os_version']
      Dir.glob(@test_folder).each do |test_file|
        puts "Running: #{test_file}"
        client = test_file.match(/tests\/(\w+)\.rb/).captures
        output_file = 'results/' + client[0] + '_' + browser['browser'] + browser['browser_version'] + ".xml"
        IO.popen("rspec #{test_file} --format RspecJunitFormatter --out #{output_file}") do |io|
          io.each do |line|
            puts line
          end
        end
      end
    end
  rescue SystemExit, Interrupt
    puts "User stopped script!"
    puts "Failed to run tests for #{current_browser.inspect}"
  end
end

task :default => [:test]



