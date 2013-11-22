require 'formula'

class KicadLibrary < Formula
  homepage 'https://code.launchpad.net/~kicad-lib-committers/kicad/library'
  head 'https://code.launchpad.net/~kicad-lib-committers/kicad/library', :using => :bzr
  def initialize; super 'kicad-library'; end
end

class Kicad < Formula
  homepage 'https://launchpad.net/kicad'
  head "http://bazaar.launchpad.net/~kicad-testing-committers/kicad/testing/", :using => :bzr

  depends_on 'bazaar'
  depends_on 'cmake' => :build
  depends_on :x11
  depends_on 'Wxmac'
  depends_on 'GLEW'

  def patches
	DATA
  end

  def install

    # install the component libraries
    KicadLibrary.new.brew do
      args = std_cmake_args + %W[
        -DKICAD_MODULES=#{share}/kicad/modules
        -DKICAD_LIBRARY=#{share}/kicad/library
        -DKICAD_TEMPLATES=#{share}/kicad/template
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
    inreplace 'common/edaappl.cpp','/Library/Application Support', "#{HOMEBREW_PREFIX}/share/kicad"

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
diff --git a/CMakeModules/download_boost.cmake b/CMakeModules/download_boost.cmake
index 5f19823..983ac61 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -126,8 +126,8 @@ ExternalProject_Add( boost
     # to ignore previously applied patches
     PATCH_COMMAND   bzr revert
         # PATCH_COMMAND continuation (any *_COMMAND here can be continued with COMMAND):
-        COMMAND     bzr patch -p0 "${PROJECT_SOURCE_DIR}/patches/boost_minkowski.patch"
-        COMMAND     bzr patch -p0 "${PROJECT_SOURCE_DIR}/patches/boost_cstdint.patch"
+        COMMAND     patch -p0 < "${PROJECT_SOURCE_DIR}/patches/boost_minkowski.patch"
+        COMMAND     patch -p0 < "${PROJECT_SOURCE_DIR}/patches/boost_cstdint.patch"
 
     # [Mis-]use this step to erase all the boost headers and libraries before
     # replacing them below.

diff --git a/CMakeModules/download_boost.cmake b/CMakeModules/download_boost.cmake
index 22affc6..8615c5f 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -140,7 +140,6 @@ ExternalProject_Add( boost
                     variant=release
                     threading=multi
                     toolset=gcc
-                    ${PIC_STUFF}
                     ${b2_libs}
                     #link=static
                     --prefix=<INSTALL_DIR>
