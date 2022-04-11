module State

using ..Abstract
using ..Utils

include("./State1D.jl")
using .State1D

include("./State2D.jl")
using .State2D

include("Patterns2D.jl")
using .Patterns2D

end