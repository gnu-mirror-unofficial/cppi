# Customize maint.mk                           -*- makefile -*-
# Copyright (C) 2003-2011 Free Software Foundation, Inc.

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# Tests not to run as part of "make distcheck".
# Exclude changelog-check here so that there's less churn in ChangeLog
# files -- otherwise, you'd need to have the upcoming version number
# at the top of the file for each `make distcheck' run.
local-checks-to-skip = patch-check strftime-check check-AUTHORS
local-checks-to-skip += changelog-check

# The local directory containing the checked-out copy of gnulib used in this
# release.  Used solely to get gnulib's SHA1 for the "announcement" target.
gnulib_dir = /gnulib

# Now that we have better (check.mk) tests, make this the default.
export VERBOSE = yes

old_NEWS_hash = 33baa6cc170e88d0627ef86668414353

# Indent only with spaces.
sc_prohibit_tab_based_indentation:
	@prohibit='^ *	'						\
	halt='TAB in indentation; use only spaces'			\
	  $(_sc_search_regexp)

# Don't use "indent-tabs-mode: nil" anymore.  No longer needed.
sc_prohibit_emacs__indent_tabs_mode__setting:
	@prohibit='^( *[*#] *)?indent-tabs-mode:'			\
	halt='use of emacs indent-tabs-mode: setting'			\
	  $(_sc_search_regexp)

bootstrap-tools = autoconf,automake,flex,gnulib,gperf,help2man

include $(srcdir)/dist-check.mk

update-copyright-env = \
  UPDATE_COPYRIGHT_USE_INTERVALS=1 \
  UPDATE_COPYRIGHT_MAX_LINE_LENGTH=79

exclude_file_name_regexp--sc_prohibit_stat_st_blocks = ^src/system\.h$$
exclude_file_name_regexp--sc_prohibit_tab_based_indentation = \
  (Makefile(\.am)?|\.mk)$$
