# $Id$
#
# Author:: Francis Cianfrocca (gmail: blackhedd)
# Homepage::  http://rubyeventmachine.com
# Date:: 3 January 2008
# 
# See EventMachine and EventMachine::Connection for documentation and
# usage examples.
#
#----------------------------------------------------------------------------
#
# Copyright (C) 2006-08 by Francis Cianfrocca. All Rights Reserved.
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
# 


if RUBY_PLATFORM =~ /java/
	require 'java'
	require 'jem'
else
	if $eventmachine_library == :pure_ruby or ENV['EVENTMACHINE_LIBRARY'] == "pure_ruby"
		require 'pr_em'
	else
		require 'rubyem'
	end
end


require "em_version"

