module Cells


include("Abstract.jl")
using .Abstract

include("Utils/Utils.jl")
using .Utils
export  ←, displayln, min_and_max, +, shift_range, window, window_padded, mosaic2, mosaic4,
        expand_vector, expand_vector_report
export animate_square

include("State/State.jl")
using .State
import .State: iter_state, iter_states, StateECA, Life, StateSquare, o_display, PatternSquare, PatternsSquareMap, insert_pattern, insert_patterns, PatternSquares
export iter_state, iter_states, StateECA, Life, StateSquare, o_display, PatternSquare, PatternsSquareMap, insert_pattern, insert_patterns, PatternSquares

end 