module Diverse

export movingavg, tempfile, unwrap, sendto

tempfile(x::AbstractString) = joinpath(tempdir(),x)

function movingavg(v::Vector,m::Int)
    n = length(v)
    0 < m < n || error("m = $m must be in the range [1,length(v)] = [1,$(length(v))]")
    res = Array(typeof(v[1]/n), n-m+1)
    s = zero(eltype(res))
    for i in 1:m
        s += v[i]
    end
    res[1] = s
    for j in 1:(length(res)-1)
        s -= v[j]
        s += v[j + m]
        res[j+1] = s
    end
    res/m
end

function unwrap(v, inplace=false)
  # currently assuming an array
  unwrapped = inplace ? v : copy(v)
  for i in 2:length(v)
    while unwrapped[i] - unwrapped[i-1] >= π
      unwrapped[i] -= 2π
    end
    while unwrapped[i] - unwrapped[i-1] <= -π
      unwrapped[i] += 2π
    end
  end
  return unwrapped
end

end


function sendto(p::Int; args...)
    for (nm, val) in args
        @spawnat(p, eval(Main, Expr(:(=), nm, val)))
    end
end


function sendto(ps::Vector{Int}; args...)
    for p in ps
        sendto(p; args...)
    end
end
