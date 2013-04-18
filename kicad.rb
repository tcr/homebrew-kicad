require 'formula'

class KicadLibrary < Formula
  homepage 'https://code.launchpad.net/~kicad-lib-committers/kicad/library'
  url 'https://code.launchpad.net/~kicad-lib-committers/kicad/library', :revision => '232', :using => :bzr
  head 'https://code.launchpad.net/~kicad-lib-committers/kicad/library', :using => :bzr
  version 'testing-232'
  def  patches
  [
	DATA

  ]
  end
  def initialize; super 'kicad-library'; end
end

class Kicad < Formula
  homepage 'https://launchpad.net/kicad'
  url "http://bazaar.launchpad.net/~kicad-testing-committers/kicad/testing/", :revision => '4103', :using => :bzr
  head "http://bazaar.launchpad.net/~kicad-testing-committers/kicad/testing/", :using => :bzr
  version 'testing-4103'

  depends_on 'bazaar'
  depends_on 'cmake' => :build
  depends_on :x11
  depends_on 'Wxmac'

  def patches
    [
    # fixes wx-config not requiring aui module
    "https://gist.github.com/raw/4602653/0e4397884062c8fc44a9627e78fb4d2af20eed5b/gistfile1.txt",
    # enable retina display for OSX
    "https://gist.github.com/raw/4602849/2fe826c13992c4238a0462c03138f4c6aabd4968/gistfile1.txt",
    #Various small patches to KICAD for OSX
    #"https://gist.github.com/shaneburrell/5255741/raw/c34c16f4b9a5895b53dd1e1f494515652de290b1/kicad-patch.txt"
    ]
  end

  def install

    # install the component libraries
    KicadLibrary.new.brew do
      args = std_cmake_args + %W[
        -DKICAD_MODULES=#{share}/kicad/modules
        -DKICAD_LIBRARY=#{share}/kicad/library
      ]
      system "cmake", ".", *args
      system "make install"
    end
    args = std_cmake_args + %W[
        -DKICAD_TESTING_VERSION=ON
        -DCMAKE_CXX_FLAGS=-D__ASSERTMACROS__
      ]

    system "cmake", ".", *args

    # fix the osx search path for the library components to the homebrew directory
    inreplace 'common/edaappl.cpp','/Library/Application Support/kicad', "#{HOMEBREW_PREFIX}/share/kicad"

    system "make install"
  end

  def caveats; <<-EOS.undent
    kicad.app and friends installed to:
      #{bin}

    To link the application to a normal Mac OS X location:
        brew linkapps
    or:
        ln -s #{bin}/bitmap2component.app /Applications
        ln -s #{bin}/cvpcb.app /Applications
        ln -s #{bin}/eeschema.app /Applications
        ln -s #{bin}/gerbview.app /Applications
        ln -s #{bin}/kicad.app /Applications
        ln -s #{bin}/pcb_calculation.app /Applications
        ln -s #{bin}/pcbnew.app /Applications
    EOS
  end

  def test
    # run main kicad UI
    system "open #{bin}/kicad.app"
  end
end
__END__
=== modified file 'CMakeLists.txt'
--- CMakeLists.txt /    2013-04-13 21:27:04 +0000
+++ CMakeLists.txt	2013-04-18 19:25:34 +0000
@@ -9,7 +9,6 @@
 # Locations for install targets.
 if(UNIX)
     if(APPLE)
-    else(APPLE)
         # Like all variables, CMAKE_INSTALL_PREFIX can be over-ridden on the command line.
         set(CMAKE_INSTALL_PREFIX /usr/local
             CACHE PATH "")
