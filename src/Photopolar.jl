module Photopolar

#export path2pol
using Light, Images
@everywhere function imread(fname::AbstractString,sz::Tuple{Int,Int})
	stream, _ = open(`dcraw -w -H 0 -o 0 -h -4 -c $fname`) 
	x = read(stream, UInt16, 3, sz...)
	#return x[1,:,:]
	y = zeros(UInt16, 1, sz...)
	for i in eachindex(y), j = 1:3
		y[i] += round(UInt16, x[j,i]/3)
	end
	return y
end
function loaddata{T <: AbstractString}(fnames::Vector{T},sz::Tuple{Int,Int})
	data = SharedArray(UInt16,6,sz...)
	@sync @parallel for i = 1:6
		data[i,:,:] = imread(fnames[i],sz)
	end
	return data
end
function getfnames(path::AbstractString)
	files = readdir(path)
	filter!(r".*\.NEF",files)
	return map(x -> joinpath(path,x), files)
end
getsz(fname::AbstractString) = (map(x -> round(Int,parse(Int,x)/2),split(split(readall(`dcraw -i -v $fname`),'\n')[14])[[3,5]])...)
getRGB(fname::AbstractString) = @spawn run(pipeline(`dcraw -w -H 0 -o 0 -h -c $fname`,`convert - -auto-level RGB0.jpg`))
function convert2polar(data::SharedArray{UInt16,3},sz::Tuple{Int,Int})
	I = zeros(sz)
	dolp = zeros(sz)
	aop = zeros(sz)
	dolcp = zeros(sz)
	dorcp = zeros(sz)
	m = zeros(6)
	for i = 1:prod(sz)
		for j = 1:6
			m[j] = (data[j,i] + 1.)/(typemax(UInt16) + 1.)
		end
		p = Polar(m...)
		I[i] = p.I > 1 ? 1.0 : isnan(p.I) ? 0.0 : p.I
		dolp[i] = p.dolp > 1 ? 1.0 : isnan(p.dolp) ? 0.0 : p.dolp
		aop[i] = isnan(p.aop) ? 0.0 : (p.aop + pi/2)/pi
		if p.docp < 0
			dolcp[i] = p.docp < -1 ? 1.0 : -p.docp
			dorcp[i] = 0.0
		elseif p.docp >= 0
			dolcp[i] = 0.0
			dorcp[i] = p.docp > 1 ? 1.0 : p.docp
		else
			dolcp[i] = 0.0
			dorcp[i] = 0.0
		end
	end
	img = grayim(I)
	@async imwrite(img,"I0.jpg")
	img = restrict(restrict(img))
	@async imwrite(img,"I.jpg")
	img = grayim(dolp)
	@async imwrite(img,"dolp0.jpg")
	img = restrict(restrict(img))
	@async imwrite(img,"dolp.jpg")
	img = grayim(aop)
	@async imwrite(img,"aop0.jpg")
	img = grayim(dolcp)
	@async imwrite(img,"dolcp0.jpg")
	img = restrict(restrict(img))
	@async imwrite(img,"dolcp.jpg")
	img = grayim(dorcp)
	@async imwrite(img,"dorcp0.jpg")
	img = restrict(restrict(img))
	@async imwrite(img,"dorcp.jpg")

end
function path2pol(path::AbstractString)
	fnames = getfnames(path)
	@async getRGB(fnames[1])
	sz = getsz(fnames[1])
	data = loaddata(fnames,sz)
	convert2polar(data,sz)
end
	
end
