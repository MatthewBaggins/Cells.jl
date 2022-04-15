module StateSquares


using ..Abstract

#= State transition rules 
The rules determine solely how `iter_grid` works
For each rule, a separate `iter_grid` method will be defined
Each subtype of `AbstractState2D` will have its own set of `iter_grid` methods defined, one for each rule
=#
export Life
struct Life <: AbstractRule end

#= Kinds of 2D states, differing in their geometry =#
export StateSquare

struct StateSquare <: AbstractState2D
    grid::BitMatrix
    rule::Type{R} where {R <: AbstractRule}
    origin::Tuple{Int64, Int64} # To ensure stable coordinate system
    
    # Default constructor with the default rule
    StateSquare() = StateSquare(Life)

    # Default constructor from a specified rule
    StateSquare(rule::AbstractRule) = new(falses(3,3), rule, (1,1))

    # Constructors from a specified grid
    ## Grid only
    StateSquare(grid::Matrix{T} where {T <: Real}) = StateSquare(grid, Life)
    ## Grid + rule
    StateSquare(grid::Matrix{T} where {T <: Real}, rule::Type{R} where {R <: AbstractRule}) = expand_state(new(grid, rule, (1,1)))
    ## Grid + rule + origin
    StateSquare(grid::Matrix{T} where {T <: Real}, rule::Type{R} where {R <: AbstractRule}, origin::Tuple{Int64, Int64}) = new(grid, rule, origin)
end

#= Iter =#
export iter_state, iter_states

# Iterate the state for one step using `iter_grid`
function iter_state(state::AbstractState2D)
    new_grid, expansion_report = iter_grid(state.grid, state.rule) |> expand_matrix
    new_origin = state.origin + expansion_report
    new_state = typeof(state)(new_grid, state.rule, new_origin)
    return new_state
end

# Iterate the state for a number of steps using `iter_grid`; don't record the history, return only the final state
function iter_state(state::AbstractState2D, n_steps::Integer)
    new_grid = deepcopy(state.grid)
    new_origin = deepcopy(state.origin)
    for _ in 1:n_steps
        new_grid, expansion_report = iter_grid(new_grid, state.rule) |> expand_matrix
        new_origin = state.origin + expansion_report
    end
    new_state = typeof(state)(new_grid, state.rule, new_origin)
    return new_state
end

# Iterate the state for a number of steps using `iter_grid`; return the entire history as a vector of grids
function iter_states(state::AbstractState2D, n_steps::Integer)::Vector{BitMatrix}
    history = [state.grid]
    new_grid = deepcopy(state.grid)
    new_origin = deepcopy(state.origin)
    for _ in 1:n_steps
        new_grid, expansion_report = iter_grid(new_grid, state.rule) |> expand_matrix
        new_origin += expansion_report
        if size(new_grid) != size(history[end])
            history = map(
                g -> pad_matrix(
                    g, size(new_grid), (1, 1) + expansion_report), 
                history)
        end
        push!(history, new_grid)
    end 
    return history
end

# UTIL: Iterate the grid for one stap, according to the rule
function iter_grid(grid::BitMatrix, ::Type{Life})::BitMatrix
    rotated_grids = [circshift(grid, (x, y)) for x in -1:1 for y in -1:1] # convert(Matrix{Int64}, [circshift(grid, (x, y)) for x in -1:1 for y in -1:1])
    update_grid = reduce(+, rotated_grids[1:4]) + reduce(+, rotated_grids[6:end])
    update_grid2 = map(x->x==2 ? 1 : 0, update_grid)
    update_grid3 = map(x->x==3 ? 1 : 0, update_grid)
    new_grid = map(x->x≠0 ? true : false, update_grid3 .+ (update_grid2 .* grid))
    return new_grid
end

#= Expand =#
# Expand a matrix and report whether the first row and col were expanded
function expand_matrix(m::Matrix)::Tuple{Matrix, Tuple{Int64, Int64}}
    first_row_expanded = sum(m[1,:]) > 0
    first_col_expanded = sum(m[:,1]) > 0
    last_row_expanded = sum(m[end,:]) > 0
    last_col_expanded = sum(m[:,end]) > 0
    target_size = (
        size(m) 
        + (first_row_expanded, first_col_expanded) 
        + (last_row_expanded, last_col_expanded))
    m_expanded = pad_matrix(m, target_size, (1+first_row_expanded, 1+first_col_expanded))
    return m_expanded, (first_row_expanded, first_col_expanded)
end

# Pad the matrix with zero to make its size equal to `target_size` and placing it within the old grid according to `target_pos`
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

# Expand the state's grid and update its origin (util for one of the constructors)
function expand_state(state::StateSquare)
    new_grid, origin_expansion = expand_matrix(grid)
    new_origin = state.origin + origin_expansion
    return StateSquare(new_grid, state.rule, new_origin)
end

#= Utils =#
# Displaying a part of the state grid, using origin-based coordinates
export o_display, o_inds

function o_display(state::StateSquare, x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64})
    displayln(state.grid[o_inds(x_inds, y_inds, state.origin...)...])
end

function o_inds(x_inds::UnitRange{Int64}, y_inds::UnitRange{Int64}, x_origin::Int64, y_origin::Int64)
    x_inds + (x_origin - 1), y_inds + (y_origin - 1)
end



end