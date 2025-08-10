# dev-libs/libbacktrace/libbacktrace-9999.ebuild

EAPI=8

inherit git-r3 autotools

DESCRIPTION="C library providing extraction of backtraces (stack traces)"
HOMEPAGE="https://github.com/ianlancetaylor/libbacktrace"
EGIT_REPO_URI="https://github.com/ianlancetaylor/libbacktrace.git"

LICENSE="BSD"
SLOT="0"
KEYWORDS=""
IUSE="static-libs test zlib"

# libbacktrace can optionally use zlib for compressed debug sections
DEPEND="
    zlib? ( sys-libs/zlib )
"
RDEPEND="${DEPEND}"
BDEPEND="
"

RESTRICT="!test? ( test )"

src_prepare() {
    default
    eautoreconf
}

src_configure() {
    local myeconf=(
        --enable-shared
        $(use_enable static-libs static)
    )

    # zlib is auto-detected; no need to force a flag unless you want to.
    # If you prefer to be explicit and upstream supports it, you could add:
    # $(use_with zlib) or $(use_enable zlib) — but only if configure.ac has those.

    econf "${myeconf[@]}"
}

src_test() {
    # Upstream typically uses "make check"; keep optional behind USE=test
    emake check
}

src_install() {
    default

    # Drop libtool files if any
    find "${ED}" -name '*.la' -type f -delete || die

    # Prune static archives unless static-libs is enabled
    if ! use static-libs; then
        find "${ED}"/usr/lib* -name '*.a' -type f -delete || die
    fi
}

