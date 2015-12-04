module Light

export Polar, Stokes, PolEllipse, rotate, mean, convert, measurements2stokes, stokes2polar
import Base: mean, convert, +, *, /

immutable Stokes{T <: AbstractFloat}
	s0::T
	s1::T
	s2::T
	s3::T
	function Stokes(s0,s1,s2,s3)
		if (s0 < 0) || (s1*s1 + s2*s2 + s3*s3 > s0*s0) 
			s0 = s1 = s2 = s3 = T(NaN)
		end
		new(s0,s1,s2,s3)
	end
end
Stokes{T <: AbstractFloat}(s0::T,s1::T,s2::T,s3::T) = Stokes{T}(s0,s1,s2,s3)

immutable Polar{T <: AbstractFloat}
	I::T
	dolp::T
	aop::T
	docp::T
	function Polar(I,dolp,aop,docp)
		if (I < 0) || (dolp*dolp + docp*docp > 1)
			I = dolp = aop = docp = T(NaN)
		end
		new(I,dolp,aop,docp)
	end
end
Polar{T <: AbstractFloat}(I::T,dolp::T,aop::T,docp::T) = Polar{T}(I,dolp,aop,docp)
convert(::Type{Array}, a::Polar) = [a.I, a.dolp, a.aop, a.docp]

#stokes2polar(s0,s1,s2,s3) = (s0, sqrt(s1*s1 + s2*s2)/s0, atan2(s2,s1)/2, s3/s0)

immutable PolEllipse{T <: AbstractFloat}
	polarization::T
	a::T
	b::T
	angle::T
	lefthand::Bool
end
#PolEllipse{T <: AbstractFloat}(polarization::T,a::T,angle::T,lefthand::Bool) = PolEllipse{T}(polarization,ellipticity,angle,lefthand)

function PolEllipse(s::Stokes)
	tmp = s.s1*s.s1 + s.s2*s.s2
	s0P = sqrt(tmp + s.s3*s.s3)
	dolp = sqrt(tmp)
	R = (s0P - dolp)/(s0P + dolp)
	aop = atan2(s.s2,s.s1)/2
	h = s.s3 < 0
	P = s0P/s.s0
	a = P*R
	b = P
	return PolEllipse(P,a,b,aop,s.s3 < 0)
end

#=function convert(::Type{PolEllipse}, a::Polar)
	P = sqrt(a.dolp*a.dolp + a.docp*a.docp)
	A = sqrt(.5*(1 + a.dolp))
	B = sqrt(.5*(1 - a.dolp))
	return PolEllipse(P,A/B,a.aop,a.docp < 0)
end

convert(::Type{PolEllipse}, a::Stokes) = PolEllipse(Polar(a))=#


convert(::Type{Stokes}, a::Polar) = Stokes(a.I, a.dolp*cos(2a.aop)*a.I, a.dolp*sin(2a.aop)*a.I, a.docp*a.I)
convert(::Type{Polar}, a::Stokes) = Polar(a.s0, sqrt(a.s1*a.s1 + a.s2*a.s2)/a.s0, atan2(a.s2,a.s1)/2, a.s3/a.s0)

*(a::Stokes,b::Number) = Stokes(a.s0*b, a.s1*b, a.s2*b, a.s3*b)
/(a::Stokes,b::Number) = Stokes(a.s0/b, a.s1/b, a.s2/b, a.s3/b)

+(a::Stokes,b::Stokes) = Stokes(a.s0 + b.s0, a.s1 + b.s1, a.s2 + b.s2, a.s3 + b.s3)

rotate(a::Polar,b::AbstractFloat) = Polar(a.I,a.dolp,a.aop + b,a.docp)
rotate(a::Stokes,b::Real) = Stokes(rotate(Polar(a),b))

function mean(a::Vector{Polar})
	I = mean(map(x -> x.I,a))
	dolp = mean(map(x -> x.dolp,a))
	α = map(x -> x.aop,a)
	aop = atan2(mean(sin(α)),mean(cos(α)))
	docp = mean(map(x -> x.docp,a))
	return Polar(I,dolp,aop,docp)
end

function measurements2stokes(ad, v, d, h, r, l)
	s0 = (v + h + d + ad + r + l)/3
	s1 = v - h
	s2 = d - ad
	s3 = r - l
	return (s0,s1,s2,s3)
end

function measurements2stokes(ad, v, d, h)
	s0 = (v + h + d + ad)/2
	s1 = v - h
	s2 = d - ad
	return (s0,s1,s2,zero(s0))
end

function measurements2stokes(r, l)
	s0 = r + l
	s3 = r - l
	return (s0,zero(s0),zero(s0),s3)
end

stokes2polar(s0, s1, s2, s3) = (s0, sqrt(s1*s1 + s2*s2)/s0, atan2(s2,s1)/2, s3/s0)


end
