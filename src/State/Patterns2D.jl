module Patterns2D

using ..Utils
using ..State2D

#= Patterns for 2D automata =#

export Pattern2D, AllPatterns2D

struct Pattern2D
    grid::Array{Bool, 2}
    name::String
end

# Still
Block = Pattern2D([1 1 ; 1 1], "Block")
BeeHive = Pattern2D([0 1 1 0 ; 1 0 0 1 ; 0 1 1 0], "BeeHive")
Loaf = Pattern2D([0 1 1 0 ; 1 0 0 1 ; 0 1 0 1 ; 0 0 1 0], "Loaf")
Boat = Pattern2D([1 1 0 ; 1 0 1 ; 0 1 0], "Boat")
Tub = Pattern2D([0 1 0 ; 1 0 1 ; 0 1 0], "Tub")

# Oscillators
Blinker = Pattern2D([1 1 1], "Blinker")
Toad = Pattern2D([0 1 1 1 ; 1 1 1 0], "Toad")
Beacon = Pattern2D([1 1 0 0 ; 1 1 0 0 ; 0 0 1 1 ; 0 0 1 1], "Beacon")
Pulsar = Pattern2D(
    mosaic4([0 0 1 1 1 0 ; 0 0 0 0 0 0 ; 1 0 0 0 0 1 ; 1 0 0 0 0 1; 1 0 0 0 0 1 ;0 0 1 1 1 0]), 
    "Pulsar")
PentaDecathlon = Pattern2D(mosaic2([1 1 1 ; 1 0 1 ; 1 1 1 ; 1 1 1], 0, 1), "PentaDecathlon")

# Spaceships
Glider = Pattern2D([0 1 0 ; 0 0 1 ; 1 1 1], "Glider")
LWSS = Pattern2D([1 0 0 1 0 ; 0 0 0 0 1 ; 1 0 0 0 1 ; 0 1 1 1 1], "LWSS")
MWSS = Pattern2D([0 1 1 1 1 1 ; 1 0 0 0 0 1 ; 0 0 0 0 0 1 ; 1 0 0 0 1 0 ; 0 0 1 0 0 0], "MWSS")
HWSS = Pattern2D([0 1 1 1 1 1 1 ; 1 0 0 0 0 0 1 ; 0 0 0 0 0 0 1 ; 1 0 0 0 0 1 0 ; 0 0 1 1 0 0 0], "HWSS")

# All patterns
AllPatterns2D = Dict(
    :Still => [Block, BeeHive, Loaf, Boat, Tub],
    :Oscillators => [Blinker, Toad, Beacon, Pulsar, PentaDecathlon],
    :Spaceships => [Glider, LWSS, MWSS, HWSS]
    )

#= Pattern insertion tools =#

export insert_pattern, insert_patterns

function insert_pattern(state::State2DSquare, pattern::Pattern2D, insert_pos::Tuple{Int64, Int64})
    target_size, new_origin = determine_target_size(state.grid, pattern.grid, insert_pos, state.origin)
    state_grid = pad_matrix(state.grid, target_size, new_origin)
    pattern_grid = pad_matrix(pattern.grid, target_size, insert_pos + new_origin)
    new_state_grid = map(x -> x!=0 ? 1 : 0, pattern_grid + state_grid)
    return State2DSquare(new_state_grid, state.rule, new_origin)
end

function insert_patterns(state::State2DSquare, patterns::Vector{Tuple{Pattern2D, Tuple{Int64, Int64}}})
    x_min = min([p_pos[1]-1 for (p, p_pos) in patterns]...)
    x_max = max([p_pos[1]+size(p.grid)[1] for (p, p_pos) in patterns]...)
    y_min = min([p_pos[2]-1 for (p, p_pos) in patterns]...)
    y_max = max([p_pos[2]+size(p.grid)[2] for (p, p_pos) in patterns]...)
    
    new_state_size = (x_max-x_min+1, y_max-y_min+1)
    new_state_origin = state.origin + (-x_min+1, -y_min+1)
    new_state_grid = pad_matrix(state.grid, new_state_size, new_state_origin)
    for (p, p_pos) in patterns
        p_grid = pad_matrix(p.grid, new_state_size, p_pos + new_state_origin)
        new_state_grid += p_grid
    end

    return State2DSquare(new_state_grid, state.rule, new_state_origin)

    # # new_state = State2DSquare(pad_matrix(state.grid, new_state_size, new_state_origin), state.rule, new_state_origin)
    # println("$x_min, $x_max, $y_min, $y_max")
    # println("$new_state_size, $new_state_origin")

    # for (pattern, insert_pos) in patterns
    #     new_state = insert_pattern(new_state, pattern, insert_pos)
    # end
    # return new_state
end

# insert_pattern(s) helper function - returns (target_size, new_origin) tuple
function determine_target_size(m0::Matrix, m1::Matrix, m1pos::Tuple{Int64, Int64}, m0o::Tuple{Int64, Int64}=(1,1))::Tuple{Tuple{Int64, Int64}, Tuple{Int64, Int64}}
    m0x0, m0x1 = (m0o[1], size(m0)[1])
    m0y0, m0y1 = (m0o[2], size(m0)[2])
    
    m1x0, m1x1 = (m1pos[1], m1pos[1] + size(m1)[1])
    m1y0, m1y1 = (m1pos[2], m1pos[2] + size(m1)[2])

    trg_x0 = min(m0x0, m1x0)
    trg_x1 = max(m0x1, m1x1)
    trg_y0 = min(m0y0, m1y0)
    trg_y1 = max(m0y1, m1y1)
    target_size = (trg_x1 - trg_x0 + 1, trg_y1 - trg_y0 + 1)

    o_x = m0x0 - trg_x0 + 1
    o_y = m0y0 - trg_y0 + 1
    new_origin = (o_x, o_y)

    return (target_size, new_origin)
end

end