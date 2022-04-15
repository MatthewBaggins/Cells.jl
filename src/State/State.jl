module State

using ..Abstract
using ..Utils

include("./StateECAs.jl")
using .StateECAs
import .StateECAs: iter_state, iter_states
include("./StateSquares.jl")
using .StateSquares
import .StateSquares: iter_state, iter_states
export StateECA, StateSquare, Life
export iter_state, iter_states, o_getindex, o_display, o_inds, expand_state, pad_matrix

include("PatternsSquares.jl")
using .PatternsSquares
export PatternsSquare, PatternsSquareMap, insert_pattern, insert_patterns

end