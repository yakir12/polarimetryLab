ispid(pid::String) = !isempty(readall(pipeline(`ps aux`, `awk '{print $2 }'`)) |> txt -> search(txt, pid))
function cleanpid(file::String)
	name, ext = splitext(file)
	if ext == ".pid"
		if ispid(name)
			run(`kill $name`)
		end
		rm(file)
	end
end
closeall(_) = map(cleanpid,readdir())
function startit(_)
	closeall(_)
	@async run(`x-terminal-emulator -e 'julia --startup-file=no Spectropolarimetry.jl'`) 
end

it = Input(3)
nr = Input(1)
refresh = Input{Any}(leftbutton)
l315c0 = Input{Any}(leftbutton)
l0c0 = Input{Any}(leftbutton)
l45c0 = Input{Any}(leftbutton)
l90c0 = Input{Any}(leftbutton)
l0c315 = Input{Any}(leftbutton)
l0c45 = Input{Any}(leftbutton)
dark = Input{Any}(leftbutton)
quit = Input{Any}(leftbutton)

lift(startit, refresh)

consume(it, typ=Any, init=empty) do i
	open("integrationtime","w") do o
		print(o,1000i)
	end
end
consume(nr, typ=Any, init=empty) do i
	open("nreplicates","w") do o
		print(o,i)
	end
end

consume(l315c0, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l315c0")
	end
end
consume(l0c0, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l0c0")
	end
end
consume(l45c0, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l45c0")
	end
end
consume(l90c0, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l90c0")
	end
end
consume(l0c315, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l0c315")
	end
end
consume(l0c45, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"l0c45")
	end
end
consume(dark, typ=Any, init=empty) do i
	open("rotation","w") do o
		print(o,"dark")
	end
end
lift(closeall, quit, typ=Any, init=empty)


function main(window)
	push!(window.assets, "widgets")

	vbox(
	hbox("Number of scans to average", slider(1:100, value=1) >>> nr),
	hbox("Integration time (milli seconds)", flex(slider(3:60_000, value=3) >>> it)),
	hbox(button("l315c0") >>> l315c0 |> fillcolor("#eeb"), button("l0c0") >>> l0c0 |> fillcolor("#eeb"), button("l45c0") >>> l45c0 |> fillcolor("#eeb"), button("l90c0") >>> l90c0 |> fillcolor("#eeb"), button("l0c315") >>> l0c315 |> fillcolor("#859"), button("l0c45") >>> l0c45 |> fillcolor("#859"), button("dark") >>> dark |> fillcolor("#875"), button("Quit") >>> quit |> fillcolor("#f75"),button("Refresh") >>> refresh |> fillcolor("#f75"))
	)
end
