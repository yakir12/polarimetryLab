using Images, ImageView
function ImageView.updatexylabel(xypos, imgc, img2, x, y)
    w = width(imgc.c)
    xu,yu = ImageView.device_to_user(ImageView.getgc(imgc.c), x, y)
    # Image-coordinates
    xi,yi = floor(Integer, 1+xu), floor(Integer, 1+yu)
    if ImageView.isinside(imgc.canvasbb, x, y)
        val = @sprintf "%5.2f" img2[xi,yi]
	mu = @sprintf "%5.2f" mean(img2.imslice)
        str = "$P: $mu $val"
        if length(str)*10>w
            ImageView.set_value(xypos, "$xi, $yi")
        else
            ImageView.set_value(xypos, str)
        end
    else
        ImageView.set_value(xypos, "$xi, $yi")
    end
end
global P = :I
getsz() = map(x -> parse(Int,x),split(readall(`identify -format "%[fx:h] %[fx:w]" RGB.ppm`)))
function wait4gui(a)
	# Create a condition object
	c = Condition()
	# Get the main window (A Tk toplevel object)
	win = toplevel(a)
	# Notify the condition object when the window closes
	bind(win, "<Destroy>", e->notify(c))
	# Wait for the notification before proceeding ... 
	wait(c)
end

x = readcsv("data.csv",Float64)
sz = getsz()
X = reshape(x,sz...,4)
dolcp = X[:,:,4]
dolcp[dolcp .> 0] = 0.0
dolcp *= -1
dorcp = X[:,:,4]
dorcp[dorcp .< 0] = 0.0
p = Dict(:I => X[:,:,1], :dolp => X[:,:,2], :aop => X[:,:,3], :dolcp => dolcp, :dorcp => dorcp)

cmap = map(RGB,linspace(Color.HSV(0,1,1),Color.HSV(330,1,1),256))
data = round(Int,(p[:aop] + pi/2)/pi*255 + 1)
img = ImageCmap(data, cmap)
imwrite(img,"aop.png")

aop = (p[:aop] + pi/2)/pi
imwrite(aop,"aop.png")

for i = [:I,:dolp,:aop,:dolcp,:dorcp]
	P = i
	img = grayim(p[i])
	#img2 = restrict(img)
	a, b = view(img, pixelspacing = [1,1])
	Tk.set_size(ImageView.toplevel(a), 500, 500)
	wait4gui(a)
	println(cs.min,cs.max)
	i != :aop && write_to_png(a,"$i.png")
end



using Colors, Images
n = 10
data = rand(1:n,10,10)
cmap = linspace(RGB(0,0,1),RGB(1,1,0),n)
img = ImageCmap(data, cmap)



a = rand(1000,1000)
a *= 75
a -= 13
view(a)


img = X[:,:,1]
img2 = restrict(restrict(img))
pipeline(
