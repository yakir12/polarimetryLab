# polarimetryLab

A set of programs that calculate polarization from spectra, stills, and video.

## Spectopolar
This program computes spcetropolarimetry.

**Outline** The program takes the six [or four] filtered spectra (i.e. anti-diagonal, vertical, diagonal, horizontal, [lefthand circular, and righthand circular]) and produces a CSV file with the intensity, degree of linear polarization, angle of polarization, [and degree of circular polarization] per wavelength.

### Instructions
* Place the polarization apparatus in front of the sample you want to measure (you'll need the laptop, USB cable, spectrometer, fiber optic, and apparatus):
![](images/sideview.JPG?raw=true)
* Check to see that the apparatus is looking directly and only at the sample.
* Double-click the `Spectopolar` icon <img src="images/icon.png" width="25" height="25"> on the desktop.
* Input the desired integration time in seconds and press enter.
* Make sure you set an integration time such that the maximum possible value in the wavelength interval of interest is not saturated but isn't too low either (play with the Glan–Thompson and Fresnel rhomb to make sure the integration time is not too high). 
* Input some non-numerical letter (`a`-`z`) when you're happy with the integration time.
* Input the number of spectra to average: as many as you have patience for (depends on the integration time).
* Set the linear (l) dial and the circular (c) dial according to the prompt (see table below). Press enter when done. 

dial    |code|anti-diagonal|vertical|diagonal|horizontal|lefthand circular|righthand circular
---     |--- |---          |---     |---     |---       |---              |---
linear  |l   |315          |0       |45      |90        |0                |0
circular|c   |0            |0       |0       |0         |315              |45

![](images/topview.JPG?raw=true)
* "dark" is an additional spectrum without the light source (but with the same integration time!). 
* The CSV file and an additional PDF plot of the results will be in the `home` directory (these are named by the time stamp of when they were created).

![](images/example.png?raw=true)

## Photopolar
This program computes photopolarimetry.

**Outline** The program takes the six filtered images (i.e. anti-diagonal, vertical, diagonal, horizontal, lefthand circular, and righthand circular) and produces five polarization images that describe the RGB, intensity, degree of linear polarization, angle of polarization, and degree of circular polarization. 

### Instructions
* Photograph your subject through the following filters in the following order: anti-diagonal, vertical, diagonal, horizontal, and if you want circular polarization as well: lefthand circular, and righthand circular. 
* Put (copy/move) these images in the folder `raw`, making sure you have only 4 or 6 images (depending if you want circular polarization or not) in the `raw` folder.
* Double click the icon.
* Wait for the "Done" message.
* The polarimetry images are now in the folder 
* Take (copy/move) the resulting images from the folder because any subsequent runs will erase anything in the folder.  
* For the best results use the D300 Nikon with the filter rings attached to the lens. 

