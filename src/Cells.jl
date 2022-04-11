module Cells

include("Abstract.jl")
using .Abstract

include("./Utils/Utils.jl")
using .Utils
export  ←, displayln, min_and_max, +, shift_range, window, window_padded, mosaic2, mosaic4,
        pad_matrix, expand_vector, expand_vector_report


include("./State/State.jl")
using .State
export  State1DWolfram, wr2map,
        Life, State2DSquare, o_display, 
        expand_state, iter_state, iter_states,
        Pattern2D, AllPatterns2D, insert_pattern, insert_patterns

end 