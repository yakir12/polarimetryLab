module Photopolarimetry

using Light, Images, ImageMagick, Colors, FixedPointNumbers

export path2stokes, getfnames, build_opt, getsz, stokes2mats, mats2images, stokes2profile, stokes2ellipse

const N = 1000
const N2 = round(Int,N/2)
const prop = Dict(:spatialorder => ["x","y"], :colorspace => "RGB", :pixelspacing => [1,1])

function getfnames(path::AbstractString)
	files = readdir(path)
	filter!(r"^[^\.].*\.(?:NEF|CR2)$",files)
	@assert length(files) == 4 || length(files) == 6
	return map(x -> joinpath(path,x), files)
end
getsz(fname) = map(x -> round(Int,parse(Int,x)/2),split(split(readall(`dcraw -i -v $fname`),'\n')[14])[[3,5]])
function build_opt(SZ,flip, flop, rotate, cropright, cropbottom, cropleft, croptop, scale)
	toflip = flip ? `-flip` : ``
	toflop = flop ? `-flop` : ``
	sz = SZ*scale/100
	w0 = sz[1]*cosd(rotate) +  sz[2]*cosd(90 - abs(rotate))
	w = round(Int, w0*cropright/100)
	h0 = sz[1]*sind(abs(rotate)) +  sz[2]*sind(90 - abs(rotate))
	h = round(Int, h0*cropbottom/100)
	x = round(Int, w0*cropleft/100)
	y = round(Int, h0*croptop/100)
	return ([w,h], `-scale $scale% -rotate $rotate +repage -crop $(w)x$h+$x+$y $toflip $toflop `)
end
#@everywhere 
function myimread(fname::AbstractString,sz::Vector{Int},opt::Cmd)
	stream, _ = open(pipeline(`dcraw -w -H 0 -o 0 -h -4 -c $fname`,`convert - $opt -channel G -separate  Gray:-`)) 
	read(stream, UInt16, 1, sz...)
end
function loaddata{T <: AbstractString}(fnames::Vector{T},sz::Vector{Int},opt::Cmd)
	n = length(fnames)
	#x = Shared
	x = Array(UInt16,n,sz...)
	#@sync @parallel 
	for i = 1:n
		x[i,:,:] = myimread(fnames[i],sz,opt)
	end
	return x
end
function data2stokes(x::Array{UInt16,3}, angleoffset::Real)
	n,w,h = size(x)
	S = Array(Stokes,w,h)
	m = zeros(n)
	for i = 1:w*h
		for j = 1:n
			m[j] = (x[j,i] + 1)/65536
		end
		tmp = Stokes(measurements2stokes(m...)...)
		S[i] = rotate(tmp,angleoffset)
	end
	return S
end
function path2stokes(path::AbstractString,opts...; angleoffset::Real = 0)
	fnames = getfnames(path) 
	SZ = getsz(fnames[1])
	sz, opt = build_opt(SZ, opts...)
	x = loaddata(fnames,sz,opt)
	return data2stokes(x, angleoffset)
end
function path2stokes(path::AbstractString; angleoffset::Real = 0)
	fnames = getfnames(path) 
	SZ = getsz(fnames[1])
	x = loaddata(fnames,SZ,` `)
	return data2stokes(x, angleoffset)
end

roundit(x::Float64) = round(Int, x*(N - 1) + 1)
function normalize(p::Polar)
	if isnan(p.I)
		return (1,1,rand(1:N),N2)
	else
		I = p.I > 1 ? N : roundit(p.I)
		dolp = p.dolp > 1 ? N : roundit(p.dolp)
		aop = I == 1 || dolp == 1 ? rand(1:N) : roundit(p.aop/pi + 0.5)
		tmp = (p.docp + 1)/2
		docp = tmp < 0 ? 1 : tmp > 1 ? N : roundit(tmp)
	end
	return (I,dolp,aop,docp)
