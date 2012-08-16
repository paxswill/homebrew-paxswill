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
      system from capturing it. The following commands will install a copy with
      the appropriate permissions and force a rebuild of the kext cache.


        sudo cp -R #{prefix}/ez430rf2500.kext /Library/Extensions
        sudo chown -R root:wheel /Library/Extensions/ez430rf2500.kext
        sudo chmod -R 755 /Library/Extensions/ez430rf2500.kext
        sudo touch /System/Library/Extensions

      If you have installed this kext before, there should be no need to
      install it again. More information is available at:
      http://mspdebug.sourceforge.net/faq.html#rf2500_osx
      EOS
  end

  def test
    system "mspdebug", "--help"
  end
end
