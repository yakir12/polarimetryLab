getsz(fname) = map(x -> parse(Int,x),split(readall(`identify -ping -format '%w %h' $fname`)))
SZ = getsz("RGB0.jpg")

## Orientation
flip = Input(false)
flop = Input(false)
rotate = Input(0)
cropright = Input(100)
cropbottom = Input(100)
cropleft = Input(0)
croptop = Input(0)
scale = Input(50)

function build_orientation(flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	toflip = flip ? `-flip` : ``
	toflop = flop ? `-flop` : ``
	sz = SZ*scale/100
	w0 = sz[1]*cosd(rotate) +  sz[2]*cosd(90 - abs(rotate))
	w = round(Int, w0*cropright/100)
	h0 = sz[1]*sind(abs(rotate)) +  sz[2]*sind(90 - abs(rotate))
	h = round(Int, h0*cropbottom/100)
	x = round(Int, w0*cropleft/100)
	y = round(Int, h0*croptop/100)
	return `-scale $scale% $toflip $toflop -rotate $rotate +repage -crop $(w)x$h+$x+$y`
end
function only_orient(what,flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	o = build_orientation(flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	name = string(abs(rand(Int)))
	run(`convert $what.jpg $o assets/$name.jpg`) 
	return name
end
function only_rescale(what,top)
	name = string(abs(rand(Int)))
	run(`convert $what.jpg -level 0,$top% assets/$name.jpg`) 
	return name
end
function both(what, flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale, top)
	o = build_orientation(flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	name = string(abs(rand(Int)))
	run(`convert $what.jpg $o -level 0,$top% assets/$name.jpg`) 
	return name
end
function dothemall(flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale, topI, topdolp, topdolcp, topdorcp)
	o = build_orientation(flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	run(`convert RGB0.jpg $o assets/RGB.jpg` & `convert I0.jpg -level 0,$topI% $o assets/I.jpg` & `convert dolp0.jpg -level 0,$topdolp% $o assets/dolp.jpg` & `convert aop0.jpg ( -size 1x256 gradient:'#FFF-#0FF' -rotate 90 -set colorspace HSB -colorspace RGB ) -clut $o assets/aop.jpg` & `convert ( ( dolcp0.jpg -level 0,$topdolcp% ) ( -size 1x256 gradient:red-black -rotate 90 ) -clut ) ( dorcp0.jpg -level 0,$topdorcp% (  -size 1x256 gradient:green1-black -rotate 90 ) -clut ) -compose Screen  -composite $o assets/docp.jpg`) 
	sz = getsz("assets/RGB.jpg")
	w, h = sz
	m = (w + h)/2
	w2 = 0.05m
	w3 = 0.2m
	buff = 0.02m
	buff1 = `-gravity center -extent $(w + 2buff)x$h`
	buff2 = `-gravity center -extent $(w2 + w + 2buff)x$h`
	run(`convert ( -size $(w2)x$(h*(1 - topdolp/100)) xc:wheat ) ( -size $(w2)x$(h*topdolp/100) gradient:white-black ) -append assets/dolpcmap.jpg`)
	run(`convert -size $(w2)x$h gradient:'#FFF-#0FF' -set colorspace HSB -colorspace RGB assets/aopcmap.jpg`)
	aopradialcmap = `-size $(w3)x$(3w3) gradient:'#FFF-#0FF' -rotate 90 -alpha set -virtual-pixel Transparent +distort Polar 49 +repage -rotate 90 -set colorspace HSB -colorspace RGB -resize $(w3)x$w3 -background none -gravity center  -extent 120x120%`
	run(`convert ( -size $(w2)x$(h/2*(1 - topdolcp/100)) xc:wheat ) ( -size $(w2)x$(h/2*topdolcp/100) gradient:green1-black ) ( -size $(w2)x$(h/2*topdorcp/100) gradient:black-red ) ( -size $(w2)x$(h/2*(1 - topdorcp/100)) xc:wheat ) -append assets/docpcmap.jpg`)
	run(`convert -background white ( assets/RGB.jpg $buff1 ) ( assets/I.jpg $buff1 ) ( ( xc:red assets/dolp.jpg assets/dolpcmap.jpg +append -crop +0+1 +repage ) $buff2 ) ( ( assets/aop.jpg ( $aopradialcmap ) -gravity NorthEast -composite )  -background white $buff1 ) ( assets/docp.jpg assets/docpcmap.jpg +append $buff2 ) +append -trim assets/photopolarimetry.jpg`)
	name = string(abs(rand(Int)))
	cp("assets/photopolarimetry.jpg","assets/$name.jpg")
	return name
end



#=a = lift(x -> only_orient(:RGB,flip = x), flip)
a = lift(x -> only_orient(:RGB,flop = x), flop)
a = lift(x -> only_orient(:RGB,rotate = x), rotate)
a = lift(x -> only_orient(:RGB,cropright = x), cropright)
a = lift(x -> only_orient(:RGB,cropbottom = x), cropbottom)
a = lift(x -> only_orient(:RGB,cropleft = x), cropleft)
a = lift(x -> only_orient(:RGB,croptop = x), croptop)
a = lift(x -> only_orient(:RGB,scale = x), scale)=#

row1 = ["Flip", checkbox(false) >>> flip, "Flop", checkbox(false) >>> flop, "Rotate", slider(-90:90,value=0) >>> rotate, "Scale", slider(1:100,value=50) >>> scale]
row2 = ["Crop top", slider(0:99,value=0) >>> croptop, "Crop bottom", slider(1:100,value=100) >>> cropbottom]
row3 = ["Crop left", slider(0:99,value=0) >>> cropleft, "Crop right", slider(1:100,value=100) >>> cropright]

orientationtab = vbox(map(pad(0.5em),[
	hbox(map(pad(0.5em), row1)),
	hbox(map(pad(0.5em), row2)),
	hbox(map(pad(0.5em), row3)),
	consume(flip,flop,rotate,cropright,cropbottom,cropleft,croptop,scale) do flp, flP, rtt, crprght, crpbttm, crplft, crptp, scl
		name = only_orient(:RGB0,flp,flP,rtt,crprght,crpbttm,crplft,crptp,scl)
		image("assets/$name.jpg")
	end
	])) 

## Scale I
topI0 = Input(100)
intensitytab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topI0,
	consume(topI0) do tpI
		name = only_rescale(:I,tpI)
		image("assets/$name.jpg")
	end
	]))

topdolp0 = Input(100)
dolptab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topdolp0,
	consume(topdolp0) do tpdlp
		name = only_rescale(:dolp,tpdlp)
		image("assets/$name.jpg")
	end
	]))

