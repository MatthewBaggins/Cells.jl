module Iter

using ..Abstract
import ..Expand: pad_matrix, expand_vector, expand_matrix
import ..Utils: window_padded, displayln

#= ECA =#
# Iterate the state for one step
function iter_state(state::AbstractStateECA)
    state_map = state.rule_map
    state_windows = window_padded(state.grid, 3, 1)
    new_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    return typeof(state)(new_state_grid, state.rule)
end

# Iterate the state for a number of steps, don't record the history, return only the final state
function iter_state(state::AbstractStateECA, n_steps::Int64)
    new_grid = deepcopy(state.grid)
    state_map = state.rule_map
    for _ in 1:n_steps
        state_windows = window_padded(new_grid, 3, 1)
        new_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    end
    return typeof(state)(new_grid, state.rule)
end

# Iterate the state for a number of steps'; return the entire history as a matrix
function iter_states(state::AbstractStateECA, n_steps::Integer)::BitMatrix
    history = [state.grid]
    new_grid = deepcopy(state.grid)
    state_map = state.rule_map
    for _ in 1:n_steps
        state_windows = window_padded(new_grid, 3, 1)
        
        new_grid, (first_expanded, last_expanded) = expand_vector(
            [state_map[Tuple(w)] for w in state_windows])
        if first_expanded
            history = map(
                x -> vcat([0], x), 
                history)
        end
        if last_expanded
            history = map(
                x -> vcat(x, [0]), 
                history)
        end
        push!(history, new_grid)
    end
    return reduce(hcat, history)'
end


#= 2D =#
# Iterate the state for one step using `iter_grid`
function iter_state(state::AbstractState2D)
    iter_grid = state.iterf
    new_grid, expansion_report = iter_grid(state.grid) |> expand_matrix
    new_origin = state.origin + expansion_report
    new_state = typeof(state)(new_grid, state.rule, new_origin)
    return new_state
end

# Iterate the state for a number of steps using `iter_grid`; don't record the history, return only the final state
function iter_state(state::AbstractState2D, n_steps::Integer)
    iter_grid = state.iterf
    new_grid = deepcopy(state.grid)
    new_origin = deepcopy(state.origin)
    for _ in 1:n_steps
        new_grid, expansion_report = iter_grid(new_grid) |> expand_matrix
        new_origin = state.origin + expansion_report
    end
    new_state = typeof(state)(new_grid, state.rule, new_origin)
    return new_state
end

# Iterate the state for a number of steps using `iter_grid`; return the entire history as a vector of grids
function iter_states(state::AbstractState2D, n_steps::Integer)::Vector{BitMatrix}
    iter_grid = state.iterf
    history = [state.grid]
    new_grid = deepcopy(state.grid)
    new_origin = deepcopy(state.origin)
    for i in 1:n_steps
        new_grid, expansion_report = iter_grid(new_grid) |> expand_matrix
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


end