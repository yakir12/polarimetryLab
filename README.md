# polarimetryLab

A set of program that calculate polarization from spectra, stills, and video.

## Spectopolar
This program computes spcetropolarimetry.

**Outline** The program takes the six [or four] filtered spectra (i.e. anti-diagonal, vertical, diagonal, horizontal, [lefthand circular, and righthand circular]) and produces a CSV file with the intensity, degree of linear polarization, angle of polarization, [and degree of circular polarization] per wavelength.

### Instructions
* Set `spectraSuite` (or whatever) to `Scans to average`: as many as you have patience for (depends on the integration time), `Boxcar width`: 0, `Strobe/light enable`: false, `Electric dark correction`: false, `Nonlinearity correction`: false, `Stray light correction`: false.
* Make sure the apparatus is pointing at the specimen and nothing else.
* Make sure you set an integration time such that the maximum possible value in the wavelength interval of interest is not saturated but isn't too low either (play with the Glan–Thompson and Fresnel rhomb to make sure the integration time is not too high). 
* Set the Glan–Thompson (l), Fresnel rhomb (c), and name the saved files according to the following:

l|c|file name
---|---|---
315|0| l315c0.txt
0|0| l0c0.txt
45|0| l45c0.txt
90|0| l90c0.txt
0|315| l0c315.txt
0|45| l0c45.txt

The last two are required if you want to know the degree of circular polarization.
* Record exactly 7 or 5 spectra and name them according to: `l315c0.txt`, `l0c0.txt`, `l45c0.txt`, `l90c0.txt` [and `l0c315.txt`, `l0c45.txt`], as well as `dark.txt`. Where `dark.txt` is an additional spectrum without the light source (but with the same integration time!). All these spectra *must* have the same integration time.
* Save the files as tab-delimited with a header.
* When done, double-click the `Spectopolar` icon <img src="src/icon.png" width="25" height="25">.
* The CSV file and an additional PDF plot of the results will be in the same folder where you saved the spectrum files.

![](src/example.png)

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

