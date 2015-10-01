module Spectropolar

using PyCall, ASCIIPlots

export spectropolar

@pyimport oceanoptics

const TAKES = [:l315c0, :l0c0, :l45c0, :l90c0, :l0c315, :l0c45, :dark]

function getit(wl::Vector{Float64},S::PyCall.PyObject)
	maxy = Float64(2^12 - 1)
	x = [wl[1:2];wl]
	minit = S[:_min_integration_time]
	S[:integration_time](minit)
	itxt = string(minit)
	while ~isalpha(itxt)
		it = parse(Float64,itxt)
		if it < minit
			it = minit
			println("Integration time cannot be smaller than $minit !!!")
		end
		S[:integration_time](it)
		sleep(.1)
		y = [0.0;maxy;S[:intensities]()]
		display(scatterplot(x,y,sym = '.'))
		println("Input the integration time in seconds (input some letter when done):")
		itxt = strip(readline())
		if isempty(itxt) 
			itxt = string(it)
		end
	end
	println("How many spectra do you want to average?")
	mutxt = strip(readline())
	mu = parse(Int,mutxt)
	return mu
end

function getdata(wl::Vector{Float64},nwl::Int,S::PyCall.PyObject,mu::Int)
	x = [[x::Symbol => 0.0 for x in TAKES]::Dict{Symbol,Float64} for i = 1:nwl]
	for i in TAKES
		println("Set apparatus to $i and press enter when ready...")
		readline()
		for l = 1:mu
			y = S[:intensities]()
			display(scatterplot(wl,y,sym = '.'))
			for j in 1:nwl
				x[j][i] += y[j]/mu
			end
		end
	end
	return x
end

function calcstokes(;dark = dark::Float64, l315c0 = l315c0::Float64, l0c0 = l0c0::Float64, l45c0 = l45c0::Float64, l90c0 = l90c0::Float64, l0c315 = l0c315::Float64, l0c45 = l0c45::Float64)
	s0 = (l315c0 + l0c0 + l45c0 + l90c0 + l0c315 + l0c45 - 6dark)/3
	s1 = l0c0 - l90c0
	s2 = l315c0 - l45c0
	s3 = l0c315 - l0c45
	return (s0,s1,s2,s3)
end

function calcpolar(s0::Float64,s1::Float64,s2::Float64,s3::Float64)
	I = s0
	dolp = sqrt(s1*s1 + s2*s2)/s0
	aop = rad2deg(0.5*atan2(s2,s1))
	docp = s3/s0
	return (I,dolp,aop,docp)
end

function spectropolar()

	S = oceanoptics.get_a_random_spectrometer()
	run(`clear`)
	wl = S[:wavelengths]()
	mu = getit(wl,S)
	nwl = length(wl)
	x = getdata(wl,nwl,S,mu)
	name = joinpath(homedir(),string(now()))
	open("$name.csv","w") do o
		println(o,"wl\t",join(TAKES,'\t'), "s0\ts1\ts2\ts3\tI\tdolp\taop\tdocp")
		for i = 1:nwl
			s0, s1, s2, s3 = calcstokes(;x[i]...)
			s0 < 1 && continue
			I, dolp, aop, docp = calcpolar(s0,s1,s2,s3)
			println(o,wl[i],'\t',join([string(x[i][j]) for j in TAKES],'\t'), s0, '\t', s1, '\t', s2, '\t', s3, '\t', I, '\t', dolp, '\t', aop, '\t', docp)
		end
	end
	readall(`pdflatex -interaction=nonstopmode --shell-escape -output-directory=$(tempdir()) "\def\NAME{$name} \input{plot.tex}"`)
	mv(joinpath(tempdir(),"plot.pdf"),"$name.pdf",remove_destination=true)
	run(`clear`)
	println("Done, the results are in $name.csv and $name.pdf.")
	print("Closing in 5...")
	for i = 1:5
		sleep(1)
		print(5 - i,"...")
	end
end

end
