# gwl - Workflow management extension for GNU Guix
# Copyright © 2017, 2018 Roel Janssen <roel@gnu.org>
#
# This program is free software: you can redistribute it and/or
# modify it under the terms of the GNU Affero General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.

include guile.am

moddir=$(prefix)/share/guile/site/@GUILE_EFFECTIVE_VERSION@
godir=$(libdir)/guile/@GUILE_EFFECTIVE_VERSION@/site-ccache

SOURCES =                                                 \
  gnu/processes.scm                                       \
  gnu/workflows.scm                                       \
  guix/process-engines.scm                                \
  guix/process-engines/bash-engine.scm                    \
  guix/process-engines/grid-engine.scm                    \
  guix/process-engines/simple-engine.scm                  \
  guix/processes.scm                                      \
  guix/scripts/process.scm                                \
  guix/scripts/workflow.scm                               \
  guix/workflows.scm                                      \
  guix/workflows/execution-order.scm                      \
  guix/workflows/graph.scm                                \
  guix/workflows/utils.scm                                \
  gwl/web-interface.scm                                   \
  gwl/www/config.scm                                      \
  gwl/www/pages.scm                                       \
  gwl/www/pages/beyond-started.scm                        \
  gwl/www/pages/error.scm                                 \
  gwl/www/pages/extended-start.scm                        \
  gwl/www/pages/getting-started.scm                       \
  gwl/www/pages/welcome.scm                               \
  gwl/www/pages/workflow-viewer.scm                       \
  gwl/www/util.scm

assetsdir = $(prefix)/share/@PACKAGE@
nobase_dist_assets_DATA =                                 \
  gwl/static/css/main.css                                 \
  gwl/static/fonts/FiraMono-Regular.ttf                   \
  gwl/static/fonts/Roboto-Bold.ttf                        \
  gwl/static/fonts/Roboto-LightItalic.ttf                 \
  gwl/static/fonts/Roboto-Light.ttf                       \
  gwl/static/fonts/OFL.txt                                \
  gwl/static/graphs/index.html                            \
  gwl/static/images/grid.png

info_TEXINFOS = doc/gwl.texi

EXTRA_DIST +=      \
  env.in           \
  doc/fdl-1.3.texi

dist-hook: $(distdir)/ChangeLog
gen-ChangeLog $(distdir)/ChangeLog:
	$(AM_V_GEN)if test -d .git; then				\
	  $(top_srcdir)/build-aux/gitlog-to-changelog	\
	    > $(distdir)/cl-t;							\
	  rm -f $(distdir)/ChangeLog;					\
	  mv $(distdir)/cl-t $(distdir)/ChangeLog;		\
	fi

.PHONY: gen-ChangeLog
