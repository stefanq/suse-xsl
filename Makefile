# Makefile for suse-xsl-stylesheets
#
# Copyright (C) 2011-2015 SUSE Linux GmbH
#
# Author:
# Frank Sundermeyer <fsundermeyer at opensuse dot org>
#
ifndef PREFIX
  PREFIX := /usr/share
endif

SHELL         := /bin/bash
PACKAGE       := suse-xsl-stylesheets
# HINT: Also raise version number in packaging/suse-xsl-stylesheets.spec
VERSION       := 2.0.6.1
CDIR          := $(shell pwd)
DIST_EXCLUDES := packaging/exclude-files_for_susexsl_package.txt
SUSE_XML_PATH := $(PREFIX)/xml/suse
DB_XML_PATH   := $(PREFIX)/xml/docbook
SUSE_SCHEMA_PATH := $(SUSE_XML_PATH)/schema
SUSE_STYLES_PATH := $(DB_XML_PATH)/stylesheet


#--------------------------------------------------------------
# stylesheet directory names

DIR2005          := suse
DIR2013_SUSE     := suse2013
DIR2013_OPENSUSE := opensuse2013
DIR2013_DAPS     := daps2013

ALL_STYLEDIRS := $(DIR2005) $(DIR2013_SUSE) $(DIR2013_OPENSUSE) $(DIR2013_DAPS)

#--------------------------------------------------------------
# Directories and files that will be created

BUILD_DIR       := build
DEV_ASPELL_DIR  := $(BUILD_DIR)/aspell
DEV_CATALOG_DIR := $(BUILD_DIR)/catalogs
DEV_STYLE_DIR   := $(BUILD_DIR)/stylesheet
DEV_HTML_DIR    := $(BUILD_DIR)/$(DIR2005)/html

# aspell dictionary
SUSE_DICT := $(BUILD_DIR)/aspell/en_US-suse-addendum.rws

# Catalog stuff
#
SUSEXSL_CATALOG    := $(DEV_CATALOG_DIR)/catalog-for-$(PACKAGE).xml


