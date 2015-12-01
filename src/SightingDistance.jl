module SightingDistance

export polSightingDistance, unpolSightingDistance, profile1, profile, fv

using Light, Roots, NLopt

const brct = Float64[0,1000] # bracket for limits of the sighting distances (m)

function polUnmaxSightingDistance(f::Stokes,b::Stokes, disc, c, Sp) # find the sighting distance for a fish against a background. f and b are Polar types
# disc: discrimination threshold, Cmin 
# c:    beam attenuation coefficient of the water
# Sp:   sensitivity
	
	ψ = (Sp - 1.)/(Sp + 1.)
	Pb = profile(b,ψ) # the activity profile of the interneuron
	
	r = 0. # set initial sighting distance: set sighting distance to zero if it's smaller than zero or larger than say 100 m
	if toZero(0.,f,b,Pb,disc,c,ψ) > 0 # if the result of this function is negative then there is no positive sighitng distance
		r = fzero(r -> toZero(r,f,b,Pb,disc,c,ψ),brct) # find the sighting distance
	end

	return r
end

function toZero(r,f,b,Pb,disc,c,ψ) # gives the difference between the two sides of equation 6 for a given sighting distance
    v = fv(r,f,b,c) # adjust the polarization state of the fish signal to this new sighting distance
    Pv = profile(v,ψ) # get the corresponding activity profile
    abs(Pv - Pb) - disc # return the difference between the discrimination threshold and the normalized absolute difference between the activity profile for the fish and the background
end

profile1(a::Stokes,ψ) = (a.s0 + ψ*a.s1)/(a.s0 - ψ*a.s1)
profile(a::Stokes,ψ) =  log((a.s0 + ψ*a.s1)/(a.s0 - ψ*a.s1)) # the activity profile of the polarization interneuron for Φmax = 0 or 90 degrees (from How and Marshall, 2013)

fv(r::Float64,f::Stokes,b::Stokes,c) = f*exp(-c*r) + b*(1. - exp(-c*r)) # modulate the stokes parameters for a signal that travels through r meters water with a specific background

unpolSightingDistance(f::Stokes,b::Stokes; disc = .02, c = .1) = begin # sighting distance of a fish against a background, taking into consideration intensity alone
	r = log(abs(f.s0 - b.s0)/b.s0/disc)/c
	r < 0 ? 0. : r # set sighting distance to zero if it's smaller than zero
end

unpolSightingDistance(f::Polar,b::Polar; disc = .02,  c = .1) = unpolSightingDistance(Stokes(f),Stokes(b),disc = disc,c = c)

function polMaxSightingDistance(f::Stokes,b::Stokes, disc, c, Sp) # find the sighting distance for a fish against a background. f and b are Polar types
# disc: discrimination threshold, Cmin 
# c:    beam attenuation coefficient of the water
# Sp:   sensitivity
	function myfun(phi,grad)
		f2 = rotate(f,phi[1])
		b2 = rotate(b,phi[1])
		polUnmaxSightingDistance(f2,b2, disc, c, Sp)
	end
	opt = Opt(:LN_COBYLA, 1)
	lower_bounds!(opt, [-pi/4])
	upper_bounds!(opt, [pi/4])
	max_objective!(opt,myfun)
	(maxy,maxx,ret) = optimize(opt, [0.])
	return maxy
end

polSightingDistance(f::Stokes,b::Stokes;  disc = .1, c = .1, Sp = 5., max = false) = max ? polMaxSightingDistance(f,b,disc,c,Sp) : polUnmaxSightingDistance(f,b,disc,c,Sp)

polSightingDistance(f::Polar,b::Polar; disc = .1, c = .1, Sp = 5., max = false) = polSightingDistance(Stokes(f),Stokes(b),disc = disc, c = c,Sp = Sp,max = max)

end





