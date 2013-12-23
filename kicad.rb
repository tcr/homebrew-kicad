require 'formula'


class Kicad < Formula
  homepage 'https://launchpad.net/kicad'
  head "http://bazaar.launchpad.net/~kicad-testing-committers/kicad/testing/", :using => :bzr

  depends_on 'bazaar'
  depends_on 'cmake' => :build
  depends_on :x11
  depends_on 'Wxmac'
  depends_on 'GLEW'
  depends_on 'Cairo'

  def patches
	DATA
  end

  def install

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
index 1840793..61f56c1 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -170,14 +170,12 @@ ExternalProject_Add( boost
     BUILD_COMMAND   ./b2
                     variant=release
                     threading=multi
-                    ${PIC_STUFF}
                     ${BOOST_TOOLSET}
                     ${BOOST_CXXFLAGS}
                     ${BOOST_LINKFLAGS}
                     ${BOOST_ADDRESSMODEL}
                     ${BOOST_ARCHITECTURE}
                     ${b2_libs}
-                    #link=static
                     --prefix=<INSTALL_DIR>
                     install

diff --git a/CMakeModules/download_boost.cmake b/CMakeModules/download_boost.cmake
index 61f56c1..401695e 100644
--- a/CMakeModules/download_boost.cmake
+++ b/CMakeModules/download_boost.cmake
@@ -219,6 +219,7 @@ mark_as_advanced( Boost_LIBRARIES Boost_INCLUDE_DIR )
 
 
 ExternalProject_Add_Step( boost bzr_commit_boost
+    COMMAND bzr whoami --branch --directory <SOURCE_DIR> "Kicad Build <nobody@example.com>"
     COMMAND bzr ci -q -m pristine <SOURCE_DIR>
     COMMENT "committing pristine boost files to 'boost scratch repo'"
     DEPENDERS patch
