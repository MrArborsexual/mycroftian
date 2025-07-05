# /usr/local/portage/app-ai/koboldcpp/koboldcpp-9999.ebuild

EAPI=8

inherit git-r3 flag-o-matic

DESCRIPTION="Lightweight GGUF/LLM inference UI powered by llama.cpp"
HOMEPAGE="https://github.com/LostRuins/koboldcpp"
EGIT_REPO_URI="https://github.com/LostRuins/koboldcpp.git"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="gui clblast cublas hipblas vulkan portable"

DEPEND="
    clblast? ( sci-libs/clblast )
    cublas? ( dev-util/nvidia-cuda-toolkit )
    hipblas? ( dev-libs/rocBLAS )
    virtual/opencl
    dev-lang/python
    dev-vcs/git
    gui? ( dev-python/customtkinter )
"

BDEPEND="gui? ( dev-python/pip )"

RDEPEND="${DEPEND}"

src_unpack() {
    which git || die "git not found in build enviorment"
    git-r3_src_unpack || "Git clone failed"
}

src_compile() {
    local mymakeargs=""

    use clblast && mymakeargs+=" LLAMA_CLBLAST=1"
    use cublas && mymakeargs+=" LLAMA_CUBLAS=1"
    use hipblas && mymakeargs+=" LLAMA_HIPBLAS=1"
    use vulkan && mymakeargs+=" LLAMA_VULKAN=1"
    use portable && mymakeargs+=" LLAMA_PORTABLE=1"

    emake ${mymakeargs}
}

src_install() {
    exeinto /opt/koboldcpp
    if [[ -f koboldcpp ]]; then
    doexe koboldcpp
    fi

    insinto /opt/koboldcpp
    doins koboldcpp.py README.md koboldcpp_default.so

    # Backend .so libraries based on USE flags
    use clblast  && doins koboldcpp_clblast.so
    use cublas   && doins koboldcpp_cublas.so
    use hipblas  && doins koboldcpp_hipblas.so
    use vulkan   && doins koboldcpp_vulkan.so
    use portable && doins koboldcpp_failsafe.so koboldcpp_noavx2.so
}

