module Cells

include("Abstract.jl")
using .Abstract

include("Utils/Utils.jl")
using .Utils
export  ←, displayln, min_and_max, +, shift_range, window, window_padded, mosaic2, mosaic4,
        expand_vector, expand_vector_report

include("State/State.jl")
using .State
export StateECA, StateSquare, Life
export wr2map, vec2wr, iter_state, iter_states, o_display, expand_state
export PatternsSquare, PatternsSqareMap, insert_pattern, insert_patterns


end 