home = joinpath(homedir(),"polar/")
push!(LOAD_PATH, home)
using Light, Spectra
path = "CP"
a = collectspect(Float64,path)
polarspectra(a,"data.csv")
run(`pdflatex plot.tex`)
run(`convert -density 300 plot.pdf -resize 1280x800! plot.png`)
#run(`xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/image-path --set $home/plot.png`)

