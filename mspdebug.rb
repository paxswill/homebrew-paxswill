require 'formula'

class Msp430Kext < Formula
  homepage 'https://github.com/paxswill/ez430rf2500'
  url 'https://github.com/downloads/paxswill/ez430rf2500/ez430rf2500.kext.zip'
  sha1 'bf1fee9c5702b017d389e6d64c36b796788d0107'
  version '1.0'
end

class Mspdebug < Formula
  homepage 'http://mspdebug.sourceforge.net/index.html'
  url 'http://sourceforge.net/projects/mspdebug/files/mspdebug-0.19.tar.gz'
  sha1 '329ad2c4cd9496dc7d24fccd59895c8d68e2bc9a'
  head 'git://mspdebug.git.sourceforge.net/gitroot/mspdebug/mspdebug'

  depends_on 'libusb-compat'

  def install
    # Just a Makefile
    args = [
      "PREFIX=#{prefix}",
      "CFLAGS=-I#{HOMEBREW_PREFIX}/include",
      "LDFLAGS=-L#{HOMEBREW_PREFIX}/lib",
      "install"
    ]
    system "make", *args
    # Move the dummy kext into the prefix
    Msp430Kext.new.brew do
      Dir.chdir '..'
      mv "ez430rf2500.kext", "#{prefix}/"
    end
  end

  def caveats
    return <<-EOS.undent
      To prevent OS X's default USB drivers from capturing the debugging
      interface, you need to install a kernel extension. It has no code, it
      just defines the appropriate manufacturer and product IDs to prevent the
      system from capturing it.

        sudo cp -R #{prefix}/ez430rf2500.kext /Library/Extensions

      If you have done this before, there is no need to do it again.
      EOS
  end

  def test
    system "mspdebug", "--help"
  end
end
