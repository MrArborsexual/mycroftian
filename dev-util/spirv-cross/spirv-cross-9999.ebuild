# Copyright 2025 Your Name
# Distributed under the terms of the GPL-2

EAPI=8
inherit git-r3 cmake

DESCRIPTION="Khronos SPIR-V reflection and parsing library"
HOMEPAGE="https://github.com/KhronosGroup/SPIRV-Cross"
EGIT_REPO_URI="https://github.com/KhronosGroup/SPIRV-Cross.git"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS=""
IUSE=""

DEPEND=""
RDEPEND=""

src_prepare() {
    default
    cmake_src_prepare
}

src_configure() {
    cmake_src_configure \
        -DCMAKE_INSTALL_PREFIX=/usr \
        -DSPIRV_CROSS_SHARED_LIB=ON \
        -DSPIRV_CROSS_STATIC_LIB=OFF
        -DBUILD_SHARED_LIBS=ON
}

# cmake.eclass handles src_compile() and src_install()
