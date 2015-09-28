# polarimetryLab

## Spectopolar
This program computes spcetropolarimetry.

**Outline** The program takes the six [or four] filtered spectra (i.e. anti-diagonal, vertical, diagonal, horizontal [lefthand circular, and righthand circular]) and produces a CSV file with the intensity, degree of linear polarization, angle of polarization [and degree of circular polarization] per wavelength.

### Instructions
1. Record the following 7 or 5 spectra: `l315c0`, `l0c0`, `l45c0`, `l90c0` [and `l0c315`, `l0c45`], and `dark`. Where `dark` is an additional spectrum without the light source (but with the same integration time!). All these spectra *must* have the same integration time. 
2. Make sure you set an integration time such that the maximum possible value in the wavelength interval of interest is not saturated but isn't too low either. 
3. Save the files as tab-delimited with a header.
4. Make sure the apparatus is pointing at the specimen and nothing else.
5. When done, double-click the `Spectopolar` icon <img src="src/icon.png" width="25" height="25">.
6. The CSV file and an additional PDF plot of the results will be in the same folder where you saved the spectrum files.

![](src/example.png)

## Photopolar
This program computes photopolarimetry.
