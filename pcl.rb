require File.expand_path("../Requirements/cuda_requirement", __FILE__)

class Pcl < Formula
  desc "Library for 2D/3D image and point cloud processing"
  homepage "http://www.pointclouds.org/"
  url "https://github.com/PointCloudLibrary/pcl/archive/pcl-1.8.0.tar.gz"
  sha256 "9e54b0c1b59a67a386b9b0f4acb2d764272ff9a0377b825c4ed5eedf46ebfcf4"
  head "https://github.com/PointCloudLibrary/pcl.git"
  revision 2

  bottle do
    sha256 "479be6e6410f4f2564d6f73816bd5d3a6356e5d12aa9ed073c0a9fef9b0efaa2" => :el_capitan
    sha256 "c2a3531109975e09808556ce922967bd9b0fcf167280ffa7dcdf86a065baddb6" => :yosemite
    sha256 "d5b080e0d6c48e6640ca503810a644a30f214019171250f3af4a850614483ccc" => :mavericks
  end

  option "with-examples", "Build pcl examples."
  option "without-tools", "Build without tools."
  option "without-apps", "Build without apps."

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build

  depends_on "boost"
  depends_on "eigen"
  depends_on "flann"
  depends_on "cminpack"

  depends_on "qhull"
  depends_on "libusb"

  depends_on "glew"
  depends_on CudaRequirement => :optional
  depends_on "qt" => :optional
  depends_on "qt5" => :optional

  if build.with? "qt"
    depends_on "sip" # Fix for building system
    depends_on "pyqt" # Fix for building system
    depends_on "vtk" => [:recommended, "with-qt"]
  elsif build.with? "qt5"
    depends_on "sip" # Fix for building system
    depends_on "pyqt5" => ["with-python", "without-python3"] # Fix for building system
    depends_on "vtk" => [:recommended, "with-qt5"]
  else
    depends_on "vtk" => :recommended
  end
  depends_on "openni" => :optional
  depends_on "openni2" => :optional


  def install
    args = std_cmake_args + %W[
      -DBUILD_SHARED_LIBS:BOOL=ON
      -DBUILD_simulation:BOOL=AUTO_OFF
      -DBUILD_outofcore:BOOL=AUTO_OFF
      -DBUILD_people:BOOL=AUTO_OFF
      -DBUILD_global_tests:BOOL=OFF
      -DWITH_TUTORIALS:BOOL=OFF
      -DWITH_DOCS:BOOL=OFF
    ]
    if build.with? "qt"
      args << "-DPCL_QT_VERSION=4"
    elsif build.with? "qt5"
      args << "-DPCL_QT_VERSION=5"
    else
      args << "-DWITH_QT:BOOL=FALSE"
    end

    if build.with? "cuda"
      args += %W[
        -DWITH_CUDA:BOOL=AUTO_OFF
        -DBUILD_GPU:BOOL=ON
        -DBUILD_gpu_people:BOOL=ON
        -DBUILD_gpu_surface:BOOL=ON
        -DBUILD_gpu_tracking:BOOL=ON
      ]
    else
      args << "-DWITH_CUDA:BOOL=OFF"
    end

    if build.with? "openni2"
      ENV.append "OPENNI2_INCLUDE", "#{Formula["openni2"].opt_include}/ni2"
      ENV.append "OPENNI2_LIB", "#{Formula["openni2"].opt_lib}/ni2"
      args << "-DBUILD_OPENNI2:BOOL=ON"
    end

    if build.with? "apps"
      args += %W[
        -DBUILD_apps=AUTO_OFF
        -DBUILD_apps_3d_rec_framework=AUTO_OFF
        -DBUILD_apps_cloud_composer=AUTO_OFF
        -DBUILD_apps_in_hand_scanner=AUTO_OFF
        -DBUILD_apps_optronic_viewer=AUTO_OFF
        -DBUILD_apps_point_cloud_editor=AUTO_OFF
      ]
      if !build.head? && build.without?("qt") && build.without?("qt5")
        args << "-DBUILD_apps_modeler:BOOL=OFF"
      else
        args << "-DBUILD_apps_modeler=AUTO_OFF"
      end
    else
      args << "-DBUILD_apps:BOOL=OFF"
    end

    args << "-DBUILD_tools:BOOL=OFF" if build.without? "tools"

    if build.with? "examples"
      args << "-DBUILD_examples:BOOL=ON"
    else
      args << "-DBUILD_examples:BOOL=OFF"
    end

    if build.with? "openni"
      args << "-DOPENNI_INCLUDE_DIR=#{Formula["openni"].opt_include}/ni"
    else
      args << "-DCMAKE_DISABLE_FIND_PACKAGE_OpenNI:BOOL=TRUE"
    end

    args << "-DCMAKE_DISABLE_FIND_PACKAGE_VTK:BOOL=TRUE" if build.without? "vtk"

    args << ".."
    mkdir "macbuild" do
      system "cmake", *args
      system "make"
      system "make", "install"

      prefix.install Dir["#{bin}/*.app"]
    end
  end

  test do
    assert_match "tiff files", shell_output("#{bin}/pcl_tiff2pcd -h", 255)
  end
end
