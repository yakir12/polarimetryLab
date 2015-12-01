push!(LOAD_PATH, pwd())
const assets = "assets"
using Images, ImageMagick, Colors, Photopolarimetry
import Tk.ChooseDirectory
#include("Photopolar.jl")
include("PhotopolarGUIfunctions.jl")

path = Input(ChooseDirectory())
flip = Input(false)
flop = Input(false) 
torun = Input{Any}(leftbutton)
rotate = Input(0)
cropright = Input(100)
cropbottom = Input(100)
cropleft = Input(0)
croptop = Input(0)
scale = Input(20)
topI = Input(100)
topdolp = Input(100)
topdolcp = Input(100)
topdorcp = Input(100)
botprofile = Input(0)
topprofile = Input(100)
Sp = Input(5)
ellipse_window = Input(0.5)
minpol = Input(0.2)
maxpol = Input(1.0)
eccentricity = Input(0.01)

torun2 = Input{Any}(leftbutton)

fnames = lift(getfnames,path)
SZ = lift(x -> getsz(x[1]),fnames)
lift(x -> write_originalRGB(x[1]),fnames)

row1 = ["Flip", checkbox(false) >>> flip, "Flop", checkbox(false) >>> flop, button("Done!") >>> torun]
row2 = ["Rotate", slider(-90:90,value=0) >>> rotate, "Scale", slider(1:100,value=20) >>> scale]
row3 = ["Crop top", slider(0:99,value=0) >>> croptop, "Crop bottom", slider(1:100,value=100) >>> cropbottom]
row4 = ["Crop left", slider(0:99,value=0) >>> cropleft, "Crop right", slider(1:100,value=100) >>> cropright]

mymin(u,l) = u > l ? l : u - 1
botprofile2 = lift(mymin, topprofile, botprofile)



s = lift(_ -> path2stokes(value(path),value(flip),value(flop),value(rotate),value(cropright),value(cropbottom),value(cropleft),value(croptop),value(scale), angleoffset = deg2rad(60)), torun, typ=Any, init=empty)
polarimgs = lift(calculatepolar, s, typ=Any, init=empty)

I = lift((x,t) -> recolor_I(x[1],t),polarimgs,topI,typ=Any, init=empty)
dolp = lift((x,t) -> recolor_dolp(x[2],t),polarimgs,topdolp,typ=Any, init=empty)
docp = lift((x,b,t) -> recolor_docp(x[4],b,t),polarimgs,topdolcp,topdorcp,typ=Any, init=empty)


profileimg = lift(stokes2profile, s, Sp, typ=Any, init=empty)
ellipse_img_name = lift(latexellipse, s, ellipse_window, maxpol, minpol, eccentricity, typ=Any, init=empty)

orientationtab = vbox(map(pad(0.5em),[
	hbox(map(pad(0.5em), row1)),
	hbox(map(pad(0.5em), row2)),
	hbox(map(pad(0.5em), row3)),
	hbox(map(pad(0.5em), row4)),
	consume(flip,flop,rotate,cropright,cropbottom,cropleft,croptop,scale) do flp, flP, rtt, crprght, crpbttm, crplft, crptp, scl
		@async cleanassets()
		name = updateRGB(flp,flP,rtt,crprght,crpbttm,crplft,crptp,scl)
		image("$assets/$name.jpg")
	end,
	])) 

intensitytab = vbox(map(pad(0.5em),[
	hbox("Intensity", slider(0:100, value = 100) >>> topI),
	hbox("DoLP", slider(0:100, value = 100) >>> topdolp),
	hbox("DoLCP", slider(0:100, value = 100) >>> topdolcp),
	hbox("DoRCP", slider(0:100, value = 100) >>> topdorcp),
	consume(I, dolp, docp, polarimgs, typ=Any, init=empty) do i, dlp, dcp, p
		buff = Image(ones(RGB{FixedPointNumbers.UFixed{UInt8,8}},10,size(i,2)))
		cat(1,i, buff, dlp, buff, p[3], buff, dcp)
	end
	]))

profiletab = vbox(map(pad(0.5em),[
	hbox(map(pad(0.5em),["upper", slider(2:100, value = 100) >>> topprofile])),
	consume(topprofile) do x
		hbox(map(pad(0.5em),["Lower", slider(0:(x - 1), value = 0) >>> botprofile]))
	end,
	hbox(map(pad(0.5em),[tex("S_p"), slider(2:10, value = 5) >>> Sp])),
iiimg = lift(recolor_profile, profileimg, botprofile2, topprofile, typ=Any, init=empty)
]))

lift(_ -> println(join([splitdir(value(path))[2],value(flip),value(flop),value(rotate),value(cropright),value(cropbottom),value(cropleft),value(croptop),value(scale),value(ellipse_window), value(minpol), value(maxpol), value(eccentricity)],",")), torun2, typ=Any, init=empty)

ellipsetab = vbox(map(pad(0.5em),[
	hbox(map(pad(0.5em),["Cell size (cm)", slider(0.1:0.05:2, value = 0.5) >>> ellipse_window])),
	hbox(map(pad(0.5em),["Min pol.", slider(0:.01:1, value = 0.2) >>> minpol])),
	hbox(map(pad(0.5em),["Max pol.", slider(0:.01:1, value = 1.0) >>> maxpol])),
	hbox(map(pad(0.5em),["Eccentricity", slider(0:.01:1, value = 0.01) >>> eccentricity])),
	button("Done!") >>> torun2,
	lift(image,ellipse_img_name, typ=Any, init=empty)
]))


#=ok = Input{Any}(leftbutton)
donetab = vbox(map(pad(0.5em),[
	button("Print", raised = true) >>> ok,
	consume(ok, typ=Any, init=empty) do o
		colorimg = load("$assets/RGB.jpg")
		aopimg = convert(Image, value(X)[3])
		Iimg = convert(Image, value(I))
		dolpimg = convert(Image, value(dolp))
		docpimg = convert(Image, value(docp))
		buff = round(Int,0.05*mean(widthheight(colorimg)))
		buffimg = Iimg[1:buff,:]
		buffimg[:] = RGB{U8}(1,1,1)
		img = cat(1,colorimg, buffimg, Iimg, buffimg, dolpimg, buffimg, aopimg, buffimg, docpimg) 
		name = string(abs(rand(Int)))
		save( "$assets/$name.jpg",img)
		image("assets/$name.jpg")
	end
	]))=#


function main(window) 
	push!(window.assets, "layout2")	
	push!(window.assets, "widgets")
	push!(window.assets, "tex")

	tabbar = tabs([ hbox("Orientation"), hbox("Photopolarimetry"), hbox("Interneuron"), hbox("Ellipse")])
	tabcontent = pages([ orientationtab, intensitytab, profiletab, ellipsetab])
	
	t, p = wire(tabbar, tabcontent, :tab_channel, :selected)
	vbox(t, p)





end
