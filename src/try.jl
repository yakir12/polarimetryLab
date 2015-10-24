using Winston

b = Input(1)

a = lift(t -> plot(rand(10)), b)

main(window) = begin
    push!(window.assets, "widgets")
    vbox(md"## Static Plot", a)
    for i = 1:100
	    sleep(1/30)
	    push!(b,i)
    end
end
