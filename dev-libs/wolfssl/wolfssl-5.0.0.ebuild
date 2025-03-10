# Copyright 2021 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit autotools

DESCRIPTION="Embedded SSL library."
HOMEPAGE="https://www.wolfssl.com/ https://github.com/wolfSSL/wolfssl"
SRC_URI="https://www.wolfssl.com/${P}.zip"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="debug cpu_flags_x86_aes sniffer"

DEPEND="sniffer? ( net-libs/libpcap )"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
	default
}

src_configure() {
	econf \
		$(use_enable cpu_flags_x86_aes aesni) \
		$(use_enable sniffer) \
		$(use_enable debug) \
		--enable-distro \
		--enable-writedup # Needed for RPCS3
}
