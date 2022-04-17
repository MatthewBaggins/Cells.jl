module StateSquares


using ..Abstract

#= State transition rules 
The rules determine solely how `iter_grid` works
For each rule, a separate `iter_grid` method will be defined
Each subtype of `AbstractState2D` will have its own set of `iter_grid` methods defined, one for each rule
=#
# export Life
struct Life <: AbstractRule end

#= Kinds of 2D states, differing in their geometry =#
# export StateSquare

struct StateSquare <: AbstractState2D
    grid::BitMatrix
    rule::Type{R} where {R <: AbstractRule}
    origin::Tuple{Int64, Int64} # To ensure stable coordinate system
    iterf::Function
    
    # Default constructor with the default rule
    StateSquare() = new(falses(3,3), Life, (1,1),  _iter_grid_square_life)

    # Constructors from a specified grid
    ## Grid only
    StateSquare(grid::AbstractMatrix{T} where {T <: Real}) = StateSquare(grid, Life)
    ## Grid + rule
    StateSquare(grid::AbstractMatrix{T} where {T <: Real}, rule::Type{R} where {R <: AbstractRule}) = expand_state(new(grid, rule, (1,1)))
    ## Grid + rule + origin
    StateSquare(grid::AbstractMatrix{T} where {T <: Real}, rule::Type{R} where {R <: AbstractRule}, origin::Tuple{Int64, Int64}) = new(grid, rule, origin, _SQUARE_RULE_ITERF_MAP[rule])
end

# UTIL: Iterate the grid for one stap, according to the rule
function _iter_grid_square_life(grid::BitMatrix)::BitMatrix
    rotated_grids = [circshift(grid, (x, y)) for x in -1:1 for y in -1:1] # convert(Matrix{Int64}, [circshift(grid, (x, y)) for x in -1:1 for y in -1:1])
    update_grid = reduce(+, rotated_grids[1:4]) + reduce(+, rotated_grids[6:end])
    update_grid2 = map(x->x==2 ? 1 : 0, update_grid)
    update_grid3 = map(x->x==3 ? 1 : 0, update_grid)
    new_grid = map(x->x≠0 ? true : false, update_grid3 .+ (update_grid2 .* grid))
    return new_grid
end

_SQUARE_RULE_ITERF_MAP = Dict{Type{R} where {R <: AbstractRule}, Function}(
    Life => _iter_grid_square_life
)

#= Utils =#
# Expand the state's grid and update its origin (util for one of the constructors)
function expand_state(state::StateSquare)
    new_grid, origin_expansion = expand_matrix(grid)
    new_origin = state.origin + origin_expansion
    return StateSquare(new_grid, state.rule, new_origin)
end

# Displaying a part of the state grid, using origin-based coordinates
function o_display(state::StateSquare, x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64})
    displayln(state.grid[o_inds(x_inds, y_inds, state.origin...)...])
end

function o_inds(x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64}, x_origin::Int64, y_origin::Int64)
    x_inds + (x_origin - 1), y_inds + (y_origin - 1)
end


end