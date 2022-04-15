module Patterns2D

using ..Utils
using ..State2D: pad_matrix, State2DSquare, o_inds

#= Patterns for 2D automata =#

export PatternSquare, PatternsSquareMap

struct PatternSquare
    grid::Array{Bool, 2}
    name::String
end

#= Rotating functions =#
export rotl90, rotr90, rot180
rotl90(p::PatternSquare) = PatternSquare(rotl90(p.grid), p.name)
rotr90(p::PatternSquare) = PatternSquare(rotr90(p.grid), p.name)
rot180(p::PatternSquare) = PatternSquare(rot180(p.grid), p.name)

# Still
Block = PatternSquare([1 1 ; 1 1], "Block")
BeeHive = PatternSquare([0 1 1 0 ; 1 0 0 1 ; 0 1 1 0], "BeeHive")
Loaf = PatternSquare([0 1 1 0 ; 1 0 0 1 ; 0 1 0 1 ; 0 0 1 0], "Loaf")
Boat = PatternSquare([1 1 0 ; 1 0 1 ; 0 1 0], "Boat")
Tub = PatternSquare([0 1 0 ; 1 0 1 ; 0 1 0], "Tub")

# Oscillators
Blinker = PatternSquare([1 1 1], "Blinker")
Toad = PatternSquare([0 1 1 1 ; 1 1 1 0], "Toad")
Beacon = PatternSquare([1 1 0 0 ; 1 1 0 0 ; 0 0 1 1 ; 0 0 1 1], "Beacon")
Pulsar = PatternSquare(
    mosaic4([0 0 1 1 1 0 ; 0 0 0 0 0 0 ; 1 0 0 0 0 1 ; 1 0 0 0 0 1; 1 0 0 0 0 1 ;0 0 1 1 1 0]), 
    "Pulsar")
PentaDecathlon = PatternSquare(mosaic2([1 1 1 ; 1 0 1 ; 1 1 1 ; 1 1 1], 0, 1), "PentaDecathlon")

# Spaceships
Glider = PatternSquare([0 1 0 ; 0 0 1 ; 1 1 1], "Glider")
LWSS = PatternSquare([1 0 0 1 0 ; 0 0 0 0 1 ; 1 0 0 0 1 ; 0 1 1 1 1], "LWSS")
MWSS = PatternSquare([0 1 1 1 1 1 ; 1 0 0 0 0 1 ; 0 0 0 0 0 1 ; 1 0 0 0 1 0 ; 0 0 1 0 0 0], "MWSS")
HWSS = PatternSquare([0 1 1 1 1 1 1 ; 1 0 0 0 0 0 1 ; 0 0 0 0 0 0 1 ; 1 0 0 0 0 1 0 ; 0 0 1 1 0 0 0], "HWSS")

# All patterns
PatternsSquareMap = Dict(
    :Still => [Block, BeeHive, Loaf, Boat, Tub],
    :Oscillators => [Blinker, Toad, Beacon, Pulsar, PentaDecathlon],
    :Spaceships => [Glider, LWSS, MWSS, HWSS]
    )

#= Pattern insertion tools =#

export insert_pattern, insert_patterns

function insert_pattern(state::State2DSquare, pattern::PatternSquare, insert_pos::Tuple{Int64, Int64})
    target_size, new_origin = determine_target_size(state.grid, pattern.grid, insert_pos, state.origin)
    state_grid = pad_matrix(state.grid, target_size, new_origin)
    pattern_grid = pad_matrix(pattern.grid, target_size, insert_pos + new_origin)
    new_state_grid = map(x -> x!=0 ? 1 : 0, pattern_grid + state_grid)
    return State2DSquare(new_state_grid, state.rule, new_origin)
end

function insert_patterns(state::State2DSquare, patterns::Vector{Tuple{PatternSquare, Tuple{Int64, Int64}}})
    x_min = min(0, [p_pos[1]-1 for (p, p_pos) in patterns]...)
    x_max = max([p_pos[1]+size(p.grid)[1] for (p, p_pos) in patterns]...)
    y_min = min(0, [p_pos[2]-1 for (p, p_pos) in patterns]...)
    y_max = max([p_pos[2]+size(p.grid)[2] for (p, p_pos) in patterns]...)

    s_o_x, s_o_y = state.origin
    o_x = x_min < 2-s_o_x ? s_o_x - x_min + 1 : s_o_x
    o_y = y_min < 2-s_o_y ? s_o_y - y_min + 1 : s_o_y

    new_state_size = (x_max-x_min+1, y_max-y_min+1)
    new_state_grid = pad_matrix(state.grid, new_state_size, (o_x, o_y))

    for (p, (p_x, p_y)) in patterns
        p_x_range = p_x:(p_x + size(p.grid)[1] - 1)
        p_y_range = p_y:(p_y + size(p.grid)[2] - 1 )
        p_x_inds, p_y_inds = o_inds(p_x_range, p_y_range, o_x, o_y)
        new_state_grid[p_x_inds, p_y_inds] .+= p.grid
    end

    return State2DSquare(new_state_grid, state.rule, (o_x, o_y))
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