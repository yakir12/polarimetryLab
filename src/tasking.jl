using Winston
function fun()
	sleep(.1)
	rand(100)
end
function a()
	while true
		produce(fun())
	end
end
b = Task(a)
function c()
	while true
		p = plot(consume(b))
		display(p)
	end
end
@spawn c()

println("kaka")

sleep(2)

println("kaka2")
