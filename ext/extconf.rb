# $Id$
#
#----------------------------------------------------------------------------
#
# Copyright (C) 2006-07 by Francis Cianfrocca. All Rights Reserved.
# Gmail: blackhedd
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of either: 1) the GNU General Public License
# as published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version; or 2) Ruby's License.
# 
# See the file COPYING for complete licensing information.
#
#---------------------------------------------------------------------------
#
# extconf.rb for Ruby/EventMachine
# We have to munge LDSHARED because this code needs a C++ link.
#

def check_libs libs = [], fatal = false
  libs.all? { |lib| have_library(lib) || (abort("could not find library: #{lib}") if fatal) }
end

def check_heads heads = [], fatal = false
  heads.all? { |head| have_header(head) || (abort("could not find header: #{head}") if fatal)}
end

require 'mkmf'

flags = ['-D BUILD_FOR_RUBY']

# Minor platform details between *nix and Windows:

if RUBY_PLATFORM =~ /(mswin|mingw|bccwin)/
  GNU_CHAIN = true if $1 == 'mingw'
  OS_WIN32 = true
  flags << "-D OS_WIN32"
else
  GNU_CHAIN = true
  OS_UNIX = true
  flags << '-D OS_UNIX'
  if have_header("sys/event.h") and have_header("sys/queue.h")
    flags << "-DHAVE_KQUEUE"
  end
  check_libs(%w[pthread], true)  
end

# Main platform invariances:

case RUBY_PLATFORM.split('-',2)[1]
when 'mswin32', 'mingw32', 'bccwin32'
  check_heads(%w[windows.h winsock.h], true)
  check_libs(%w[kernel32 rpcrt4 gdi32], true)

  unless GNU_CHAIN
    flags << "-EHs"
    flags << "-GR"
  end

when /solaris/
  check_libs(%w[nsl socket], true)

  flags << '-D OS_SOLARIS8'

  # on Unix we need a g++ link, not gcc.
  CONFIG['LDSHARED'] = "$(CXX) -shared"

  # Patch by Tim Pease, fixes SUNWspro compile problems.
  if CONFIG['CC'] == 'cc'
    $CFLAGS = CONFIG['CFLAGS'] = "-g -O2 -fPIC"
    CONFIG['CCDLFLAGS'] = "-fPIC"
  end

when /openbsd/  
  # OpenBSD branch contributed by Guillaume Sellier.
   
  # on Unix we need a g++ link, not gcc. On OpenBSD, linking against libstdc++ have to be explicitly done for shared libs
  CONFIG['LDSHARED'] = "$(CXX) -shared -lstdc++"

when /darwin/

  # on Unix we need a g++ link, not gcc.
  # Ff line contributed by Daniel Harple.
  CONFIG['LDSHARED'] = "$(CXX) " + CONFIG['LDSHARED'].split[1..-1].join(' ')

when /linux/

  # Original epoll test is inadequate because 2.4 kernels have the header
  # but not the code.
  #flags << '-DHAVE_EPOLL' if have_header('sys/epoll.h')
  if have_header('sys/epoll.h')
	  File.open("hasEpollTest.c", "w") {|f|
		  f.puts "#include <sys/epoll.h>"
		  f.puts "int main() { epoll_create(1024); return 0;}"
	  }
	  (e = system( "gcc hasEpollTest.c -o hasEpollTest " )) and (e = $?.to_i)
	  `rm -f hasEpollTest.c hasEpollTest`
	  flags << '-DHAVE_EPOLL' if e == 0
  end

  if have_func('rb_thread_blocking_region') and have_macro('RB_UBF_DFL', 'ruby.h')
	  flags << "-DHAVE_TBR"
  end

  # on Unix we need a g++ link, not gcc.
  CONFIG['LDSHARED'] = "$(CXX) -shared"

  # Modify the mkmf constant LINK_SO so the generated shared object is stripped.
  # You might think modifying CONFIG['LINK_SO'] would be a better way to do this,
  # but it doesn't work because mkmf doesn't look at CONFIG['LINK_SO'] again after
  # it initializes.
  LINK_SO.replace(LINK_SO + "; strip $@")
  
else
  # on Unix we need a g++ link, not gcc.
  CONFIG['LDSHARED'] = "$(CXX) -shared"
end

# OpenSSL:

OPENSSL_LIBS_HEADS_PLATFORMS = {
  :unix => [%w[ssl crypto], %w[openssl/ssl.h openssl/err.h]],
  :darwin => [%w[ssl crypto C], %w[openssl/ssl.h openssl/err.h]],
  # openbsd and linux:
  :crypto_hack => [%w[crypto ssl crypto], %w[openssl/ssl.h openssl/err.h]],
  :mswin => [%w[ssleay32 libeay32], %w[openssl/ssl.h openssl/err.h]],
}

dc_flags = ['ssl']
dc_flags += ["#{ENV['OPENSSL']}/include", ENV['OPENSSL']] if /linux/ =~ RUBY_PLATFORM
libs, heads = case RUBY_PLATFORM
when /mswin/    : OPENSSL_LIBS_HEADS_PLATFORMS[:mswin]
when /mingw/    : OPENSSL_LIBS_HEADS_PLATFORMS[:unix]
when /darwin/   : OPENSSL_LIBS_HEADS_PLATFORMS[:darwin]
when /openbsd/  : OPENSSL_LIBS_HEADS_PLATFORMS[:crypto_hack]
when /linux/    : OPENSSL_LIBS_HEADS_PLATFORMS[:crypto_hack]
else              OPENSSL_LIBS_HEADS_PLATFORMS[:unix]
end
dir_config(*dc_flags)
have_openssl = check_libs(libs) and check_heads(heads)
flags << "-D #{have_openssl ? "WITH_SSL" : "WITHOUT_SSL"}"

# Finally, seal up flags and write Makefile

if $CPPFLAGS
  $CPPFLAGS += ' ' + flags.join(' ')
else
  $CFLAGS += ' ' + flags.join(' ')
end

create_makefile "rubyeventmachine"
