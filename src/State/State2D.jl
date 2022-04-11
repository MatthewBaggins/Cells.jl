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
    State2DSquare(::Type{Life}) = new(falses(3,3), Life, (0,0))
    State2DSquare() = State2DSquare(Life)
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
export expand_state, pad_matrix
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

export iter_state, iter_states

function iter_grid(grid::Matrix{Bool}, ::Type{Life})
    rotated_grids = [circshift(grid, (x, y)) for x in -1:1 for y in -1:1] # convert(Matrix{Int64}, [circshift(grid, (x, y)) for x in -1:1 for y in -1:1])
    update_grid = reduce(+, rotated_grids[1:4]) + reduce(+, rotated_grids[6:end])
    update_grid2 = map(x->x==2 ? 1 : 0, update_grid)
    update_grid3 = map(x->x==3 ? 1 : 0, update_grid)
    new_grid = map(x->x≠0 ? true : false, update_grid3 .+ (update_grid2 .* grid))
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

function iter_states(state::AbstractState2D, steps::Integer)::Vector{Matrix{Bool}}
    next_state_grid = deepcopy(state.grid)
    history = [next_state_grid]
    for _ in 1:steps
        next_state_grid = iter_grid(next_state_grid, state.rule)
        next_state_grid, report = expand_matrix_report(next_state_grid)
        if size(next_state_grid) != size(history[end])
            h_pos = (1+("first_row" in report), 1+("first_col" in report))
            history = map(h -> pad_matrix(h, size(next_state_grid), h_pos), history)
        end
        push!(history, next_state_grid)
    end 
    return history
end

function expand_matrix_report(m::Matrix{Bool})::Tuple{Matrix{Bool}, Vector{String}}
    m_expanded = deepcopy(m)
    report = []
    if sum(m[1,:]) != 0
        m_expanded = vcat(falses(1, size(m_expanded)[2]), m_expanded)
        push!(report, "first_row")
    end
    if sum(m[end,:]) != 0
        m_expanded = vcat(m_expanded, falses(1, size(m_expanded)[2]))
        push!(report, "last_row")
    end
    if sum(m[:,1]) != 0
        m_expanded = hcat(falses(size(m_expanded)[1], 1), m_expanded)
        push!(report, "first_col")
    end
    if sum(m[:,end]) != 0
        m_expanded = hcat(m_expanded, falses(size(m_expanded)[1], 1))
        push!(report, "last_col")
    end
    
    return m_expanded, report
end

function pad_matrix(matrix::Matrix, target_size::Tuple{Int64, Int64}, target_pos::Tuple{Int64, Int64})
    m_size = size(matrix)
    m = deepcopy(matrix)
    println(target_size)
    println(target_pos)
    
    # Pad rows above
    m = vcat(zeros(
        target_pos[1]-1, m_size[2]
    ), m)
    
    println(size(m))
    println((target_size[1]-target_pos[1]-m_size[1]+1, m_size[2]))

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

end