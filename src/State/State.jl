module State

using ..Abstract
using ..Utils

include("./State1D.jl")
using .State1D
import .State1D: iter_state, iter_states
include("./State2D.jl")
using .State2D
import .State2D: iter_state, iter_states
export State1DWolfram, State2DSquare, Life
export iter_state, iter_states, o_getindex, o_display, o_inds, expand_state, pad_matrix

include("Patterns2D.jl")
using .Patterns2D
export Pattern2D, AllPatterns2D, insert_pattern, insert_patterns

end