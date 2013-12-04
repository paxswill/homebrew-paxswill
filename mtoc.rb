require 'formula'

class Mtoc < Formula

  url 'http://www.opensource.apple.com/tarballs/cctools/cctools-839.tar.gz'
  sha1 'af26af8bb068f51680ebcb828125f21a6863aa3b'

  depends_on 'md' => :build

  def install
    # Don't use the 'intall' target on the Makefiles as it'll put stuff all
    # over, even if you define DSTROOT. We only need mtoc and the man page for
    # this formula anyway.
    cd('libstuff') do
      system 'make', 'EFITOOLS=efitools', 'TRIE=-DTRIE_SUPPORT', 'LTO=-DLTO_SUPPORT', 'all'
    end
    cd('efitools') do
      system 'make', 'EFITOOLS=efitools', 'TRIE=-DTRIE_SUPPORT', 'LTO=-DLTO_SUPPORT', 'mtoc.NEW'
      bin.install 'mtoc.NEW' => 'mtoc'
    end
    man.mkpath
    man1.install 'man/mtoc.1'
  end

end
