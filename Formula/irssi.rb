class Irssi < Formula
  desc "Modular IRC client"
  homepage "https://irssi.org/"
  url "https://github.com/irssi/irssi/releases/download/1.1.1/irssi-1.1.1.tar.xz"
  sha256 "784807e7a1ba25212347f03e4287cff9d0659f076edfb2c6b20928021d75a1bf"

  bottle do
    sha256 "e27d4bf8c70368533d9f6e9094a29c4b5f018014930c8e29f924a4b960841d5e" => :mojave
    sha256 "6698db08f5b35df7bf0acbb8f005f79e3598999efcd78bdc3f82cc0eaaac2a6f" => :high_sierra
    sha256 "dc216333ed72a035a6f817e6970b74d82c06994a2bbaeda7bfe3e2c1b7e087dc" => :sierra
    sha256 "10a3178cc7c7542d2350830d8e2d08b16afa1d33d923193de46cabf58086509e" => :el_capitan
    sha256 "1d5eceb8680ba403f6f955c2f7fe88ebb01c19388e93300f04875b3f82fd58ce" => :x86_64_linux
  end

  head do
    url "https://github.com/irssi/irssi.git"
    depends_on "automake" => :build
    depends_on "autoconf" => :build
    depends_on "libtool" => :build
    depends_on "lynx" => :build
  end

  option "with-dante", "Build with SOCKS support"
  option "without-perl", "Build without perl support"

  depends_on "pkg-config" => :build
  depends_on "glib"
  depends_on "openssl" => :recommended
  depends_on "dante" => :optional
  depends_on "perl" unless OS.mac? || build.without?("perl") # for libperl.so

  def install
    args = %W[
      --disable-dependency-tracking
      --prefix=#{prefix}
      --sysconfdir=#{etc}
      --with-bot
      --with-proxy
      --enable-true-color
      --with-socks=#{build.with?("dante") ? "yes" : "no"}
      --with-ncurses=#{OS.mac? ? MacOS.sdk_path/"usr" : Formula["ncurses"].prefix}
    ]

    if build.with? "perl"
      args << "--with-perl=yes"
      args << "--with-perl-lib=#{lib}/perl5/site_perl"
    else
      args << "--with-perl=no"
    end

    args << "--disable-ssl" if build.without? "openssl"

    if build.head?
      system "./autogen.sh", *args
    else
      system "./configure", *args
    end
    # "make" and "make install" must be done separately on some systems
    system "make"
    system "make", "install"
  end

  test do
    IO.popen("#{bin}/irssi --connect=irc.freenode.net", "w") do |pipe|
      pipe.puts "/quit\n"
      pipe.close_write
    end
  end
end
