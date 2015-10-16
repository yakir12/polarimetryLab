using Images
import Tk.ChooseDirectory
include("Photopolar.jl")

outliar = RGB(0.941176, 0.901961, 0.54902)

function updateRGB(opts...)
	SZ = getsz("originalRGB.jpg")
	opt = build_opt(SZ,opts...)
	name = string(abs(rand(Int)))
	writeRGB(opt,name)
	name
end

function cleanassets()
	files = readdir(assets)
	filter!(r".*\.jpg",files)
	map(x -> rm(joinpath(assets,x)), files)
end

function copyassets()
	files = readdir(assets)
	filter!(r".*\.jpg",files)
	mv(joinpath(assets,files[1]),joinpath(assets,"RGB.jpg"))
end

function recolor_I(img,t)
	n = round(Int,N*t/100)
	cmap = [linspace(RGB(0,0,0),RGB(1,1,1),n);fill(RGB(1,1,1),N - n)]
	img.cmap = cmap
	return img
end

function recolor_dolp(img,t)
	n = round(Int,N*t/100)
	cmap = [linspace(RGB(0,0,0),RGB(1,1,1),n);fill(outliar,N - n)]
	img.cmap = cmap
	return img
end

function recolor_docp(img,b,t)
	nb = round(Int,N/2*b/100)
	nt = round(Int,N/2*t/100)
	cmap = [fill(outliar,Int(N/2) - nb); linspace(RGB(1,0,0),RGB(0,0,0),nb); linspace(RGB(0,0,0),RGB(0,1,0),nt); fill(outliar,Int(N/2) - nt)]
	img.cmap = cmap
	return img
end



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


directorytab = lift(path) do t
	fnames = getfnames(t)
	write_originalRGB(fnames[1])
	vbox(h1("Directory:"),
		vskip(1em),
		t,
		vskip(1em),
		h1("Files:"),
		fnames...) |> pad(1em) |> maxwidth(30em)
end

row1 = ["Flip", checkbox(false) >>> flip, "Flop", checkbox(false) >>> flop, button("Done!") >>> torun]
row2 = ["Rotate", slider(-90:90,value=0) >>> rotate, "Scale", slider(1:100,value=20) >>> scale]
row3 = ["Crop top", slider(0:99,value=0) >>> croptop, "Crop bottom", slider(1:100,value=100) >>> cropbottom]
row4 = ["Crop left", slider(0:99,value=0) >>> cropleft, "Crop right", slider(1:100,value=100) >>> cropright]

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
	X = consume(torun, typ=Any, init=empty) do trn
		copyassets()
		fnames = getfnames(value(path))
		opts = (value(flip),value(flop),value(rotate),value(cropright),value(cropbottom),value(cropleft),value(croptop),value(scale))
		@sync x = get_data(opts,fnames)
		convert2polar(x)
	end
	])) 

intensitytab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topI,
I = lift((x,t) -> recolor_I(x[1],t),X,topI,typ=Any, init=empty)
	]))

dolptab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topdolp,
dolp = lift((x,t) -> recolor_dolp(x[2],t),X,topdolp,typ=Any, init=empty)
	]))

docptab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topdolcp,
	slider(0:100, value = 100) >>> topdorcp,
docp = lift((x,b,t) -> recolor_docp(x[4],b,t),X,topdolcp,topdorcp,typ=Any, init=empty)
	]))


ok = Input{Any}(leftbutton)
donetab = vbox(map(pad(0.5em),[
	button("Print", raised = true) >>> ok,
	consume(ok, typ=Any, init=empty) do o
		colorimg = imread("$assets/RGB.jpg")
		aopimg = convert(Image, value(X)[3])
		Iimg = convert(Image, value(I))
		dolpimg = convert(Image, value(dolp))
		docpimg = convert(Image, value(docp))
		buff = round(Int,0.05*mean(widthheight(colorimg)))
		buffimg = Iimg[1:buff,:]
		buffimg[:] = RGB{U8}(1,1,1)
		img = cat(1,colorimg, buffimg, Iimg, buffimg, dolpimg, buffimg, aopimg, buffimg, docpimg) 
		name = string(abs(rand(Int)))
		imwrite(img, "$assets/$name.jpg")
		image("assets/$name.jpg")
	end
	]))


function main(window) 
	push!(window.assets, "layout2")	
	push!(window.assets, "widgets")


	tabbar = tabs([
	hbox("Navigate"),
	hbox("Orientation"),
	hbox("Intensity"),
	hbox("DoLP"),
	hbox("DoCP"),
	hbox("Done!")
	])
	
	tabcontent = pages([
	directorytab,
	orientationtab,
	intensitytab,
	dolptab,
	docptab,
	donetab
	])
	
	t, p = wire(tabbar, tabcontent, :tab_channel, :selected)
	   # ^^^ returns a pair of "connected" tab set and pages
	vbox(t, p)





end
