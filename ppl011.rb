require 'formula'

class Ppl011 < Formula
  homepage 'http://bugseng.com/products/ppl/'
  url 'http://bugseng.com/products/ppl/download/ftp/releases/0.11.2/ppl-0.11.2.tar.bz2'
  md5 'c24429e6c3bc97d45976a63f40f489a1'

  depends_on 'gmp'

  keg_only 'Conflicts with updated PPL'

  def install
    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-optimization=sspeed"
    system "make install"
  end
end
