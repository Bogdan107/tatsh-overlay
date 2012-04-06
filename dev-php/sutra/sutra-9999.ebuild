# kate: replace-tabs false;
# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils git-2

EAPI=4

DESCRIPTION="An extension upon Flourish."
HOMEPAGE="http://www.poluza.com/"
EGIT_REPO_URI="git://github.com/tatsh/sutra.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="site"

DEPEND=""
RDEPEND=">=dev-lang/php-5.2.3
				 dev-php/flourish[sutra-patches]
				 dev-php/moor"

src_prepare() {
	mkdir sutra
	cp -R classes model routers scripts sutra
	mv scripts/compile-javascript.inc sutra

	cd sutra
		epatch "${FILESDIR}"/${PN}-${PV}-jscc-fix-include-path.patch
	cd ..

	if use site ; then
		mv site htdocs

		# Scripts for sites
		# for now just delete them
		rm sutra/scripts/install-*
		# end

		# Create sutra-create-category, sutra-create-router-alias,
		#   sutra-fsql, sutra-jscc, sutra-jsccd
		mkdir bin
		for i in sutra/scripts/*.php; do
			mv "$i" "bin/sutra-$(basename ${i%.*})"
		done
		mv bin/sutra-js-compiler bin/sutra-jscc
		mv bin/sutra-js-compiler-daemon bin/sutra-jsccd
		rm -R sutra/scripts
	fi
}

src_install() {
	for i in bin/*; do
		dobin "$i" || die "install $i failed"
	done

	insinto /usr/share/php
	doins -r sutra
	rm -R sutra

	if use site ; then
		insinto /usr/share/webapps/sutra/${PV}
		doins -r htdocs

		mkdir sutra
		mv routes sutra
		insinto /usr/share
		doins -r sutra
		rm -R sutra

		mkdir sutra
		mv config sutra/sample-config
		insinto /etc
		doins -r sutra

		insinto /usr/share/php/sutra/templates
		doins -r template/default
	fi
}

pkg_postinst() {
	elog
	elog "To begin a site, copy /usr/share/webapps/${PN}/${PV}/htdocs to where your site roots are."
	elog
}
