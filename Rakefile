#!/usr/bin/env rake
#--
# Ruby/EventMachine
#   http://rubyeventmachine.com
#   Copyright (C) 2006-07 by Francis Cianfrocca
#
#   This program is copyrighted free software. You may use it under
#   the terms of either the GPL or Ruby's License. See the file
#   COPYING in the EventMachine distribution for full licensing
#   information.
#
# $Id$
#++
require 'rubygems'  unless defined?(Gem)
require 'rake'      unless defined?(Rake)
require 'rake/gempackagetask'

Package = true # Build zips and tarballs?

Spec = Gem::Specification.new do |s|
  s.name              = "eventmachine"
  s.summary           = "Ruby/EventMachine library"
  s.platform          = Gem::Platform::RUBY

  s.has_rdoc          = true
  s.rdoc_options      = %w(--title EventMachine --main README --line-numbers)
  s.extra_rdoc_files  = %w(
    README RELEASE_NOTES TODO
    LIGHTWEIGHT_CONCURRENCY SPAWNED_PROCESSES DEFERRABLES
    PURE_RUBY EPOLL KEYBOARD SMTP
    COPYING GNU LEGAL
  )

  s.files             = %w(Rakefile) + Dir.glob("{bin,tests,lib,ext,tasks}/**/*")

  s.require_path      = 'lib'

  s.test_file         = "tests/testem.rb"
  s.extensions        = "ext/extconf.rb"

  s.author            = "Francis Cianfrocca"
  s.email             = "garbagecat10@gmail.com"
  s.rubyforge_project = 'eventmachine'
  s.homepage          = "http://rubyeventmachine.com"

  # Pulled in from readme, as code to pull from readme was not working!
  # Might be worth removing as no one seems to use gem info anyway.
  s.description = <<-EOD
EventMachine implements a fast, single-threaded engine for arbitrary network
communications. It's extremely easy to use in Ruby. EventMachine wraps all
interactions with IP sockets, allowing programs to concentrate on the
implementation of network protocols. It can be used to create both network
servers and clients. To create a server or client, a Ruby program only needs
to specify the IP address and port, and provide a Module that implements the
communications protocol. Implementations of several standard network protocols
are provided with the package, primarily to serve as examples. The real goal
of EventMachine is to enable programs to easily interface with other programs
using TCP/IP, especially if custom protocols are required.
  EOD

  require 'lib/eventmachine_version'
  s.version = EventMachine::VERSION
  # s.requirements << 'Java' # TODO
end

Dir.glob('tasks/*.rake').each { |r| Rake.application.add_import r }

desc "Compile the extension."
task :build do |t|
  mkdir "nonversioned" unless File.directory?("nonversioned")
  chdir("nonversioned") do
    system "ruby ../ext/extconf.rb"
    system "make clean"
    system "make"
    Dir.glob('*.{so,bundle,dll,jar}').each do |f|
      cp f, "../lib"
    end
  end
end

# Basic clean definition, this is enhanced by imports aswell.
task :clean do
  Dir.glob('lib/*.{so,bundle,jar,dll}').each { |file| rm file }
  rm_rf 'nonversioned'
  Dir.glob('java/**/*.{class,jar}').each { |file| rm file }
end

### OLD RAKE: ###
# # The tasks and external gemspecs we used to generate binary gems are now
# # obsolete. Use Patrick Hurley's gembuilder to build binary gems for any
# # desired platform.
# # To build a binary gem on Win32, ensure that the include and lib paths
# # both contain the proper references to OPENSSL. Use the static version
# # of the libraries, not the dynamic, otherwise we expose the user to a
# # runtime dependency.
# 
# =begin
# # To build a binary gem for win32, first build rubyeventmachine.so
# # using VC6 outside of the build tree (the normal way: ruby extconf.rb,
# # and then nmake). Then copy rubyeventmachine.so into the lib directory,
# # and run rake gemwin32.
# =end
# 


JSpec = Spec.dup
JSpec.name = 'eventmachine-java'
JSpec.extensions = nil
JSpec.files << 'lib/em_reactor.jar'

Rake::GemPackageTask.new(JSpec) do end
desc "Build the EventMachine RubyGem for JRuby"
task :jgem => [:clean, :jar, "pkg/eventmachine-java-#{JSpec.version}.gem"]

namespace :jgem do
  desc "Build and install the jruby gem"
  task :install => :jgem do
    sudo "gem inst pkg/#{JSpec.name}*.gem"
  end
end


# This task creates the JRuby JAR file and leaves it in the lib directory.
# This step is required before executing the jgem task.
desc "Compile the JAR"
task :jar do |t|
  chdir('java/src') do
    sh 'javac com/rubyeventmachine/*.java'
    sh "jar -cf em_reactor.jar com/rubyeventmachine/*.class"
    mv 'em_reactor.jar', '../../lib/em_reactor.jar'
  end
end

# The idea for using Rakefile instead of extconf: task :default => [RUBY_PLATFORM == 'java' ? :jar : :extension]