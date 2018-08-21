#!/bin/bash

sudo apt-get purge -y wolfram-engine
sudo apt-get -y purge libreoffice*
sudo apt-get -y clean
sudo apt-get -y autoremove

sudo apt-get update && sudo apt-get -y upgrade
sudo apt-get install -y build-essential cmake pkg-config
sudo apt-get install -y libjpeg-dev libtiff5-dev libjasper-dev libpng12-dev
sudo apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libv4l-dev
sudo apt-get install -y libxvidcore-dev libx264-dev
sudo apt-get install -y libgtk2.0-dev libgtk-3-dev
sudo apt-get install -y libcanberra-gtk*
sudo apt-get install -y libatlas-base-dev gfortran
sudo apt-get install -y python2.7-dev python3-dev

cd $HOME
wget -O opencv.zip https://github.com/opencv/opencv/archive/3.3.0.zip
unzip opencv.zip
rm -rf opencv.zip 

wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/3.3.0.zip
unzip opencv_contrib.zip
rm -rf opencv_contrib.zip

cd $HOME 
wget https://bootstrap.pypa.io/get-pip.py
sudo python get-pip.py
sudo python3 get-pip.py
sudo pip install virtualenv virtualenvwrapper
sudo rm -rf ~/.cache/pip

export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3

# virtualenv and virtualenvwrapper
echo 'export WORKON_HOME=$HOME/.virtualenvs' >> $HOME/.profile 
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3' >> $HOME/.profile

source /usr/local/bin/virtualenvwrapper.sh

source $HOME/.profile

mkvirtualenv cv -p python3

workon cv

pip install numpy pyzbar imutils picamera dlib face_recognition

cd $HOME/opencv-3.3.0/

mkdir build

cd build

cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib-3.3.0/modules \
    -D ENABLE_NEON=ON \
    -D ENABLE_VFPV3=ON \
    -D BUILD_TESTS=OFF \
    -D INSTALL_PYTHON_EXAMPLES=OFF \
    -D BUILD_EXAMPLES=OFF ..
    
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/g' /etc/dphys-swapfile    

sudo /etc/init.d/dphys-swapfile restart

make -j4

sudo make install

sudo ldconfig

sudo sed -i 's/CONF_SWAPSIZE=1024/CONF_SWAPSIZE=100/g' /etc/dphys-swapfile 

cd /usr/local/lib/python3.5/dist-packages/

sudo mv cv2.cpython-35m-arm-linux-gnueabihf.so cv2.so

cd ~/.virtualenvs/cv/lib/python3.5/site-packages/

ln -s /usr/local/lib/python3.5/dist-packages/cv2.so cv2.so

cd $HOME 

source $HOME/.profile

source /usr/local/bin/virtualenvwrapper.sh

workon cv

cv_version_python3=$(python3 -c 'import cv2; print(cv2.__version__)')

cv_version_python2=$(python2 -c 'import cv2; print(cv2.__version__)')

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

if [ "$cv_version_python2" = "3.3.0" ]; then
  printf "installation of openCV for python 2 is ${GREEN}[ok \xE2\x9C\x94]\n${NC}"
else
  printf "installation of openCV is ${RED}[bad X]\n${NC}"    
fi

if [ "$cv_version_python3" = "3.3.0" ]; then
  printf "installation of openCV for python 3 is ${GREEN}[ok \xE2\x9C\x94]\n${NC}"
else
  printf "installation of openCV is ${RED}[bad X]\n${NC}"    
fi


