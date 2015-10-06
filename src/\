using Winston, PyCall
@pyimport oceanoptics
S = oceanoptics.get_a_random_spectrometer()
wl = S[:wavelengths]()
maxy = Float64(2^12 - 1)
minit = S[:_min_integration_time]
function _plotit()
	y = S[:intensities]()
	p = plot(wl,y)
	ylim(0.0,maxy)
	display(p)
end
function plotit()
	while true
		@async _plotit()
		sleep(1/30)
	end
end
function changeit(x)
	S[:integration_time](x)
	sleep(x)
end

@schedule @spawn plotit()

@spawn @schedule changeit(0.01)


consume(

function _changeit(x,itchanged)
	S[:integration_time](x)
	sleep(x)
end
itchanged = Condition()
function a()
	while true
		wait(itchanged)
		y = S[:intensities]()
		produce(y)
	end
end
b = Task(a)
function c()
	for y in b
		@async begin 
			p = plot(wl,y)
			ylim(0.0,maxy)
			display(p)
		end
		sleep(1/30)
	end
end
function changeit(it)
	d = Task(() -> _changeit(it))
	yieldto(d)
end
_changeit(minit)

@spawn c()



using Winston, PyCall
@pyimport oceanoptics
S = oceanoptics.get_a_random_spectrometer()
wl = S[:wavelengths]()
maxy = Float64(2^12 - 1)
minit = S[:_min_integration_time]
global it = [minit]
S[:integration_time](it[1])
function c()
	while true
		sleep(.1)
		S[:integration_time](it[1])
		sleep(it[1])
		y = S[:intensities]()
		p = plot(wl,y)
		ylim(0.0,maxy)
		display(p)
	end
end

@spawn c()




_f() = println(rand())
f() = produce(_f())
a = Task(f)
schedule(a)



using Winston, PyCall, Reactive
@pyimport oceanoptics
S = oceanoptics.get_a_random_spectrometer()
wl = S[:wavelengths]()
maxy = Float64(2^12 - 1)
minit = S[:_min_integration_time]
nwl = length(wl)

sensor_input = lift((delta) -> plot(S[:intensities]()), fps(1.0))