# html4 stylesheets for STYLEDIR2005 are autogenerated from the xhtml
# stylesheets so we only need to maintain them in one place
#
XHTML2HTML      := $(DIR2005)/common/xhtml2html.xsl
HTMLSTYLESHEETS := $(subst $(DIR2005)/xhtml,$(DEV_HTML_DIR),$(wildcard $(DIR2005)/xhtml/*.xsl))

#-------
# Local Stylesheets Directories

DEV_DIR2005          := $(DEV_STYLE_DIR)/$(DIR2005)-ns
DEV_DIR2013_DAPS     := $(DEV_STYLE_DIR)/$(DIR2013_DAPS)-ns
DEV_DIR2013_OPENSUSE := $(DEV_STYLE_DIR)/$(DIR2013_OPENSUSE)-ns
DEV_DIR2013_SUSE     := $(DEV_STYLE_DIR)/$(DIR2013_SUSE)-ns

DEV_DIRECTORIES := $(DEV_ASPELL_DIR) $(DEV_CATALOG_DIR) $(DEV_HTML_DIR) \
   $(DEV_DIR2005) $(DEV_DIR2013_DAPS) \
   $(DEV_DIR2013_OPENSUSE) $(DEV_DIR2013_SUSE)

LOCAL_STYLEDIRS := $(DIR2005) $(DEV_DIR2005) \
   $(DIR2013_SUSE) $(DEV_DIR2013_SUSE) $(DIR2013_DAPS) $(DEV_DIR2013_DAPS) \
   $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE)


#-------------------------------------------------------
# Directories for installation

INST_STYLE_ROOT          := $(DESTDIR)$(SUSE_STYLES_PATH)

STYLEDIR2005            := $(INST_STYLE_ROOT)/$(DIR2005)
STYLEDIR2005-NS         := $(INST_STYLE_ROOT)/$(DIR2005)-ns
SUSESTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)
SUSESTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_SUSE)-ns
DAPSSTYLEDIR2013        := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)
DAPSSTYLEDIR2013-NS     := $(INST_STYLE_ROOT)/$(DIR2013_DAPS)-ns
OPENSUSESTYLEDIR2013    := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)
OPENSUSESTYLEDIR2013-NS := $(INST_STYLE_ROOT)/$(DIR2013_OPENSUSE)-ns

ASPELLDIR     := $(DESTDIR)$(PREFIX)/suse-xsl-stylesheets/aspell
DOCDIR        := $(DESTDIR)$(PREFIX)/doc/packages/suse-xsl-stylesheets
TTF_FONT_DIR  := $(DESTDIR)$(PREFIX)/fonts/truetype
CATALOG_DIR   := $(DESTDIR)/etc/xml
SGML_DIR      := $(DESTDIR)$(PREFIX)/sgml
VAR_SGML_DIR  := $(DESTDIR)/var/lib/sgml

INST_STYLEDIRS := $(STYLEDIR2005) $(STYLEDIR2005-NS) \
   $(SUSESTYLEDIR2013) $(SUSESTYLEDIR2013-NS) $(DAPSSTYLEDIR2013) \
   $(DAPSSTYLEDIR2013-NS) $(OPENSUSESTYLEDIR2013) $(OPENSUSESTYLEDIR2013-NS)

INST_DIRECTORIES := $(ASPELLDIR) $(INST_STYLEDIRS) $(DOCDIR) $(DTDDIR_10) \
   $(RNGDIR_09) $(RNGDIR_10) $(TTF_FONT_DIR) $(CATALOG_DIR) $(SGML_DIR) \
   $(VAR_SGML_DIR)

#############################################################

all: $(SUSEXSL_CATALOG)
all: $(HTMLSTYLESHEETS) $(SUSE_DICT) generate_xslns
	@echo "Ready to install..."

#-----------------------------
install: | $(INST_DIRECTORIES)
	install -m644 $(SUSE_DICT) $(ASPELLDIR)
	install -m644 $(DEV_CATALOG_DIR)/*.xml $(CATALOG_DIR)
	install -m644 COPYING* $(DOCDIR)
	install -m644 fonts/*.ttf $(TTF_FONT_DIR)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2005) . | (cd  $(STYLEDIR2005); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2005) . | (cd  $(STYLEDIR2005-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_DAPS) . | (cd  $(DAPSSTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_DAPS) . | (cd  $(DAPSSTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_OPENSUSE) . | (cd  $(OPENSUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_OPENSUSE) . | (cd  $(OPENSUSESTYLEDIR2013-NS); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013); tar xp)
	tar c --mode=u+w,go+r-w,a-s -C $(DEV_DIR2013_SUSE) . | (cd  $(SUSESTYLEDIR2013-NS); tar xp)
	for SDIR in $(INST_STYLEDIRS); do \
	   sed -i "s/@@#version@@/$(VERSION)/" $$SDIR/VERSION.xsl; \
	done

#-----------------------------
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)

#-----------------------------
# Generate SUSE aspell dictionary
#
$(SUSE_DICT): $(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt
	aspell --lang=en create master ./$@ < $<

.INTERMEDIATE: $(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt
$(DEV_ASPELL_DIR)/suse_wordlist_tmp.txt: aspell/suse_wordlist.txt | $(DEV_ASPELL_DIR)
	cat $< | sort | uniq > $@

#-----------------------------
# auto-generate the DocBook5 (xsl-ns) stylesheets
# Let's be super lazy and generate them every time make is called by
# making this target PHONY
#
.PHONY: generate_xslns
generate_xslns: | $(LOCAL_STYLEDIRS)
	bin/xslns-build $(DIR2005) $(DEV_DIR2005)
	bin/xslns-build $(DIR2013_DAPS) $(DEV_DIR2013_DAPS)
	bin/xslns-build $(DIR2013_OPENSUSE) $(DEV_DIR2013_OPENSUSE)
	bin/xslns-build $(DIR2013_SUSE) $(DEV_DIR2013_SUSE)

#-----------------------------
# Auto-generate HTML stylesheets from XHTML:
$(DEV_HTML_DIR)/%.xsl: $(DIR2005)/xhtml/%.xsl | $(DEV_HTML_DIR)
	xsltproc --output $@  ${XHTML2HTML} $<


# FIXME: None of the below URLs exist. Would be good if they would at least
#        redirect into the SVN instead of 404ing.
$(SUSEXSL_CATALOG): | $(DEV_CATALOG_DIR)
	xmlcatalog --noout --create $@
	for catalog in $(ALL_STYLEDIRS); do \
	  xmlcatalog --noout --add "rewriteSystem" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$$catalog" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$$catalog)" $@; \
	  xmlcatalog --noout --add "rewriteURI" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$$catalog" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$$catalog)" $@; \
	  xmlcatalog --noout --add "rewriteSystem" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$${catalog}-ns" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$${catalog}-ns)" $@; \
	  xmlcatalog --noout --add "rewriteURI" \
	    "https://raw.githubusercontent.com/openSUSE/suse-xsl/master/$${catalog}-ns" \
	    "file://$(subst $(DESTDIR),,$(INST_STYLE_ROOT)/$${catalog}-ns)" $@; \
	done
	sed -i '/^<!DOCTYPE .*>$$/d' $@
	sed -i '/<catalog/a\ <group id="$(PACKAGE)">' $@
	sed -i '/<\/catalog/i\ </group>' $@

# create needed directories
#
$(INST_DIRECTORIES) $(DEV_DIRECTORIES) $(BUILD_DIR):
	@mkdir -p $@

#-----------------------------
# create tarball
#

.PHONY: dist
dist: | $(BUILD_DIR)
	@tar cfjhP $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2 \
	  -C $(CDIR) --exclude-from=$(DIST_EXCLUDES) \
	  --transform 's:^$(CDIR):suse-xsl-stylesheets-$(VERSION):' $(CDIR)
	@echo "Successfully created $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2"

PHONY: dist-clean
dist-clean:
	rm -f $(BUILD_DIR)/$(PACKAGE)-$(VERSION).tar.bz2	
	rmdir $(BUILD_DIR) 2>/dev/null || true
