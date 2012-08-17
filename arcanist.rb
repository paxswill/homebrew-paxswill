require 'formula'

class Arcanist < Formula
  homepage 'http://phabricator.org/'
  url 'https://github.com/facebook/arcanist.git'
  version 'tip'

  def install
    # Instead of copying things piecemeal, I just reclone arcanist in.
    # This let's `arc upgrade` work (which is also a viloation of Homebrew
    # policies).
    system 'git', 'clone', url
    cd 'arcanist/externals/includes' do
      system 'git', 'clone', 'git://github.com/facebook/libphutil.git'
    end
    prefix.install 'arcanist'
    completion_d = prefix+'etc/bash_completion.d'
    mkdir_p completion_d
    ln_s (prefix+'arcanist/resources/shell/bash-completion'), (completion_d+'arcanist')
    (bin+'arc').write <<-EOS.undent
    #!/bin/sh
    "#{prefix}/arcanist/bin/arc" "$@"
    EOS
  end
end