topdolcp0 = Input(100)
dolcptab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topdolcp0,
	consume(topdolcp0) do tpdlcp
		name = only_rescale(:dolcp,tpdlcp)
		image("assets/$name.jpg")
	end
	]))

topdorcp0 = Input(100)
dorcptab = vbox(map(pad(0.5em),[
	slider(0:100, value = 100) >>> topdorcp0,
	consume(topdorcp0) do tpdrcp
		name = only_rescale(:dorcp,tpdrcp)
		image("assets/$name.jpg")
	end
	]))

ok = Input{Any}(leftbutton)
donetab = vbox(map(pad(0.5em),[
	button("Print", raised = true) >>> ok,
	consume(ok) do o
		name = dothemall(value(flip), value(flop), value(rotate), value(cropright), value(cropbottom), value(cropleft), value(croptop), value(scale), value(topI0), value(topdolp0), value(topdolcp0), value(topdorcp0))
		image("assets/$name.jpg")

		#o = build_orientation(value(flip), value(flop), value(rotate), value(cropright), value(cropbottom), value(cropleft), value(croptop), value(scale))
		#name = string(abs(rand(Int)))
		#run(`convert RGB0.jpg ( I0.jpg -level 0,$(value(topI0))% ) ( dolp0.jpg -level 0,$(value(topI0))% ) ( aop0.jpg ( -size 1x256 gradient:'#FFF-#0FF' -rotate 90 -set colorspace HSB -colorspace RGB ) -clut ) ( ( dolcp0.jpg -level 0,$(value(topI0))% ( -size 1x256 gradient:red-black -rotate 90 ) -clut ) ( dorcp0.jpg -level 0,$(value(topI0))% (  -size 1x256 gradient:green1-black -rotate 90 ) -clut ) -compose Screen  -composite ) $o +append assets/$name.jpg`) 
		#run(`convert RGB0.jpg ( I0.jpg -level 0,$(value(topI0))% ) ( ( dolp0.jpg -level 0,$(value(topI0))% ) ( -size $(round(Int,SZ[1]))x$(SZ[2]) gradient:blue-red ) -append ) ( aop0.jpg ( -size 1x256 gradient:'#FFF-#0FF' -rotate 90 -set colorspace HSB -colorspace RGB ) -clut ) ( ( dolcp0.jpg -level 0,$(value(topI0))% ( -size 1x256 gradient:red-black -rotate 90 ) -clut ) ( dorcp0.jpg -level 0,$(value(topI0))% (  -size 1x256 gradient:green1-black -rotate 90 ) -clut ) -compose Screen  -composite ) $o +append assets/$name.jpg`) 
		#image("assets/$name.jpg")
#=, value(eval(symbol("top$i"))))
		names = Dict()
		for i in [:I0, :dolp0, :dolcp0, :dorcp0]
			names[i] = both(i, value(flip), value(flop), value(rotate), value(cropright), value(cropbottom), value(cropleft), value(croptop), value(scale), value(eval(symbol("top$i"))))
		end
		for i in [:RGB0, :aop0]
			names[i] = only_orient(i,value(flip), value(flop), value(rotate), value(cropright), value(cropbottom), value(cropleft), value(croptop), value(scale))
		end
		name = string(abs(rand(Int)))
		run(`convert assets/$(names[:RGB0]).jpg assets/$(names[:I0]).jpg assets/$(names[:dolp0]).jpg assets/$(names[:aop0]).jpg +append assets/$name.jpg`) 
		image("assets/$name.jpg")=#
	end
	]))


function main(window) 
	push!(window.assets, "layout2")	
	push!(window.assets, "widgets")

	tabbar = tabs([
	hbox("Orientation"),
	hbox("Intensity"),
	hbox("DoLP"),
	hbox("DoLCP"),
	hbox("DoRCP"),
	hbox("Done!")
	])
	
	tabcontent = pages([
	orientationtab,
	intensitytab,
	dolptab,
	dolcptab,
	dorcptab,
	donetab
	])
	
	t, p = wire(tabbar, tabcontent, :tab_channel, :selected)
	   # ^^^ returns a pair of "connected" tab set and pages
	vbox(t, p)





end
