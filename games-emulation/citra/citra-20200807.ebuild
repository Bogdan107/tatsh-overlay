# Copyright 2020 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7
inherit cmake-utils

DESCRIPTION="A Nintendo 3DS emulator."
HOMEPAGE="https://citra-emu.org/"
MY_SHA="f72be7af2dd1706cbbd80a9baae417e17752a1b0"
INIH_SHA="2023872dfffb38b6a98f2c45a0eb25652aaea91f"
LODEPNG_SHA="31d9704fdcca0b68fb9656d4764fa0fb60e460c2"
SOUNDTOUCH_SHA="060181eaf273180d3a7e87349895bd0cb6ccbf4a"
NIHSTRO_SHA="fd69de1a1b960ec296cc67d32257b0f9e2d89ac6"
SRC_URI="https://github.com/citra-emu/citra/archive/${MY_SHA}.tar.gz -> ${P}.tar.gz
	https://github.com/benhoyt/inih/archive/${INIH_SHA}.tar.gz -> ${PN}-inih-2023872.tar.gz
	https://github.com/lvandeve/lodepng/archive/${LODEPNG_SHA}.tar.gz -> ${PN}-lodepng-31d9704.tar.gz
	https://github.com/citra-emu/ext-soundtouch/archive/${SOUNDTOUCH_SHA}.tar.gz -> ${PN}-soundtouch.tar.gz
	https://github.com/neobrain/nihstro/archive/${NIHSTRO_SHA}.tar.gz -> ${PN}-nihstro.tar.gz
	https://api.citra-emu.org/gamedb/ -> ${PN}-compatibility_list.json"

LICENSE="ZLIB BSD GPL-2 LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=">=dev-libs/xbyak-5.941
	net-libs/enet
	dev-libs/teakra
	dev-libs/cubeb
	virtual/ffmpeg
	dev-libs/crypto++:0/8
	dev-libs/libfmt
	app-arch/zstd
	dev-libs/boost
	media-libs/libsdl2
	dev-libs/dynarmic"
RDEPEND="${DEPEND}"
BDEPEND=">=sys-devel/clang-10"

PATCHES=(
	${FILESDIR}/${PN}-src-cmake-fixes.patch
	${FILESDIR}/${PN}-externals.patch
	${FILESDIR}/${PN}-no-check-submodules.patch
	${FILESDIR}/${PN}-xbyak.patch
)

S="${WORKDIR}/${PN}-${MY_SHA}"

src_prepare() {
	rmdir "${S}/externals/inih/inih" \
		"${S}/externals/lodepng/lodepng" \
		"${S}/externals/nihstro" \
		"${S}/externals/soundtouch" || die
	mv "${WORKDIR}/ext-soundtouch-${SOUNDTOUCH_SHA}" "${S}/externals/soundtouch" || die
	mv "${WORKDIR}/inih-${INIH_SHA}" "${S}/externals/inih/inih" || die
	mv "${WORKDIR}/lodepng-${LODEPNG_SHA}" "${S}/externals/lodepng/lodepng" || die
	mv "${WORKDIR}/nihstro-${NIHSTRO_SHA}" "${S}/externals/nihstro" || die
	mkdir -p "${WORKDIR}/${P}_build/dist/compatibility_list" || die
	cp "${DISTDIR}/${PN}-compatibility_list.json" "${WORKDIR}/${P}_build/dist/compatibility_list/compatibility_list.json" || die
	cmake-utils_src_prepare
}

src_configure() {
	CC=${CHOST}-clang
	CXX=${CHOST}-clang++
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=OFF
		-DENABLE_FFMPEG_AUDIO_DECODER=ON
		-DENABLE_FFMPEG_VIDEO_DUMPER=ON
		-DENABLE_WEB_SERVICE=OFF
		-DUSE_SYSTEM_BOOST=ON
	)
	cmake-utils_src_configure
}

