# This is used by several rake tasks, that parameterize the
# behavior so we can use the same tests to test both the
# extension and non-extension versions.
def run_tests t, libr, test_filename_filter="test_*.rb"
  require 'test/unit/testsuite'
  require 'test/unit/ui/console/testrunner'

  runner = Test::Unit::UI::Console::TestRunner

  $eventmachine_library = libr
  $LOAD_PATH.unshift('tests')
  $stderr.puts "Checking for test cases:" #if t.verbose

  if test_filename_filter.is_a?(Array)
    test_filename_filter.each {|testcase|
      $stderr.puts "\t#{testcase}"
      load "tests/#{testcase}"
    }
  else
    Dir["tests/#{test_filename_filter}"].each do |testcase|
      $stderr.puts "\t#{testcase}" #if t.verbose
      load testcase
    end
  end

  suite = Test::Unit::TestSuite.new($name)

  ObjectSpace.each_object(Class) do |testcase|
    suite << testcase.suite if testcase < Test::Unit::TestCase
  end

  runner.run(suite)
end

desc "Run tests for #{Spec.name}."
task :test do |t|
  run_tests t, nil
end

namespace :test do
  desc "Run tests for #{Spec.name}."
  task :partial do |t|
    run_tests t, :extension, [
      "test_basic.rb",
      "test_epoll.rb",
      "test_errors.rb",
      "test_eventables.rb",
      "test_exc.rb",
      "test_futures.rb",
      "test_hc.rb",
      "test_httpclient2.rb",
      "test_httpclient.rb",
      "test_kb.rb",
      #"test_ltp2.rb",
      "test_ltp.rb",
      "test_next_tick.rb",
      "test_processes.rb",
      "test_pure.rb",
      "test_running.rb",
      "test_sasl.rb",
      #"test_send_file.rb",
      "test_servers.rb",
      "test_smtpclient.rb",
      "test_smtpserver.rb",
      "test_spawn.rb",
      "test_timers.rb",
      "test_ud.rb",
    ]
  end

  desc "Run pure-ruby tests for #$name."
  task :testpr do |t|
    run_tests t, :pure_ruby
  end

  desc "Run extension tests for #$name."
  task :testext do |t|
    run_tests t, :extension
  end

  desc "PROVISIONAL: run tests for user-defined events"
  task :ud do |t|
    run_tests t, :extension, "test_ud.rb"
  end

  desc "PROVISIONAL: run tests for line/text protocol handler"
  task :ltp do |t|
    run_tests t, :extension, "test_ltp*.rb"
  end

  desc "PROVISIONAL: run tests for header/content protocol handler"
  task :hc do |t|
    run_tests t, :extension, "test_hc.rb"
  end

  desc "PROVISIONAL: run tests for exceptions"
  task :exc do |t|
    run_tests t, :extension, "test_exc.rb"
  end

  desc "Test protocol handlers"
  task :protocols => [ :hc, :ltp ]


  desc "Test HTTP client"
  task :httpclient do |t|
    run_tests t, :extension, "test_httpclient.rb"
  end

  desc "Test HTTP client2"
  task :httpclient2 do |t|
    run_tests t, :extension, "test_httpclient2.rb"
  end

  desc "Test futures"
  task :futures do |t|
    run_tests t, :extension, "test_future*.rb"
  end

  desc "Test Timers"
  task :timers do |t|
    run_tests t, :extension, "test_timer*.rb"
  end

  desc "Test Next Tick"
  task :next_tick do |t|
    run_tests t, :extension, "test_next_tick*.rb"
  end

  desc "Test Epoll"
  task :epoll do |t|
    run_tests t, :extension, "test_epoll*.rb"
  end

  desc "Test Servers"
  task :servers do |t|
    run_tests t, :extension, "test_servers*.rb"
  end

  desc "Test Basic"
  task :basic do |t|
    run_tests t, :extension, "test_basic*.rb"
  end

  desc "Test Send File"
  task :send_file do |t|
    run_tests t, :extension, "test_send_file*.rb"
  end

  desc "Test Running"
  task :running do |t|
    run_tests t, :extension, "test_running*.rb"
  end

  desc "Test Keyboard Events"
  task :keyboard do |t|
    run_tests t, :extension, "test_kb*.rb"
  end

  desc "Test Spawn"
  task :spawn do |t|
    run_tests t, :spawn, "test_spawn*.rb"
  end

  desc "Test SMTP"
  task :smtp do |t|
    run_tests t, :extension, "test_smtp*.rb"
  end

  desc "Test Errors"
  task :errors do |t|
    run_tests t, :extension, "test_errors*.rb"
  end

  desc "Test Pure Ruby"
  task :pure do |t|
    run_tests t, :extension, "test_pure*.rb"
  end

  desc "Test Processes"
  task :processes do |t|
    run_tests t, :extension, "test_process*.rb"
  end

  desc "Test SASL"
  task :sasl do |t|
    run_tests t, :extension, "test_sasl*.rb"
  end
end