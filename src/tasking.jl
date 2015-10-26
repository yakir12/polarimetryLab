using Winston, PyCall, Reactive
@pyimport seabreeze
seabreeze.use("pyseabreeze")
@pyimport seabreeze.spectrometers as sb
devices = sb.list_devices()
S = sb.Spectrometer(devices[1])

const MINIT = 300000#S[:minimum_integration_time_micros]
S[:integration_time_micros](MINIT)

const MAXY = 2^12 - 1
const M = 1.1MAXY
const m = MAXY - M
const WL = S[:wavelengths]()
const NWL = length(WL)
c0 = Channel{Array{Float64,1}}(1)
I = Channel{Array{Float64,1}}(1)
global MU = 3
global IT = copy(MINIT)
it = Channel{Int}(1)
function setit()
	x = take!(it)
	IT = x
	S[:integration_time_micros](x)
end
put!(it,MINIT)
function fetchI()
	while true
		sleep(0)
		isready(it) && setit()
		y = S[:intensities]()
		put!(c0,y)
	end
end
c1 = Channel{Array{Float64,1}}(1)
put!(c1,rand(NWL))
function meanI()
	mu = zeros(NWL)
	for i = 1:MU
		tmp = take!(c0)
		for j = 1:NWL
			mu[j] += tmp[j]/MU
		end
	end
	take!(c1)
	put!(c1,mu)
end
function plotit()
	while true
		meanI()
		y = fetch(c1)
		p = plot(WL,y)
		ylim(m,M)
		display(p)
	end
end
@schedule fetchI()
@schedule plotit()

put!(it,3000000)













using PyCall
@pyimport seabreeze
seabreeze.use("pyseabreeze")
@pyimport seabreeze.spectrometers as sb
devices = sb.list_devices()
S = sb.Spectrometer(devices[1])
S[:integration_time_micros](300000)
c0 = Channel{Array{Float64,1}}(1)
function fetchI()
	while true
		sleep(0)
		y = S[:intensities]()
		put!(c0,y)
	end
end
function plotit()
	while true
		take!(c0)
	end
end
@schedule fetchI()
@schedule plotit()





function mockfunction()
	sleep(rand()*IT*1e-6)
	return rand(2048)
end

y = mockfunction()




