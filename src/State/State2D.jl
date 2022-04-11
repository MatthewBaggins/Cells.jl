module State2D

using ..Abstract

#= State transition rules =#
export Life
struct Life <: AbstractRule2D end

#= Kinds of 2D states, differing in their geometry =#
export State2DSquare
struct State2DSquare <: AbstractState2D
    grid::Matrix{Bool}
    rule::Type{R} where {R <: AbstractRule2D}
    origin::Tuple{Int64, Int64} # To ensure stable coordinate system

    State2DSquare(grid::Matrix{N} where {N <: Real}) = State2DSquare(grid, Life)
    State2DSquare(grid::Matrix{N} where {N <: Real}, rule::Type{R} where {R <: AbstractRule2D}) = expand_state(new(grid, rule, (1,1)))
    State2DSquare(grid::Matrix{N} where {N <: Real}, rule::Type{R} where {R <: AbstractRule2D}, origin::Tuple{Int64, Int64}) = new(grid, rule, origin)
    
end

#= Displaying a part of the state grid, using origin-based coordinates =#
export o_display
function o_display(state::State2DSquare, x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64})
    displayln(state.grid[
        x_inds + state.origin[1], 
        y_inds + state.origin[2]
    ])
end

#= State grid expansion and origin update =#
export expand_state
function expand_state(state::State2DSquare)
    expanded_grid = deepcopy(state.grid)
    ox, oy = deepcopy(state.origin)
    if sum(state.grid[1,:]) != 0
        expanded_grid = vcat(zeros(1, size(expanded_grid)[2]), expanded_grid)
        ox += 1
    end
    if sum(state.grid[end,:]) != 0
        expanded_grid = vcat(expanded_grid, zeros(1, size(expanded_grid)[2]))
    end
    if sum(state.grid[:,1]) != 0
        expanded_grid = hcat(zeros(size(expanded_grid)[1], 1), expanded_grid)
        oy += 1
    end
    if sum(state.grid[:,end]) != 0
        expanded_grid = hcat(expanded_grid, zeros(size(expanded_grid)[1], 1))
    end
    
    return State2DSquare(expanded_grid, state.rule, (ox, oy))
end

#= Iterators =#

export iter_state

function iter_grid(grid::Matrix{Bool}, ::Type{Life})
    rotated_grids = [circshift(grid, (x, y)) for x in -1:1 for y in -1:1] # convert(Matrix{Int64}, [circshift(grid, (x, y)) for x in -1:1 for y in -1:1])
    update_grid = reduce(+, rotated_grids[1:4]) + reduce(+, rotated_grids[6:end])
    update_grid2 = map(x->x==2 ? 1 : 0, update_grid)
    update_grid3 = map(x->x==3 ? 1 : 0, update_grid)
    new_grid = map(x->x≠0 ? 1 : 0, update_grid3 .+ (update_grid2 .* grid))
    return new_grid
end

function iter_state(state::State2DSquare)
    new_grid = iter_grid(state.grid, state.rule)
    new_state = expand_state(State2DSquare(new_grid, state.rule, state.origin))
    return new_state
end

function iter_state(state::AbstractState2D, steps::Integer)
    new_state = deepcopy(state)
    for _ in 1:steps
        new_state = iter_state(new_state)
    end 
    return new_state
end

end