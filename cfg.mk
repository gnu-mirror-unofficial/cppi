# Customize maint.mk                           -*- makefile -*-
# Copyright (C) 2003-2013 Free Software Foundation, Inc.

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

# Use the direct link.  This is guaranteed to work immediately, while
# it can take a while for the faster mirror links to become usable.
url_dir_list = http://ftp.gnu.org/gnu/$(PACKAGE)

# Now that we have better (check.mk) tests, make this the default.
export VERBOSE = yes

old_NEWS_hash = e917bc1270c3a14ebf7ce8b17ab297bf

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

-include $(srcdir)/dist-check.mk

update-copyright-env = \
  UPDATE_COPYRIGHT_USE_INTERVALS=1 \
  UPDATE_COPYRIGHT_MAX_LINE_LENGTH=79

_hv_regex_strong ?= ^ *\. "\$${top_srcdir=\.}/tests/init\.sh"

exclude_file_name_regexp--sc_prohibit_stat_st_blocks = ^src/system\.h$$
exclude_file_name_regexp--sc_prohibit_tab_based_indentation = \
  (Makefile(\.am)?|\.mk)$$

# Tell the tight_scope rule that yacc-related yy* names are extern.
export _gl_TS_unmarked_extern_functions = main usage yy.*
export _gl_TS_unmarked_extern_vars = yy.*
