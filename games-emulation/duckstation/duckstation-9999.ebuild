# Copyright 2025
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake git-r3 flag-o-matic

DESCRIPTION="DuckStation PS1 emulator (Royce fork) - prefer system libraries"
HOMEPAGE="https://github.com/MrArborsexual/duckstation"
EGIT_REPO_URI="https://github.com/MrArborsexual/duckstation.git"

LICENSE="GPL-3"
SLOT="0"
KEYWORDS=""

# Frontends/backends/features
IUSE="
  qt5
  mini
  regtest
  test
  retro
  discord
  opengl
  vulkan
  sdl2
  sdl3
  wayland
  X
  egl
  gbm
  evdev
  udev
  alsa
  pulseaudio
  pipewire
  curl
  zstd
  backtrace
  nogui
  ffmpeg
"
# Frontend selection: either nogui, or at least one of qt6/imgui
# SDL2 and SDL3 are mutually exclusive (pick one if you need SDL features)
REQUIRED_USE="
  nogui? ( !qt5 !mini )
  !nogui? ( || ( qt5 mini ) )
  ^^ ( sdl2 sdl3 )
"

# Common system libraries you want to force instead of vendoring.
# Expect to tweak as you wire up your CMake options and unbundle logic.
COMMON_DEPEND="
  media-libs/VulkanMemoryAllocator
  app-arch/p7zip
  media-libs/iconfontcppheaders
  media-libs/glad
  dev-cpp/simpleini
  media-libs/imgui
  dev-libs/libchdr
  dev-util/spirv-cross:=
  media-libs/shaderc:=
  media-libs/libsoundtouch:=
  media-libs/plutosvg:=
  backtrace? ( dev-libs/libbacktrace:= )

  discord? ( dev-libs/discord-rpc:= )

  vulkan? ( media-libs/vulkan-loader:= )
  opengl? ( virtual/opengl )

  media-video/ffmpeg

  curl? (
    net-misc/curl:=
    dev-libs/openssl:=
  )

  zstd? ( app-arch/zstd:= )
"

# UI/input stacks mostly flow through Qt/SDL; keep flags for clarity and future tightening
QT_DEPS="
  qt5? (
    dev-qt/qtcore:5
    dev-qt/qtgui:5
    dev-qt/qtwidgets:5
    dev-qt/qtimageformats:5
    dev-qt/qtsvg:5
  )
"
SDL_DEPS="
  sdl3? ( media-libs/libsdl3[alsa?,pulseaudio?,wayland?,X?,vulkan?,opengl?] )
  sdl2? ( media-libs/libsdl2[alsa?,pulseaudio?,wayland?,X?,vulkan?,opengl?] )
"

# These are largely handled by Qt/SDL, but exposing them keeps intent explicit.
PLATFORM_DEPS="
  alsa? ( media-libs/alsa-lib )
  pulseaudio? ( media-sound/pulseaudio )
  pipewire? ( media-video/pipewire )
  wayland? ( dev-libs/wayland )
  X? ( x11-libs/libX11 )
"

DEPEND="
  ${COMMON_DEPEND}
  ${QT_DEPS}
  ${SDL_DEPS}
  ${PLATFORM_DEPS}
  virtual/pkgconfig
"

RDEPEND="
  ${COMMON_DEPEND}
  ${QT_DEPS}
  ${SDL_DEPS}
  ${PLATFORM_DEPS}
"

BDEPEND="
  virtual/pkgconfig
"

src_prepare() {
  cmake_src_prepare

  # You may add sed/patch steps here to force system libs over bundled copies,
  # or to expose missing CMake options in your fork.
  # e.g. rm -r third_party/<lib> to guarantee system usage (once CMake honors it).
}

src_configure() {
  local mycmakeargs=(
    -DBUILD_QT_FRONTEND=$(usex qt5 ON OFF)
    -DBUILD_MINI_FRONTEND=$(usex mini ON OFF)
    -DBUILD_REGTEST=$(usex regtest ON OFF)
    -DBUILD_TESTS=$(usex test ON OFF)

    -DENABLE_OPENGL=$(usex opengl ON OFF)
    -DENABLE_VULKAN=$(usex vulkan ON OFF)
    -DENABLE_FFMPEG=$(usex ffmpeg ON OFF)
    -DENABLE_RETROACHIEVEMENTS=$(usex retro ON OFF)
    -DENABLE_DISCORD_PRESENCE=$(usex discord ON OFF)

    -DENABLE_SDL2=$(usex sdl2 ON OFF)
    -DENABLE_SDL3=$(usex sdl3 ON OFF)

    -DENABLE_WAYLAND=$(usex wayland ON OFF)
    -DENABLE_X11=$(usex X ON OFF)
    -DENABLE_EGL=$(usex egl ON OFF)
    -DENABLE_GBM=$(usex gbm ON OFF)
    -DENABLE_EVDEV=$(usex evdev ON OFF)
    -DENABLE_UDEV=$(usex udev ON OFF)

    -DENABLE_ALSA=$(usex alsa ON OFF)
    -DENABLE_PULSEAUDIO=$(usex pulseaudio ON OFF)
    -DENABLE_PIPEWIRE=$(usex pipewire ON OFF)

    -DENABLE_CURL=$(usex curl ON OFF)
    -DENABLE_ZSTD=$(usex zstd ON OFF)
    -DENABLE_BACKTRACE=$(usex backtrace ON OFF)
  )
  cmake_src_configure
}

