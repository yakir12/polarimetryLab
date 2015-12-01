outliar = RGB(0.941176, 0.901961, 0.54902)

writeRGB(opt::Cmd,name::AbstractString) = run(`convert originalRGB.jpg $opt $assets/$name.jpg`)

function updateRGB(opts...)
	_, opt = build_opt(value(SZ),opts...)
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
	cp(joinpath(assets,files[1]),"RGB.jpg",remove_destination=true)
end

function recolor_I(img,t)
	N = length(img.cmap)
	n = round(Int,N*t/100)
	cmap = [linspace(RGB(0,0,0),RGB(1,1,1),n);fill(RGB(1,1,1),N - n)]
	img.cmap = cmap
	return convert(Image, img)
end

function recolor_dolp(img,t)
	N = length(img.cmap)
	n = round(Int,N*t/100)
	cmap = [linspace(RGB(0,0,0),RGB(1,1,1),n);fill(outliar,N - n)]
	img.cmap = cmap
	return convert(Image, img)
end

function recolor_docp(img,b,t)
	N2 = round(Int,length(img.cmap)/2)
	nb = round(Int,N2*b/100)
	nt = round(Int,N2*t/100)
	cmap = [fill(outliar,N2 - nb); linspace(RGB(1,0,0),RGB(0,0,0),nb); linspace(RGB(0,0,0),RGB(0,1,0),nt); fill(outliar,N2 - nt)]
	img.cmap = cmap
	return convert(Image, img)
end

write_originalRGB(fname::AbstractString) = run(pipeline(`dcraw -w -H 0 -o 0 -h -c $fname`,`convert - -auto-level originalRGB.jpg`))

function calculatepolar(s)
	mats = stokes2mats(s)
	imgs = mats2images(mats...)
end

function recolor_profile(img,b,t)
	N = length(img.cmap)
	nb = round(Int,N*b/100)
	nt = round(Int,N*t/100)
	cmap = [fill(outliar,nb); linspace(RGB(0,0,0),RGB(1,1,1),nt - nb); fill(outliar,N - nt)]
	img.cmap = cmap
	return img
end

function latexellipse(s,window,maxpol,minpol,eccentricity)
	copyassets()
	stokes2ellipse(s,window_in_cm = window, maxpol = maxpol, minpol = minpol, eccentricity = eccentricity)
	open("ellipse.tex","w") do o
		println(o,"""\\documentclass{standalone}
		\\usepackage{tikz}
		\\usetikzlibrary{arrows.meta,positioning,calc}
		\\usepackage{pgfplots}
		\\pgfplotsset{compat=1.12}
		\\definecolor{dolpcolor}{rgb}{0,1,0}
		\\definecolor{dolcpcolor}{rgb}{1,0,0}
		\\definecolor{dorcpcolor}{rgb}{0,0,1}
		\\begin{document}
				\\input{ellipse.tikz}
		\\end{document}""")
	end
	run(`pdflatex ellipse.tex`)
	name = string(abs(rand(Int)))
	name = "assets/$name.png"
	run(`convert -density 96 -quality 100 ellipse.pdf $name`)
	#run(`convert -density 96 -quality 100 ellipse.pdf -size $(value(SZ)[1])x $name`)
	return name
end
