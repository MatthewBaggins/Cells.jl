module State2D

using ..Abstract

#= State transition rules =#
export Life
struct Life <: AbstractRule2D end

#= Kinds of 2D states, differing in their geometry =#
export StateSquare
struct StateSquare <: AbstractState2D
    grid::BitMatrix
    rule::Type{R} where {R <: AbstractRule2D}
    origin::Tuple{Int64, Int64} # To ensure stable coordinate system
    
    # Constructors
    StateSquare(grid::Matrix{N} where {N <: Real}) = StateSquare(grid, Life)
    StateSquare(grid::Matrix{N} where {N <: Real}, rule::Type{R} where {R <: AbstractRule2D}) = expand_state(new(grid, rule, (1,1)))
    StateSquare(grid::Matrix{N} where {N <: Real}, rule::Type{R} where {R <: AbstractRule2D}, origin::Tuple{Int64, Int64}) = new(grid, rule, origin)
    StateSquare(::Type{Life}) = new(falses(3,3), Life, (1,1))
    StateSquare() = StateSquare(Life)
end

#= Displaying a part of the state grid, using origin-based coordinates =#
export o_display, o_inds
function o_display(state::StateSquare, x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64})
    displayln(state.grid[o_inds(x_inds, y_inds, state.origin...)...])
end

function o_inds(x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64}, x_origin::Int64, y_origin::Int64)
    x_inds + (x_origin - 1), y_inds + (y_origin - 1)
end

#= Iter =#

export iter_state, iter_states

function iter_grid(grid::Matrix{Bool}, ::Type{Life})
    rotated_grids = [circshift(grid, (x, y)) for x in -1:1 for y in -1:1] # convert(Matrix{Int64}, [circshift(grid, (x, y)) for x in -1:1 for y in -1:1])
    update_grid = reduce(+, rotated_grids[1:4]) + reduce(+, rotated_grids[6:end])
    update_grid2 = map(x->x==2 ? 1 : 0, update_grid)
    update_grid3 = map(x->x==3 ? 1 : 0, update_grid)
    new_grid = map(x->x≠0 ? true : false, update_grid3 .+ (update_grid2 .* grid))
    return new_grid
end

function iter_state(state::StateSquare)
    new_grid = iter_grid(state.grid, state.rule)
    new_state = expand_state(StateSquare(new_grid, state.rule, state.origin))
    return new_state
end

function iter_state(state::AbstractState2D, steps::Integer)
    new_state = deepcopy(state)
    for _ in 1:steps
        new_state = iter_state(new_state)
    end 
    return new_state
end

function iter_states(state::AbstractState2D, steps::Integer)::Vector{Matrix{Bool}}
    next_state_grid = deepcopy(state.grid)
    history = [next_state_grid]
    for _ in 1:steps
        next_state_grid = iter_grid(next_state_grid, state.rule)
        next_state_grid, (
            first_row_expanded, _, 
            first_col_expanded, _) = expand_matrix_report(next_state_grid)
        if size(next_state_grid) != size(history[end])
            h_pos = (1+first_row_expanded, 1+first_col_expanded)
            history = map(h -> pad_matrix(h, size(next_state_grid), h_pos), history)
        end
        push!(history, next_state_grid)
    end 
    return history
end

#= Expand =#

#= State grid expansion and origin update =#
function pad_matrix(matrix::Matrix, target_size::Tuple{Int64, Int64}, target_pos::Tuple{Int64, Int64})
    m_size = size(matrix)
    m = deepcopy(matrix)
    
    # Pad rows above
    m = vcat(zeros(
        target_pos[1]-1, m_size[2]
    ), m)

    # Pad rows below
    m = vcat(m, zeros(
        target_size[1]-target_pos[1]-m_size[1]+1, m_size[2]
    ))
    m_size = size(m)
    
    # Pad cols from left
    m = hcat(zeros(
        m_size[1], target_pos[2]-1,
    ), m)
    
    # Pad cols from right
    m = hcat(m, zeros(
        m_size[1], target_size[2]-target_pos[2]-m_size[2]+1
    ))
    
    return m
end

function expand_state(state::StateSquare)
    new_origin = state.origin + (sum(state.grid[1,:]) > 0, sum(state.grid[:,1]) > 0)
    target_size = size(state.grid) + (sum(state.grid[1,:]) > 0, sum(state.grid[:,1]) > 0) + (sum(state.grid[end,:]) > 0, sum(state.grid[:,end]) > 0)
    new_grid = pad_matrix(state.grid, target_size, new_origin)
    return StateSquare(new_grid, state.rule, new_origin)
end

function expand_matrix_report(m::Matrix{Bool})::Tuple{Matrix{Bool}, Tuple{Bool, Bool, Bool, Bool}}
    m_expanded = deepcopy(m)
    first_row_expanded = last_row_expanded = first_col_expanded  = last_col_expanded = false
    if sum(m[1,:]) != 0
        m_expanded = vcat(falses(1, size(m_expanded)[2]), m_expanded)
        first_row_expanded = true
    end
    if sum(m[end,:]) != 0
        m_expanded = vcat(m_expanded, falses(1, size(m_expanded)[2]))
        last_row_expanded = true
    end
    if sum(m[:,1]) != 0
        m_expanded = hcat(falses(size(m_expanded)[1], 1), m_expanded)
        first_col_expanded = true
    end
    if sum(m[:,end]) != 0
        m_expanded = hcat(m_expanded, falses(size(m_expanded)[1], 1))
        last_col_expanded = true
    end
    
    return m_expanded, (first_row_expanded, last_row_expanded, first_col_expanded, last_col_expanded)
end

end