class W3m < Formula
  desc "Pager/text based browser"
  homepage "https://w3m.sourceforge.io/"
  revision 5
  head "https://github.com/tats/w3m.git"

  stable do
    url "https://downloads.sourceforge.net/project/w3m/w3m/w3m-0.5.3/w3m-0.5.3.tar.gz"
    sha256 "e994d263f2fd2c22febfbe45103526e00145a7674a0fda79c822b97c2770a9e3"

    # Upstream is effectively Debian https://github.com/tats/w3m at this point.
    # The patches fix a pile of CVEs
    patch do
      url "https://mirrors.ocf.berkeley.edu/debian/pool/main/w/w3m/w3m_0.5.3-36.debian.tar.xz"
      mirror "https://mirrorservice.org/sites/ftp.debian.org/debian/pool/main/w/w3m/w3m_0.5.3-36.debian.tar.xz"
      sha256 "e7f41ac222c55830ce121e1c50e67ab04b292837b9bb1ece2eae2689c82147ec"
      apply "patches/010_upstream.patch",
            "patches/020_debian.patch"
    end
  end

  bottle do
    sha256 "e8aa7de4835538616cd9902bb49cbc1bf5c897969c9fdcc8aed9ecd42175e376" => :mojave
    sha256 "4b0be4259e778c1c7df97d43b9e176e019e6de5d7bdeceec89baa34bdc0392db" => :high_sierra
    sha256 "1e2305cc1e1e717648d331a44d3f0867ad20e63a50fbdd0d824e4482e4d8a6f7" => :sierra
    sha256 "745f4a07f511c4a9ecbf4cb12bba58eac9c36a92291945134cbebe4fe03dc747" => :el_capitan
    sha256 "0985ae777239981b09a6628bf82fbd22e1bec549d6fac106a73f3bcfc58717ce" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "bdw-gc"
  depends_on "openssl"
  unless OS.mac?
    depends_on "ncurses"
    depends_on "libbsd"
    depends_on "zlib"
    depends_on "gettext"
  end

  def install
    system "./configure", "--prefix=#{prefix}",
                          "--disable-image",
                          "--with-ssl=#{Formula["openssl"].opt_prefix}"
    system "make", "install"
  end

  test do
    assert_match /DuckDuckGo/, shell_output("#{bin}/w3m -dump https://duckduckgo.com")
  end
end