end
function colorwheel(r::Int)
	row = Int[]
	col = Int[]
	ind = Int[]
	r2 = r*r
	for i in -r:r, j in -r:r
		if i*i + j*j <= r2
			push!(row,i + r + 1)
			push!(col,j + r + 1)
			tmp = atan2(j,i)/pi
			a = tmp > 0 ? roundit(tmp) : roundit(1 + tmp)
			push!(ind,a)
		end
	end
	return (row,col,ind)
end
function stokes2mats(s::Array{Stokes,2})
	sz = size(s)
	I = zeros(Int,sz)
	dolp = zeros(Int,sz)
	aop = zeros(Int,sz)
	docp = zeros(Int,sz)
	for i in eachindex(s)
		I[i], dolp[i], aop[i], docp[i] = normalize(Polar(s[i]))
	end
	return (I, dolp, aop, docp)
end
function mats2images(I::Array{Int,2},dolp::Array{Int,2},aop::Array{Int,2},docp::Array{Int,2})
	sz = size(I)
	row,col,ind = colorwheel(round(Int,0.1*mean(sz)))
	buff = round(Int,0.025*mean(sz))
	for (r,c,i) in zip(row,col,ind)
		aop[sz[1] - r - buff, c + buff] = i
	end
	Iimg = ImageCmap(I, linspace(RGB(0,0,0),RGB(1,1,1),N); prop...)
	colorbar = repeat(reshape(collect(round(Int,linspace(N,1,sz[2]))),1,sz[2]),outer = [round(Int,0.1sz[1]),1])
	dolpimg = ImageCmap(cat(1,dolp,colorbar),linspace(RGB(0,0,0),RGB(1,1,1),N); prop...)
	aopimg = convert(Image, ImageCmap(aop,convert(Array{RGB{FixedPointNumbers.UFixed{UInt8,8}},1}, linspace(HSV(0,1,1), HSV(360,1,1),N)); prop...))
	docpimg = ImageCmap(cat(1,docp,colorbar), [linspace(RGB(1,0,0),RGB(0,0,0),Int(N/2)); linspace(RGB(0,0,0), RGB(0,1,0),Int(N/2))]; prop...)
	return (Iimg, dolpimg, aopimg, docpimg)
end

profile(a::Stokes,ψ) = (a.s0 + ψ*a.s1)/(a.s0 - ψ*a.s1)
normalizeprofile(x,Sp) = (x - 1/Sp)/(Sp - 1/Sp)

function stokes2profile(s::Array{Stokes,2}, Sp::Number)
	sz = size(s)
	p = zeros(Int,sz)
	ψ = (Sp - 1)/(Sp + 1)
	for i in eachindex(s)
		p[i] = isnan(s[i].s0) ? rand(1:N) : roundit(normalizeprofile(profile(s[i],ψ),Sp))
	end
	colorbar = repeat(reshape(collect(round(Int,linspace(N,1,sz[2]))),1,sz[2]),outer = [round(Int,0.1sz[1]),1])
	ImageCmap(cat(1,p,colorbar),linspace(RGB(0,0,0),RGB(1,1,1),N); prop...)
end


import Base: /, *
immutable Centimeter
	x::Real
end
*(x::Centimeter,y::Real) = x.x*y
*(y::Real,x::Centimeter) = x*y
/(x::Centimeter,y::Real) = x.x/y
/(y::Real,x::Centimeter) = x/y
immutable Pixel
	x::Integer
end
*(x::Pixel,y::Real) = x.x*y
*(y::Real,x::Pixel) = x*y
/(x::Pixel,y::Real) = x.x/y
/(y::Real,x::Pixel) = x/y
immutable Length
	cm::Centimeter
	px::Pixel
