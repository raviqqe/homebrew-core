class Gnuplot < Formula
  desc "Command-driven, interactive function plotting"
  homepage "http://www.gnuplot.info/"
  url "https://downloads.sourceforge.net/project/gnuplot/gnuplot/5.2.4/gnuplot-5.2.4.tar.gz"
  sha256 "1515f000bd373aaa53b16183f274189d4f5e0ae47d22f434857933d16a4770cb"

  bottle do
    sha256 "de4c1ae7e84496672a59e46e57bbb52de0c30e52e5fc057b41e7d6a6f0a754e8" => :mojave
    sha256 "83e62efd791e58c6be41b8da6975e66bf88ee01c2d364dc56f4496a2ec2c20aa" => :high_sierra
    sha256 "bdd5bf26cfe0c268092d6120f1aaa57cf9f7c99464c83de1b64ac3d7c24f1741" => :sierra
    sha256 "b0d21667f51ef06d824a1b68ed41d32d85848e8da4b9ac8fa9fdf09c31f7f05b" => :el_capitan
    sha256 "d59963dc052f9ca7c62089ebdf42c100acf6e22b582ab95a8ad7072730577cc7" => :x86_64_linux
  end

  head do
    url "https://git.code.sf.net/p/gnuplot/gnuplot-main.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  option "with-cairo", "Build the Cairo based terminals"
  option "without-lua", "Build without the lua/TikZ terminal"
  option "with-wxmac", "Build wxmac support. Need with-cairo to build wxt terminal"
  option "with-aquaterm", "Build with AquaTerm support"

  deprecated_option "with-x" => "with-x11"
  deprecated_option "wx" => "with-wxmac"
  deprecated_option "qt" => "with-qt"
  deprecated_option "with-qt5" => "with-qt"
  deprecated_option "cairo" => "with-cairo"
  deprecated_option "nolua" => "without-lua"

  depends_on "pkg-config" => :build
  depends_on "gd"
  depends_on "readline"
  depends_on "lua" => :recommended
  depends_on "pango" if build.with?("cairo") || build.with?("wxmac")
  depends_on "qt" => :optional
  depends_on "wxmac" => :optional
  depends_on :x11 => :optional
  depends_on "linuxbrew/xorg/xorg" if build.with?("x11") && !OS.mac?

  needs :cxx11 if build.with? "qt"

  resource "libcerf" do
    url "http://apps.jcns.fz-juelich.de/src/libcerf/libcerf-1.5.tgz"
    mirror "https://www.mirrorservice.org/sites/distfiles.macports.org/libcerf/libcerf-1.5.tgz"
    sha256 "e36dc147e7fff81143074a21550c259b5aac1b99fc314fc0ae33294231ca5c86"
  end

  def install
    # Qt5 requires c++11 (and the other backends do not care)
    ENV.cxx11 if build.with? "qt"

    if build.with? "aquaterm"
      # Add "/Library/Frameworks" to the default framework search path, so that an
      # installed AquaTerm framework can be found. Brew does not add this path
      # when building against an SDK (Nov 2013).
      ENV.prepend "CPPFLAGS", "-F/Library/Frameworks"
      ENV.prepend "LDFLAGS", "-F/Library/Frameworks"
    end

    # Build libcerf
    resource("libcerf").stage do
      system "./configure", "--prefix=#{buildpath}/libcerf", "--enable-static", "--disable-shared"
      system "make", "install"
    end
    ENV.prepend_path "PKG_CONFIG_PATH", buildpath/"libcerf/lib/pkgconfig"

    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-readline=#{Formula["readline"].opt_prefix}
      --without-tutorial
    ]

    if build.without? "wxmac"
      args << "--disable-wxwidgets"
      args << "--without-cairo" if build.without? "cairo"
    end

    if build.with? "qt"
      args << "--with-qt"
    else
      args << "--with-qt=no"
    end

    args << "--without-lua" if build.without? "lua"
    args << (build.with?("aquaterm") ? "--with-aquaterm" : "--without-aquaterm")
    args << (build.with?("x11") ? "--with-x" : "--without-x")
    args << "--with-texdir=#{share}/texmf" unless OS.mac?

    system "./prepare" if build.head?
    system "./configure", *args
    ENV.deparallelize # or else emacs tries to edit the same file with two threads
    system "make"
    system "make", "install"
  end

  def caveats
    if build.with? "aquaterm"
      <<~EOS
        AquaTerm support will only be built into Gnuplot if the standard AquaTerm
        package from SourceForge has already been installed onto your system.
        If you subsequently remove AquaTerm, you will need to uninstall and then
        reinstall Gnuplot.
      EOS
    end
  end

  test do
    system "#{bin}/gnuplot", "-e", <<~EOS
      set terminal dumb;
      set output "#{testpath}/graph.txt";
      plot sin(x);
    EOS
    assert_predicate testpath/"graph.txt", :exist?
  end
end
