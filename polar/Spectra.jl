# a small script to read a tab delimited spectrum file from an OceanOptics spectrometer. Normalizes to the integration time.
module Spectra

using Light, Diverse

export AlignedSpectra, collectspect, polarspectra, read_spectra

immutable UnprossSpectrum{T <: AbstractFloat}
	nwl::Int
	wl::Vector{T}
	I::Vector{T}
	it::Int
	name::ASCIIString
end

immutable AlignedSpectra{T <: AbstractFloat}
	nwl::Int
	n::Int
	wl::Vector{T}
	s::Array{Dict{Symbol,T},1}
end

##############functions###########################
# helper function
readwords(s::IOStream) = split(readline(s))

function skip(s::IOStream,n::Int)
	map(_ -> readline(s),1:n)
	readwords(s)
end

# read spectrum file
function read_spectra(T::DataType,f)
	name = join(split(basename(f),'.')[1:end-1],'.')
	s = open(f,"r")
	if split(readline(s))[1] == "SpectraSuite"
	
		words = skip(s,7)
		it = parse(Int,words[4]) # integration time
	
		words = skip(s,6)
		nwl = parse(Int,words[end]) # number of wavelengths
	
		readline(s)
	
		I = Array(T,nwl)
		wl = Array(T,nwl)
		for i = 1:nwl
			words = readwords(s)
			wl[i] = parse(T,words[1])
			I[i] = parse(T,words[2])
		end
		close(s)
	else
		close(s)
		it = 1
		x = readdlm(f,',',T)
		wl = vec(x[:,1])
		I = vec(x[:,2])
		nwl = length(wl)
	end

	# remove electrical noise
	I .-= mean(I[wl .< 300])

	# set any negative values to zero
	I[I .< 0] = 0.

	return UnprossSpectrum{T}(nwl,wl,I,it,name)
end

function reduceres(x::Vector,y::Vector, x2::LinSpace,nx::Int,w::Int)
	y2 = Array(Float64,nx)
	for i = 1:nx
		j = findfirst(x .> x2[i])
		y2[i] = mean(y[j-w:j+w])
	end
	return y2
end	

const minwl = 400
const maxwl = 700
const nwl2 = 1000
const w = 10
const wl2 = linspace(minwl,maxwl,nwl2)
# collect all the files from a directory and turn them into spectra
function collectspect(T::DataType,d)
	fs = readdir(d)
	filter!(x -> split(x,'.')[end] == "txt",fs)
	map!(x -> joinpath(d,x),fs)
	s = map(x -> read_spectra(T,x),fs)
	
	# checks
	n = length(s)
	n > 0 || error("no spectra in $d")
	tf1 = [s[1].nwl == s[i].nwl for i = 2:n]
	tf2 = [s[1].wl == s[i].wl for i = 2:n]
	if ~reduce(&, [tf1;tf2])
		nwl = s[1].nwl
		wl = s[1].wl
		for i = 2:n
			I = zeros(T,nwl)
			for j = 1:nwl
				I[j] = s[i].I[indmin(abs(wl[j] - s[i].wl))]
			end
			s[i] = UnprossSpectrum{T}(nwl,wl,I,s[i].it,s[i].name)
			#wlrange = s[i].wl[1]:mean(diff(s[i].wl)):s[i].wl[end]
			#I = CoordInterpGrid(wlrange, s[i].I, 0., InterpQuadratic)
			#Ihat = I[wl]
			#s[i] = UnprossSpectrum{T}(nwl,wl,Ihat,s[i].it,s[i].name)
		end
	end
	tf1 = [s[1].nwl == s[i].nwl || error("unequal number of wavelengths") for i = 2:n]
	tf2 = [s[1].wl == s[i].wl || error("misaligned spectra") for i = 2:n]
	nwl = s[1].nwl
	wl = s[1].wl

	# reduce
	s = [UnprossSpectrum{T}(nwl2,wl2,reduceres(wl,s[i].I,wl2,nwl2,w),s[i].it,s[i].name) for i = 1:n]

	measurement = filter(x -> !contains(x.name,"dark"),s)
	dark = filter(x -> contains(x.name,"dark"),s)

	n = length(measurement)
	s = [[symbol(x.name)::Symbol => 0. for x in measurement] for i = 1:nwl2]
	for i = 1:n
		j = findfirst(x -> measurement[i].it == x.it, dark)
		# check
		j != 0 || error("can't find a dark spectrum with the same integration time as $(measurement[i].it)")
		for k = 1:nwl2
			# subtract dark and divide by intergration time
			s[k][symbol(measurement[i].name)] = (measurement[i].I[k] - dark[j].I[k])/measurement[i].it
		end
	end
	AlignedSpectra{T}(nwl2,n,wl2,s)
end	

function polarspectra(a::AlignedSpectra,fname)
	a.n == 6 || error("wrong number of spectra (6 !== $(a.n))")
	T = eltype(a.wl)
	s0 = zeros(T,a.nwl)
	s1 = zeros(T,a.nwl)
	s2 = zeros(T,a.nwl)
	s3 = zeros(T,a.nwl)
	d = zeros(T,a.nwl)
	sd = zeros(T,a.nwl)
	for i in eachindex(s0)
		s0[i], s1[i], s2[i], s3[i] = measurements2stokes(a.s[i][:l315c0], a.s[i][:l0c0], a.s[i][:l45c0], a.s[i][:l90c0], a.s[i][:l0c315], a.s[i][:l0c45])
		d[i] = sqrt(s1[i]*s1[i] + s2[i]*s2[i] + s3[i]*s3[i]) - s0[i]
		sd[i] = sign(d[i])
	end
	for i = 2:a.nwl-1
		if sd[i-1] == sd[i] == sd[i+1] == one(T)
			s0[i] += d[i]
		end
	end

	open(fname,"w") do o
		println(o,"wl\tI\tdolp\taop\tdocp")
		for i = 1:a.nwl
			p = Polar(Stokes(s0[i],s1[i],s2[i],s3[i]))
			println(o,a.wl[i],'\t',p.I,'\t',p.dolp,'\t',rad2deg(unwrap(p.aop)),'\t',p.docp)
		end
	end
end




end
