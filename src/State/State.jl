module State


using ..Abstract
using ..Utils

include("./Expand.jl")
using .Expand
import .Expand: expand_vector, expand_matrix, pad_matrix

include("./Iter.jl")
import .Iter: iter_state, iter_states
export iter_state, iter_states

include("./StateECAs.jl")
import .StateECAs: StateECA
export StateECA

include("./StateSquares.jl")
import .StateSquares: Life, StateSquare, o_inds, o_display
export Life, StateSquare, o_inds, o_display

include("PatternSquares.jl")
import .PatternSquares: PatternSquare, PatternsSquareMap, insert_pattern, insert_patterns
export PatternSquares, PatternSquare, PatternsSquareMap, insert_pattern, insert_patterns

end