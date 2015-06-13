#!/bin/bash

echo '########## This script prepares a Debian 8(Jessie) x64 system for the ######'
echo '########## Doubango Open Telepresence requirements and install script ######'
echo '########## By: Sylvester Mitchell ###### June 10, 2015 #####################'

sleep 3
echo 'Enable non free repository'
sleep 2
echo "" >> /etc/apt/sources.list
echo "#nonfree" >> /etc/apt/sources.list
echo "deb http://ftp.us.debian.org/debian/ jessie main contrib non-free" >> /etc/apt/sources.list
echo "deb-src http://ftp.us.debian.org/debian/ jessie main contrib non-free" >> /etc/apt/sources.list
sleep 2


echo 'Updating operating system'
sleep 2

apt-get -y update
apt-get -y upgrade

sleep 3

echo 'Lets update the time'
apt-get -y install ntp ntpdate
ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
ntpdate time-a.nist.gov

sleep 3

apt-get -y install gcc g++ automake wget make git subversion chkconfig nano
apt-get -y install libtool autoconf cmake pkg-config nasm bzip2

sleep 3

apt-get -y install libspeexdsp-dev libssl libssl-dev libogg-dev libtheora-dev libvorbis-dev libspeex-dev yasm
apt-get -y install libvpx-dev libgsm1-dev libfaac-dev yasm libspeex1

sleep 3
echo 'Installing libsrtp'
sleep 2

cd /usr/src
git clone https://github.com/cisco/libsrtp/
cd libsrtp
git checkout v1.5.0
CFLAGS="-fPIC" ./configure --enable-pic && make && make install
ldconfig

sleep 3
echo 'Installing Opencore-AMR'
sleep 2
cd /usr/src
git clone git://opencore-amr.git.sourceforge.net/gitroot/opencore-amr/opencore-amr
cd opencore-amr && autoreconf --install && ./configure && make && make install
ldconfig

sleep 3
echo 'Installing libopus'
sleep 2
cd /usr/src
wget http://downloads.xiph.org/releases/opus/opus-1.0.2.tar.gz
tar -xvzf opus-1.0.2.tar.gz
rm opus-1.0.2.tar.gz
cd opus-1.0.2
./configure --with-pic --enable-float-approx && make && make install
ldconfig

sleep 3
echo 'Installing g729b'
sleep 2
cd /usr/src
svn co http://g729.googlecode.com/svn/trunk/ g729b
cd g729b
./autogen.sh && ./configure --enable-static --disable-shared && make && make install
ldconfig

sleep 3
echo 'Installing x264'
sleep 2 
cd /usr/src
wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar -xvjf last_x264.tar.bz2
rm /usr/src/x264_install.txt
echo "because of how the software unpacks, i can't reliably script in the filename. leaving text file instructions to complete manually."
echo "cd into extracted folder & run this to complete installation ./configure --enable-shared --enable-pic && make && make install && ldconfig" >> /usr/src/x264_install.txt
read -p "Open another terminal window. Navigate to src directory and install. press enter when you completed installation..."
sleep 3
echo 'Installing freetype2'
sleep 2 
cd /usr/src
wget http://download.savannah.gnu.org/releases/freetype/freetype-2.4.12.tar.bz2
tar xjf freetype-2.4.12.tar.bz2
rm freetype-2.4.12.tar.bz2
cd freetype-2.4.12 && ./configure && make && make install && ldconfig

sleep 3
echo 'Installing OpenH264'
sleep 2
cd /usr/src
git clone https://github.com/cisco/openh264.git
cd openh264
git checkout v1.1
make ENABLE64BIT=Yes # Use ENABLE64BIT=No for 32bit platforms
make install
ldconfig

sleep 3
echo 'Installing ffmpeg'
sleep 2 
cd /usr/src
git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg
cd ffmpeg
git checkout n1.2
./configure --extra-cflags="-fPIC" --extra-ldflags="-lpthread" --enable-pic --enable-memalign-hack --enable-pthreads --enable-shared --disable-static --disable-network --enable-pthreads --disable-ffmpeg --disable-ffplay --disable-ffserver --disable-ffprobe --enable-gpl --disable-debug --enable-libfreetype --enable-libfaac --enable-nonfree --enable-libx264 --enable-encoder=libx264 --enable-decoder=h264
make && make install
ldconfig

sleep 3
echo 'Installing OpenAL'
sleep 2 
cd /usr/src
wget http://kcat.strangesoft.net/openal-releases/openal-soft-1.15.1.tar.bz2
tar xjf openal-soft-1.15.1.tar.bz2
rm openal-soft-1.15.1.tar.bz2
cd openal-soft-1.15.1/build
cmake ..
make && make install
ldconfig

sleep 3
echo 'Installing OpenOffice Application'
sleep 2 
cd /usr/src
wget http://sourceforge.net/projects/openofficeorg.mirror/files/4.0.0/binaries/en-US/Apache_OpenOffice_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz
mkdir -p OpenOfficeApplication && tar -zxvf Apache_OpenOffice_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz -C OpenOfficeApplication
dpkg -i OpenOfficeApplication/en-US/DEBS/*.deb

sleep 3
echo 'Installing OpenOffice SDK'
sleep 2 
cd /usr/src
wget http://sourceforge.net/projects/openofficeorg.mirror/files/4.0.0/binaries/SDK/Apache_OpenOffice-SDK_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz
mkdir -p OpenOfficeSDK && tar -zxvf Apache_OpenOffice-SDK_4.0.0_Linux_x86-64_install-deb_en-US.tar.gz -C OpenOfficeSDK
dpkg -i OpenOfficeSDK/en-US/DEBS/*.deb

LD_LIBRARY_PATH=/opt/openoffice4/program:/opt/openoffice4/sdk/lib /opt/openoffice4/sdk/bin/cppumaker -BUCR -O /opt/openoffice4/sdk/includecpp /opt/openoffice4/program/types.rdb

echo "PATH=$PATH:/opt/openoffice4/program" >> /etc/environment
source /etc/environment

apt-get -y install openjdk-7-jdk
apt-get -y install libspeexdsp1 libspeexdsp-dev

sleep 3
echo 'Installing Doubango Framework'
sleep 2 
cd /usr/src
svn checkout http://doubango.googlecode.com/svn/branches/2.0/doubango doubango
cd doubango && ./autogen.sh && ./configure --with-speexdsp --with-ffmpeg
make
make install
ldconfig

sleep 3
echo 'Installing Doubango Telepresence'
sleep 2 
cd /usr/src
svn checkout https://telepresence.googlecode.com/svn/trunk/ telepresence
cd telepresence
./autogen.sh && ./configure
make && make install && ldconfig
make samples

cd ..

echo 'Installing Doubango OpenTelepresence complete....'


























