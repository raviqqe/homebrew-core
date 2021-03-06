class Byobu < Formula
  desc "Text-based window manager and terminal multiplexer"
  homepage "http://byobu.co/"
  url "https://launchpad.net/byobu/trunk/5.127/+download/byobu_5.127.orig.tar.gz"
  sha256 "4bafc7cb69ff5b0ab6998816d58cd1ef7175e5de75abc1dd7ffd6d5288a4f63b"

  bottle do
    cellar :any_skip_relocation
    sha256 "a38947144d88d06d05ae8443d045d2c0e230f20f5de8ca617dd4436a73d74c91" => :mojave
    sha256 "072c0ed467ca88ca0f5f06a62e526f7e6a6891d52343a24a5bc2459c8227b739" => :high_sierra
    sha256 "072c0ed467ca88ca0f5f06a62e526f7e6a6891d52343a24a5bc2459c8227b739" => :sierra
    sha256 "072c0ed467ca88ca0f5f06a62e526f7e6a6891d52343a24a5bc2459c8227b739" => :el_capitan
    sha256 "0f159e02d3e803736aadc23d78e46c7c3459302efc65ad50b976172e5cd0c244" => :x86_64_linux
  end

  head do
    url "https://github.com/dustinkirkland/byobu.git"

    depends_on "automake" => :build
    depends_on "autoconf" => :build
  end

  depends_on "coreutils"
  depends_on "gnu-sed" # fails with BSD sed
  depends_on "tmux"
  depends_on "newt"

  conflicts_with "ctail", :because => "both install `ctail` binaries"

  def install
    if build.head?
      cp "./debian/changelog", "./ChangeLog"
      system "autoreconf", "-fvi"
    end
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  def caveats; <<~EOS
    Add the following to your shell configuration file:
      export BYOBU_PREFIX=#{HOMEBREW_PREFIX}
  EOS
  end

  test do
    system bin/"byobu-status"
  end
end
