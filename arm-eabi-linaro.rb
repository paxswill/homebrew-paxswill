require 'formula'

class LinaroNewlib < Formula
  homepage 'http://www.sourceware.org/newlib/'
  url 'ftp://sources.redhat.com/pub/newlib/newlib-1.20.0.tar.gz'
  sha1 '65e7bdbeda0cbbf99c8160df573fd04d1cbe00d1'
end

class LinaroBinutils < Formula
  homepage 'http://www.gnu.org/software/binutils/binutils.html'
  url 'http://ftpmirror.gnu.org/binutils/binutils-2.22.tar.gz'
  mirror 'http://ftp.gnu.org/gnu/binutils/binutils-2.22.tar.gz'
  md5 '8b3ad7090e3989810943aa19103fdb83'
end

class LinaroGdb < Formula
  homepage 'https://launchpad.net/gdb-linaro'
  url 'https://launchpad.net/gdb-linaro/7.4/7.4-2012.06/+download/gdb-linaro-7.4-2012.06.tar.bz2'
  md5 'f18fb5745da8bf3576f83971201acf12'
end

class ArmEabiLinaro < Formula
  homepage 'https://launchpad.net/gcc-linaro'
  if ARGV.include? '--with-gcc46'
    url 'https://launchpad.net/gcc-linaro/4.6/4.6-2012.06/+download/gcc-linaro-4.6-2012.06.tar.bz2'
    md5 '5104039954c65904648e62ee7a20ba1f'
  else
    url 'https://launchpad.net/gcc-linaro/4.7/4.7-2012.06/+download/gcc-linaro-4.7-2012.06.tar.bz2'
    md5 'd82f23f7feaad1721932481fe6fbc99c'
  end
  version '2012.06'
  
  depends_on 'gmp'
  depends_on 'mpfr'
  depends_on 'libmpc'
  depends_on 'ppl'
  depends_on 'cloog'

  def options
    [
      ['--with-gcc46', "Use GCC 4.6 instead of GCC 4.7"],
    ]
  end

  def install
    target = "arm-none-eabi"
    # Undefine LD, gcc expects that this will not be set
    ENV.delete 'LD'

    # Compiling a cross compiler precludes the use of the normal bootstrap
    # compiler process so we need to use GCC to compile the toolchain. Luckily
    # LLVM-GCC works.
    ENV.llvm

    # Halfway through the build process the compiler switches to an internal
    # version of gcc that does not understand Apple specific options.
    ENV.cc_flag_vars.each do |var|
      ENV.delete var
    end
    ENV.delete 'CPPFLAGS'
    ENV.delete 'LDFLAGS'
    unless HOMEBREW_PREFIX.to_s == '/usr/local'
      ENV['CPPFLAGS'] = "-I#{HOMEBREW_PREFIX}/include"
      ENV['LDFLAGS'] = "-L#{HOMEBREW_PREFIX}/lib"
    end
    ENV.set_cflags "-Os -w -pipe"

    # We need to use our toolchain during the build process, prepend it to PATH
    ENV.prepend 'PATH', bin, ':'

    # Build binutils and newlib alongside gcc for simplicity
    source_dir = Pathname.new Dir.pwd
    [LinaroGdb, LinaroNewlib, LinaroBinutils].each do |formula|
      formula.new.brew do |brew|
        system "rsync", "-av", "--ignore-existing", Dir.pwd+'/', source_dir
      end
    end

    args = [
      "--prefix=#{prefix}",
      #"--with-sysroot=#{prefix}",
      "--program-prefix=arm-eabi-linaro-",
      "--target=#{target}",
      "--disable-nls",
      "--enable-interwork",
      "--enable-multilib",
      "--enable-languages=c,c++",
      "--with-newlib",
      "--disable-shared",
      "--disable-threads",
      "--disable-libssp",
      "--disable-libstdcxx-pch",
      "--disable-libmudflap",
      "--disable-libgomp",
      #"--enable-poison-system-directories",
      "--with-python=no",
    ]
    # Specify the exact directory where the dependent libs are
    ['gmp', 'mpfr', 'ppl', 'cloog'].each do |dep|
      args << "--with-#{dep}=#{(Formula.factory dep).prefix}"
    end
    args << "--enable-cloog-backend=isl"
    args << "--with-mpc=#{(Formula.factory 'libmpc').prefix}"

    # Some (most?) of these packages prefer to be built in a seperate directory
    mkdir 'build' do
      system "../configure", *args
      system "make"
      # Install must be sequential
      ENV.j1
      system "make", "install"
    end
  end
end
