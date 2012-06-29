require 'formula'

class Msp430Kext < Formula
  homepage 'https://github.com/paxswill/ez430rf2500'
  url 'https://github.com/downloads/paxswill/ez430rf2500/ez430rf2500.kext.zip'
  sha1 'bf1fee9c5702b017d389e6d64c36b796788d0107'
  version '1.0'
end

class Mspdebug < Formula
  homepage 'http://mspdebug.sourceforge.net/index.html'
  url 'http://sourceforge.net/projects/mspdebug/files/mspdebug-0.19.tar.gz/download'
  sha1 '329ad2c4cd9496dc7d24fccd59895c8d68e2bc9a'
  head 'git://mspdebug.git.sourceforge.net/gitroot/mspdebug/mspdebug'

  depends_on 'libusb'

  def install
    # Just a Makefile
    system "make", "PREFIX=#{prefix}", "install"
    Msp430Kext.new.brew do |brewed|
      Dir.chdir '..'
      puts Dir.pwd
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
end
