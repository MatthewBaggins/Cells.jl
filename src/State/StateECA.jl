module State1D

using ..Abstract
using ..Utils
using Images
using Colors
using ImageView, Gtk.ShortNames

#= Wolfram's Elementary Cellular Automata =#
export StateECA
struct StateECA <: AbstractState1D
    grid::BitVector #TODO: Change to BitVector and BitMatrix
    rule::UInt8
    StateECA(grid::Vector{T} where {T <: Real}, rule) = new(
        map(x -> x == 0 ? false : true, grid), rule)
    StateECA(rule::Unsigned) = new(cat(falses(15), true, falses(15), dims=1), rule)
end

#= Map the number of a Wolfram rule (0-255) to the proper map =#
function _rule_to_map(wr::UInt8)::Dict{Tuple{Bool, Bool, Bool}, Bool}
    global _ECA_CONTEXTS
    state_map = Dict(
        context => (nextcell == '0' ? false : true) for (context, nextcell) in zip(
            _ECA_CONTEXTS, string(wr, base=2, pad=8)))
    return state_map
end

global _ECA_CONTEXTS = (
    (true, true, true),
    (true, true, false),
    (true, false, true),
    (true, false, false),
    (false, true, true),
    (false, true, false),
    (false, false, true),
    (false, false, false))

#= Iter =#

export iter_state, iter_states

function iter_state(state::StateECA)
    state_map = _rule_to_map(state.rule)
    state_windows = window_padded(state.grid, 3, 1)
    next_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    return StateECA(next_state_grid, state.rule)
end

function iter_state(state::StateECA, n_steps::Int64)
    state_map = _rule_to_map(state.rule)
    next_state_grid = deepcopy(state.grid)
    for _ in 1:n_steps
        state_windows = window_padded(next_state_grid, 3, 1)
        next_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    end
    return StateECA(next_state_grid, state.rule)
end

function iter_states(state::StateECA, n_steps::Integer)::Matrix{Bool}
    state_map = _rule_to_map(state.rule)
    next_state_grid = deepcopy(state.grid)
    history = [next_state_grid]
    for _ in 1:n_steps
        state_windows = window_padded(next_state_grid, 3, 1)
        next_state_grid, first_expanded, last_expanded = expand_vector_report(
            [state_map[Tuple(w)] for w in state_windows])
        if first_expanded
            history = map(x -> cat([0], x, dims=1), history)
        end
        if last_expanded
            history = map(x -> cat(x, [0], dims=1), history)
        end
        push!(history, next_state_grid)
    end
    return reduce(hcat, history)'
end

#= Expand =#

# Expand the vector: pad its ends with zeros if they are not zeros already
function expand_vector(v::Vector)
    new_v = deepcopy(v)
    if v[1] != 0
        pushfirst!(new_v, 0)
    end
    if v[end] != 0
        push!(new_v, 0)
    end
    return new_v
end

# Expand the vector and report whether its start and end were expanded
function expand_vector_report(v::Vector)::Tuple{Vector, Bool, Bool}
    new_v = deepcopy(v)
    start_expanded = end_expanded = false
    if v[1] != 0
        start_expanded = true
        pushfirst!(new_v, 0)
    end
    if v[end] != 0
        end_expanded = true
        push!(new_v, 0)
    end
    return (new_v, start_expanded, end_expanded)
end

end