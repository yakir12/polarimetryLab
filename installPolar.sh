# Todo: 
# find how to just run ./installPolar.sh without the need to copy paste each line seperately

# gain root
sudo -i

# julia. git will now be installed
add-apt-repository -y ppa:staticfloat/juliareleases
apt-get update
apt-get -y install julia

#imagemagick
# (maybe not needed: add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe" && apt-get update && apt-get -y install imagemagick --fix-missing)
apt-get -y remove imagemagick
apt-get -y install build-essential checkinstall
apt-get -y build-dep imagemagick
wget http://www.imagemagick.org/download/ImageMagick-6.9.2-4.tar.gz
tar xzvf ImageMagick-6.9.2-4.tar.gz
cd ImageMagick-6.9.2-4/
./configure --prefix=/opt/imagemagick-6.9 
make
# a lot of user interface coming up, not sure how to automate that now:
checkinstall
# Done. The new package has been installed and saved to
#  /root/ImageMagick-6.9.2-4/imagemagick-6.9.2_4-1_amd64.deb
#  You can remove it from your system anytime using: 
#       dpkg -r imagemagick-6.9.2
ln -s /opt/imagemagick-6.9/bin/animate /usr/bin/
ln -s /opt/imagemagick-6.9/bin/compare /usr/bin/
ln -s /opt/imagemagick-6.9/bin/composite /usr/bin/
ln -s /opt/imagemagick-6.9/bin/conjure /usr/bin/
ln -s /opt/imagemagick-6.9/bin/convert /usr/bin/
ln -s /opt/imagemagick-6.9/bin/display /usr/bin/
ln -s /opt/imagemagick-6.9/bin/identify /usr/bin/
ln -s /opt/imagemagick-6.9/bin/import /usr/bin/
ln -s /opt/imagemagick-6.9/bin/mogrify /usr/bin/
ln -s /opt/imagemagick-6.9/bin/montage /usr/bin/
ln -s /opt/imagemagick-6.9/bin/stream /usr/bin/

#dcraw
apt-get -y install dcraw

#################################
## later:
##manual setup for wireless connection with Eduroam
##vim
#apt-get -y install vim-gnome
## seabreeze
#git clone https://github.com/ap--/python-seabreeze.git
#apt-get -y install python-numpy python-pip libusb-1.0-0
#pip -y install pyusb==1.0.0b1
#cd python-seabreeze
#python setup.py install --without-cseabreeze
##LaTex
#apt-get -y install texlive-full

##################################

# this is necesary for the http and medbus stuff in julia for some reason, might be unnecessary in the future:
apt-get install libhttp-parser2.1 
apt-get install cmake 

#exit su
exit

# julia packages
julia -e 'map(Pkg.add, ["Winston", "PyCall", "Images", "Colors", "Reactive", "Escher", "ImageView", "Tk"])'


# Escher
sudo ln -s /home/polar/.julia/v0.4/Escher/bin/escher /usr/local/bin/

#Chromium 

apt-get install chromium-browser

# polarimetryLab
git clone https://github.com/yakir12/polarimetryLab


# general update
#apt-get update
#apt-get -y upgrade
