function check4errors(path::AbstractString)
	files = readdir(path)
	for i in ["dark.txt", "l0c0.txt", "l0c315.txt", "l0c45.txt", "l315c0.txt", "l45c0.txt", "l90c0.txt"]
		if ~(i in files)
			p = @spawn run(`zenity --error --text="Error! Could not find file $i\nPress OK to terminate."`)
			wait(p)
			exit()
		end
	end
end
function getdata(path::AbstractString)
	x = readdlm(joinpath(path,"dark.txt"), '\t', Float64, skipstart=16,comment_char='>')
	wl = x[:,1]
	nwl = length(wl)
	dark = x[:,2]
	return (nwl,dark,wl)
end
function calcstokes(dark::Float64, l315c0::Float64, l0c0::Float64, l45c0::Float64, l90c0::Float64, l0c315::Float64, l0c45::Float64)
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
function gety(s::IO)
	l = readline(s)
	_, yt = split(l,'\t')
	y = parse(Float64,strip(yt))
	return y
end
function spect2csv(path::AbstractString)
	check4errors(path)
	nwl,dark,wl = getdata(path)
	l315c0 = open(joinpath(path,"l315c0.txt"),"r")
	l0c0 = open(joinpath(path,"l0c0.txt"),"r")
	l45c0 = open(joinpath(path,"l45c0.txt"),"r")
	l90c0 = open(joinpath(path,"l90c0.txt"),"r")
	l0c315 = open(joinpath(path,"l0c315.txt"),"r")
	l0c45 = open(joinpath(path,"l0c45.txt"),"r")
	for i in [l315c0, l0c0, l45c0, l90c0, l0c315, l0c45], j = 1:17
		readline(i)
	end
	polar = open(joinpath(path,"polar.csv"),"w")
	println(polar, "wl\tI\tdolp\taop\tdocp")
	for i = 1:nwl
		lambda  = wl[i]
		ydark   = dark[i]
		yl315c0 = gety(l315c0)
		yl0c0   = gety(l0c0)
		yl45c0  = gety(l45c0)
		yl90c0  = gety(l90c0)
		yl0c315 = gety(l0c315)
		yl0c45  = gety(l0c45)
		s0, s1, s2, s3 = calcstokes(ydark, yl315c0, yl0c0, yl45c0, yl90c0, yl0c315, yl0c45)
		s0 < 1 && continue
		I, dolp, aop, docp = calcpolar(s0,s1,s2,s3)
		println(polar, lambda, '\t', I, '\t', dolp, '\t', aop, '\t', docp)
	end
	map(close,[l315c0, l0c0, l45c0, l90c0, l0c315, l0c45, polar])
end
