require 'formula'

class Arcanist < Formula
  homepage 'http://phabricator.org/'
  head 'https://github.com/facebook/arcanist.git'

  def install
    cd 'externals/includes' do
      system 'git', 'clone', 'git://github.com/facebook/libphutil.git'
    end
    (prefix+'etc/bash_completion.d').install "resources/shell/bash-completion" => 'arcanist'
    bin.install 'bin/arc'
    prefix.install "externals", "scripts", "src"
  end
end