end
Length(x::Centimeter,RATIO::Real) = Length(x,Pixel(round(Int,x/RATIO)))
Length(x::Pixel,RATIO::Real) = Length(Centimeter(x*RATIO),x)
findwindow(x::Real,RATIO::Real) = round(x/2/RATIO)*RATIO
function sense(el::PolEllipse,window::Length,maxpol::Real)
	p = round(el.polarization/maxpol,4)
	a = round(window.cm.x*el.a/maxpol,4)
	b = round(window.cm.x*el.b/maxpol,4)
	theta = round(rad2deg(el.angle),4)
	color = el.lefthand ? "dolcpcolor" : "dorcpcolor"
	return (color,p,theta,a,b)
end
function point2measurement(p1::Int,p2::Int,s::Array{Stokes,2},w::Int)
	m = Stokes(0.,0.,0.,0.)
	for j = -w:w, k = -w:w
		tmp = s[p1 + j, p2 + k]
		m += isnan(tmp.s0) ? Stokes(0.,0.,0.,0.) : tmp
	end
	return m/4*w*w
end
function grid(s::Array{Stokes,2},sz::Tuple{Length,Length},window::Length,maxpol::Real,RATIO::Real, minpol::Real, eccentricity::Real, name::AbstractString, linearcolor::RGB)
	open("ellipse.tikz","w") do o
		println(o,"""\\begin{tikzpicture}
			\\begin{axis}[xmin=0,xmax=1,ymin=0,ymax=1, ticks=none, axis lines=none, width = $(sz[1].cm.x) cm, height = $(sz[2].cm.x) cm, scale only axis]
				\\addplot graphics [xmin=0,xmax=1,ymin=0,ymax=1]{$name.jpg};
			\\end{axis}""")
		
		for i = (1 + window.px.x):2window.px.x:(sz[1].px.x - window.px.x), j = (1 + window.px.x):2window.px.x:(sz[2].px.x - window.px.x)
			ss = point2measurement(i,sz[2].px.x - j + 1,s,window.px.x)
			isnan(ss.s0) && continue
			el = PolEllipse(ss)
			el.polarization < minpol && continue
			#isnan(el.a) < minpol && continue
			color,p,theta,a,b = sense(el,window,maxpol)
			x = RATIO*(i - .5)
			y = RATIO*(j - .5)
			#y = RATIO*(sz[2].px.x - (j - 1.5))
			if a/b < eccentricity
				x1 = x + b*cosd(theta + 180 + 90)
				y1 = y + b*sind(theta + 180 + 90)
				x2 = x1 + 2b*cosd(theta + 90)
				y2 = y1 + 2b*sind(theta + 90)
				#println(o,"\\draw [$color,draw opacity = $p] ($x1 cm,$y1 cm) -- ($x2 cm, $y2 cm);")
				println(o,"\\draw [dolpcolor] ($x1 cm,$y1 cm) -- ($x2 cm, $y2 cm);")
			else
				#println(o,"\\draw [$color,draw opacity = $p] ($x cm,$y cm) circle [x radius=$a cm, y radius=$b cm, rotate=$theta];")
				println(o,"\\draw [$color] ($x cm,$y cm) circle [x radius=$a cm, y radius=$b cm, rotate=$theta];")
			end
		end
		println(o,"""\\draw[step = $(2window.cm.x) cm, gray, very thin, draw opacity=0.25] (0,0) grid ($(sz[1].cm.x) cm, $(sz[2].cm.x) cm);
	\\end{tikzpicture}""")
	end
end
function stokes2ellipse(s::Array{Stokes,2}; dpi::Int = 96, window_in_cm::Real = 0.15, maxpol::Real = 1, minpol::Real = 0, eccentricity::Real = 0.01, name = "RGB", linearcolor::RGB = RGB(0.0,1.0,0.0))
	SZ = size(s)
	const RATIO = 2.54/dpi
	sz = (Length(Pixel(SZ[1]),RATIO),Length(Pixel(SZ[2]),RATIO))
	window = Length(Centimeter(findwindow(window_in_cm,RATIO)),RATIO)
	grid(s,sz,window,maxpol,RATIO, minpol, eccentricity,name,linearcolor)
end

end
