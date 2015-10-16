push!(LOAD_PATH, pwd())
if nprocs() < 6
	addprocs(6)
end
using Light, Images, Colors
assets = "assets"
N = 300
function getfnames(path::AbstractString)
	files = readdir(path)
	filter!(r".*\.NEF",files)
	return map(x -> joinpath(path,x), files)
end
write_originalRGB(fname::AbstractString) = run(pipeline(`dcraw -w -H 0 -o 0 -h -c $fname`,`convert - -auto-level originalRGB.jpg`))
getsz(fname::AbstractString) = map(x -> parse(Int,x),split(readall(`identify -ping -format '%w %h' $fname`)))
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
	return `-scale $scale% $toflip $toflop -rotate $rotate +repage -crop $(w)x$h+$x+$y`
end
writeRGB(opt::Cmd,name::AbstractString) = run(`convert originalRGB.jpg $opt $assets/$name.jpg`)
@everywhere function myimread(fname::AbstractString,sz::Vector{Int},opt::Cmd)
	stream, _ = open(pipeline(`dcraw -w -H 0 -o 0 -h -4 -c $fname`,`convert - $opt -colorspace Gray  Gray:-`)) 
	read(stream, UInt16, 1, sz...)
end
function loaddata{T <: AbstractString}(fnames::Vector{T},sz::Vector{Int},opt::Cmd)
	x = SharedArray(UInt16,6,sz...)
	@parallel for i = 1:6
		x[i,:,:] = myimread(fnames[i],sz,opt)
	end
	return x
end
function get_data{T <: AbstractString}(opts,fnames::Vector{T})
	@sync SZ = getsz("originalRGB.jpg")
	opt = build_opt(SZ,opts...)
	writeRGB(opt,"RGB")
	sz = getsz("$assets/RGB.jpg")
	loaddata(fnames,sz,opt)
end
roundit(x::Float64) = round(Int, x*(N - 1) + 1)
function normalize(p::Polar)
	if isnan(p.I)
		return (1,1,1,1)
	else
		I = p.I > 1 ? N : roundit(p.I)
		dolp = p.dolp > 1 ? N : roundit(p.dolp)
		aop = roundit(p.aop/pi + 0.5)
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
function convert2polar(x::SharedArray{UInt16,3})
	sz = size(x,2,3)
	I = zeros(Int,sz)
	dolp = zeros(Int,sz)
	aop = zeros(Int,sz)
	docp = zeros(Int,sz)
	m = zeros(6)
	for i = 1:prod(sz)
		for j = 1:6
			m[j] = (x[j,i] + 1.)/(typemax(UInt16) + 1.)
		end
		p = Polar(m[1], m[2], m[3], m[4], m[5], m[6])
		I[i], dolp[i], aop[i], docp[i] = normalize(p)
	end
	prop = Dict(:spatialorder => ["x","y"], :colorspace => "RGB", :pixelspacing => [1,1])
	colorbar = repeat(reshape(collect(round(Int,linspace(N,1,sz[2]))),1,sz[2]),outer = [round(Int,0.1sz[1]),1])
	row,col,ind = colorwheel(round(Int,0.1*mean(sz)))
	buff = round(Int,0.025*mean(sz))
	for (r,c,i) in zip(row,col,ind)
		aop[sz[1] - r - buff, c + buff] = i
	end
	Iimg = ImageCmap(I, linspace(RGB(0,0,0),RGB(1,1,1),N); prop...)
	dolpimg = ImageCmap(cat(1,dolp,colorbar),linspace(RGB(0,0,0),RGB(1,1,1),N); prop...)
	aopimg = ImageCmap(aop,convert(Array{RGB{FixedPointNumbers.UfixedBase{UInt8,8}},1}, linspace(HSV(0,1,1), HSV(360,1,1),N)); prop...)
	docpimg = ImageCmap(cat(1,docp,colorbar), [linspace(RGB(1,0,0),RGB(0,0,0),Int(N/2)); linspace(RGB(0,0,0), RGB(0,1,0),Int(N/2))]; prop...)
	return (Iimg, dolpimg, aopimg, docpimg)
end


