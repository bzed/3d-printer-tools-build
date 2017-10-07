#!/bin/bash

set -e

export TOOLS="libArcus CuraEngine"

# its possible to build more than CuraEngine, uncomment the following line
# and / or edit it to suit your needs. NOT TESTED YET!

# export TOOLS="${TOOLS} libSavitar Uranium fdm_materials Cura Slic3r_prusa"

# sli3r

export BASEDIR="$(dirname $(readlink -f $0))"

# cura branch to build
#build_tag=2.7.0
build_tag=3.0


# slic3r-prusa tag to build
Slic3r_prusa_tag=master

# change here if you don't want to install into /usr/local
# or if you want to pass other options to cmake.
#export CMAKE_INSTALL_PREFIX="${BASEDIR}"
export CMAKE_INSTALL_PREFIX=/usr/local
export CMAKE="cmake -DCMAKE_INSTALL_PREFIX=${CMAKE_INSTALL_PREFIX}"

#uncomment if you don't need sudo to install.
export SUDO=sudo

# directory for the sources
export SRCDIR=${BASEDIR}/src

libArcus_packages="
 python3-sip-dev python3-sip-dbg
 protobuf-compiler libprotobuf-dev libprotoc-dev
"
libSavitar_packages="
 python3-sip-dev python3-sip-dbg
"
CuraEngine_packages="
 python3-all-dev
 protobuf-compiler libprotobuf-dev
 libcppunit-dev
"
Cura_packages="
 qttools5-dev qttools5-dev-tools
 gettext
 python3-pytest pylint3
 qml-module-qtqml-models2
 qml-module-qtquick-controls
 qml-module-qtquick-dialogs
 qml-module-qt-labs-settings
 qml-module-qt-labs-folderlistmodel
 qml-module-qtquick-layouts
 python-serial python-zeroconf
 python3-pyqt5
 python3-pyqt5.qtopengl
 python3-pyqt5.qtquick
 python3-pyqt5.qtsvg
 "
Uranium_packages="
 python3-pyqt5 python3-numpy
 doxygen
 gettext
 python3-pytest pylint3
 python3-scipy
 qml-module-qtqml-models2
 qml-module-qtquick-dialogs
 python3-colorlog
 libopenblas-base
"
fdm_materials_packages=""
Slic3r_prusa_packages="
 libextutils-cppguess-perl
 libboost-thread-dev libboost-log-dev libboost-locale-dev
 libtbb-dev libalien-wxwidgets-perl
 libeigen3-dev libglew-dev
 libextutils-typemaps-default-perl libextutils-xspp-perl
 liblocal-lib-perl libwx-perl libopengl-perl libwx-glcanvas-perl
"


# git repositories
ultimaker_url="https://github.com/Ultimaker/"
Slic3r_prusa_url="https://github.com/prusa3d/Slic3r_prusa/"

libArcus_tag=${build_tag}
libArcus_url="${ultimaker_url}/libArcus"
libSavitar_tag=${build_tag}
libSavitar_url="${ultimaker_url}/libSavitar"
CuraEngine_tag=${build_tag}
CuraEngine_url="${ultimaker_url}/CuraEngine"
Cura_tag=${build_tag}
Cura_url="${ultimaker_url}/Cura"
Uranium_tag=${build_tag}
Uranium_url="${ultimaker_url}/Uranium"
fdm_materials_tag=master
fdm_materials_url="${ultimaker_url}/fdm_materials"




function build() {
    local part=${1}
    local branch
    eval sudo apt -y install "\${${part}_packages}"
    cd ${SRCDIR}
    if [ ! -d ${part} ]; then
        eval git clone "\${${part}_url}" ${part}
    fi
    cd ${part}
    eval branch="\${${part}_tag}"
    git fetch
    git checkout ${branch}
    if git branch -a | grep -q ${branch}; then
        git reset --hard origin/${branch}
    fi
    rm -rf build
    mkdir build && cd build
    ${CMAKE} ..
    make
    sudo make install
}

sudo apt update
sudo apt -y install build-essential cmake make git python3-all-dev python3-all-dbg

for tool in "${TOOLS}"; do
    build "${tool}"
done

