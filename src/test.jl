include("Photopolar.jl")
path = "../images/photopol_example"
fnames = getfnames(path)
@async write_originalRGB(fnames[1])
opts = (true, false, 7, 90, 82, 2, 3, 25)
@sync x = get_data(opts,fnames)
I, dolp, aop, docp = convert2polar(x);

#=		colorimg = imread("$assets/RGB.jpg")
		aopimg = convert(Image, aop)
		Iimg = convert(Image,I)
		dolpimg = convert(Image,dolp)
		docpimg = convert(Image,docp)
		buff = round(Int,0.05*mean(widthheight(colorimg)))
		buffimg = Iimg[1:buff,:]
		buffimg[:] = RGB{U8}(1,1,1)
		img = cat(1,colorimg, buffimg, Iimg, buffimg, dolpimg, buffimg, aopimg, buffimg, docpimg) 
		name = string(abs(rand(Int)))
		imwrite(img, "$assets/$name.jpg")

		map(x -> println(size(x)), (colorimg, Iimg, dolpimg, aop, docpimg)) 

		img = cat(1,colorimg, Iimg, dolpimg, aop, docpimg) 
		imwrite(img, "$assets/all.jpg")=#


