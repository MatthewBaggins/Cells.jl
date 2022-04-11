module State

using ..Abstract
using ..Utils

include("./State1D.jl")
using .State1D
include("./State2D.jl")
using .State2D
export State1DWolfram, State2DSquare, Life
export wr2map, vec2wr, iter_state, iter_states, o_display, expand_state, pad_matrix

include("Patterns2D.jl")
using .Patterns2D
export Pattern2D, AllPatterns2D, insert_pattern, insert_patterns

end