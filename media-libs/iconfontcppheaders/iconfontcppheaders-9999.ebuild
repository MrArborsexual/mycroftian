# Copyright 1999-2025 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="C++ headers for icon fonts like Font Awesome, Fork Awesome, Material Icons, etc."
HOMEPAGE="https://github.com/juliettef/IconFontCppHeaders"
EGIT_REPO_URI="https://github.com/juliettef/IconFontCppHeaders.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

inherit git-r3

src_install() {
    insinto /usr/include/iconfontcppheaders
    doins *.h
}
