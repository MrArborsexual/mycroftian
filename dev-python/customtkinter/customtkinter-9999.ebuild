# /usr/local/portage/dev-python/customtkinter/customtkinter-9999.ebuild

EAPI=8

PYTHON_COMPAT=( python3_12 )
DISTUTILS_USE_PEP517=setuptools

inherit git-r3 distutils-r1

DESCRIPTION="A modern and customizable tkinter UI library"
HOMEPAGE="https://github.com/TomSchimansky/CustomTkinter"
EGIT_REPO_URI="https://github.com/TomSchimansky/CustomTkinter.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="examples"
REQUIRED_USE="|| ( python_targets_python3_12 )"




DEPEND="dev-python/setuptools[${PYTHON_USEDEP}]"
RDEPEND="${DEPEND}
    dev-python/pillow
    dev-lang/python[tk]
"

BDEPEND="dev-vcs/git"

src_install() {
    distutils-r1_src_install

    # Install asset folders manually
    insinto /usr/share/${PN}/assets/fonts
    doins -r customtkinter/assets/fonts/*

    insinto /usr/share/${PN}/assets/icons
    doins -r customtkinter/assets/icons/*

    insinto /usr/share/${PN}/assets/themes
    doins -r customtkinter/assets/themes/*

    # Optional examples
    if use examples; then
        docinto examples
        dodoc examples/*
    fi
    [[ -f Readme.md ]] && dodoc Readme.md
}
