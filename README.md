# polarimetryLab

A set of programs that calculate polarization from spectra, stills, and video.

## Spectopolar
This program computes spcetropolarimetry.

**Outline** The program takes filtered spectra (i.e. anti-diagonal, vertical, diagonal, horizontal, lefthand circular, and righthand circular) and produces a CSV file with the spectra, intensity, degree of linear polarization, angle of polarization, and degree of circular polarization per wavelength.

### Instructions
* Place the polarization apparatus in front of the sample you want to measure (you'll need the laptop, USB cable, spectrometer, fiber optic, and apparatus):
![](images/sideview.JPG?raw=true)
* Check to see that the apparatus is looking directly and only at the sample.
* Navigate to [here](http://localhost:5555/SpectropolarimetryGUI.jl).
* Wait a minute or two (you'll see a live output of the spectrometer and a pdf file with the (for now, empty) polarization curves).
* Input the desired integration time in micro seconds.
* Make sure you set an integration time such that the maximum possible value in the wavelength interval of interest is not saturated but isn't too low either (play with the Glan–Thompson and Fresnel rhomb to make sure the integration time is not too high). 
* Input the number of spectra to average: as many as you have patience for (depends on the integration time).
* Set the linear (l) dial and the circular (c) dial according to the prompt (see table below). 

dial    |code|anti-diagonal|vertical|diagonal|horizontal|lefthand circular|righthand circular
---     |--- |---          |---     |---     |---       |---              |---
linear  |l   |315          |0       |45      |90        |0                |0
circular|c   |0            |0       |0       |0         |315              |45

![](images/topview.JPG?raw=true)
* "DARK" is an additional spectrum without the light source (but with the same integration time!). 
* The CSV file, `data.csv`, and an additional PDF plot, `plot.pdf`, of the results will be in the `polar/src` directory.

![](images/example.png?raw=true)

## Photopolar
This program computes photopolarimetry.

**Outline** The program takes filtered images (i.e. anti-diagonal, vertical, diagonal, horizontal, lefthand circular, and righthand circular) and produces four polarization images that describe the intensity, degree of linear polarization, angle of polarization, and degree of circular polarization. The porgram generates the polarization receptor activity (see [Polarization distance: a framework for modelling object detection by polarization vision systems](http://rspb.royalsocietypublishing.org/content/281/177)) as well as a polarization ellipse representation of the image (see [Biologically inspired representation of photopolarimetric data using the polarization ellipse]()).

### Instructions
* Photograph your subject through the following filters in the following order: anti-diagonal, vertical, diagonal, horizontal, and if you want circular polarization as well: lefthand circular, and righthand circular. 
* For the best results use the D300 Nikon with the filter rings attached to the lens. 
* You have to save the images in raw format (e.g. `NEF`)
* Navigate to [here](http://localhost:5555/photoPolar.jl).
* You'll get a navigation window: navigate to where the folder with all the raw images are.
* Manipulate (rotate, flip, flop, crop, etc.) your image to include only what you want.
* Press `Done`.
* After a few seconds the results will be in the other tabs.
* You can save the photopolarimetry images from the browser (with `Save image as...`).
* The polarization ellipse image can also be saved in the same way, but the much higher quality PDF file is in `polar/src`.
