# /your/overlay/dev-libs/discord-rpc/discord-rpc-3.4.0.ebuild

EAPI=8

inherit git-r3 cmake

DESCRIPTION="Official DiscordRPC SDK for game presence integration"
HOMEPAGE="https://github.com/discord/discord-rpc"
EGIT_REPO_URI="https://github.com/discord/discord-rpc.git"
EGIT_COMMIT="v3.4.0"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"

DEPEND="
"
RDEPEND=""

src_prepare() {
    default

    # Remove upstream .clang-format that contains duplicate 'IndentCaseLabels' keys
    rm -f "${S}/.clang-format"

    cmake_src_prepare
}

src_configure() {
    cmake_src_configure \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DCMAKE_BUILD_TYPE=Release \
        -DBUILD_SHARED_LIBS=ON
}

src_compile() {
    cmake_src_compile
}

src_install() {
    cmake_src_install
}
