# Todo: 
# need to install chrome somehow!!!
# find how to just run ./installPolar.sh without the need to copy paste each line seperately
# (I installed vim-gnome)


# gain root
sudo -i

#chrome: 
apt-get -y install chromium-browser

# julia. git will now be installed
add-apt-repository -y ppa:staticfloat/juliareleases
apt-get update
apt-get -y install julia

#imagemagick
# (maybe not needed: add-apt-repository "deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe" && apt-get update && apt-get -y install imagemagick --fix-missing)
apt-get -y remove imagemagick
apt-get -y install build-essential checkinstall
apt-get -y build-dep imagemagick
wget http://www.imagemagick.org/download/ImageMagick-6.9.2-7.tar.gz
tar xzvf ImageMagick-6.9.2-7.tar.gz
cd ImageMagick-6.9.2-7/
./configure --prefix=/opt/imagemagick-6.9 
make
# need to make this "yes" but with enter somehow...
yes '' | checkinstall
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
cd

#dcraw
wget https://www.cybercom.net/~dcoffin/dcraw/archive/dcraw-9.26.0.tar.gz
tar xzvf dcraw-9.26.0.tar.gz
cd dcraw
chmod +x install
./install
cd

#################################
## later:
##manual setup for wireless connection with Eduroam
##vim
#apt-get -y install vim-gnome
## seabreeze
git clone https://github.com/ap--/python-seabreeze.git
apt-get -y install python-numpy python-pip libusb-1.0-0
yes | pip install pyusb==1.0.0b1
cd python-seabreeze
./misc/install_udev_rules.sh
python setup.py install --without-cseabreeze
cd

##LaTex
exit
wget http://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
tar xzvf install-tl-unx.tar.gz 
cd install-tl-20151201/
# some manual input (say "I")
./install-tl
 echo "export PATH=/home/polar/texlive/2015/bin/x86_64-linux:$PATH" >> ~/.profile
 echo "export PATH=/home/polar/texlive/2015/bin/x86_64-linux:$PATH" >> ~/.bashrc
# you need to install pgfplots and maybe tikzscale with tlmgr from 
##################################

## this is necesary for the http and medbus stuff in julia for some reason, might be unnecessary in the future:
#sudo -i
#apt-get install libhttp-parser2.1 
#

#exit su
exit

# julia packages
sudo apt-get install libmagickwand5
sudo apt-get install tcl8.5
sudo apt-get install cmake
julia -e 'map(Pkg.add, ["ImageMagick", "Winston", "PyCall", "Images", "Colors", "Reactive", "Escher", "ImageView", "Tk"])'
julia -e 'Pkg.update()'

# Escher
sudo ln -s /home/polar/.julia/v0.4/Escher/bin/escher /usr/local/bin/

# polarimetryLab
git clone https://github.com/yakir12/polarimetryLab


# general update
#apt-get update
#apt-get -y upgrade

# set chromium as default browser, add the github website as default
add runescher.sh to the autostart!!!


ATTRS{product}=="Ocean*", RUN+="/home/yakir/Documents/Projects/polarimetryLab/src/showSpectrometer.sh"

