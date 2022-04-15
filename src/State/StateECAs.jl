module StateECAs

using ..Abstract
using ..Utils
using Images
using Colors
using ImageView, Gtk.ShortNames

#= Wolfram's Elementary Cellular Automata =#
export StateECA

struct StateECA <: AbstractState1D
    grid::BitVector
    rule::UInt8

    # Default constructor with the default rule
    StateECA() = StateECA(30)

    # Default constructor from a specified rule
    StateECA(rule::Unsigned) = new(cat(falses(15), true, falses(15), dims=1), rule%256)

    # Constructors from a specified grid
    StateECA(grid::Vector{T} where {T <: Real}, rule) = new(
        map(x -> x == 0 ? false : true, grid), rule)
end

#= Iter =#
export iter_state, iter_states

# Iterate the state for one step
function iter_state(state::StateECA)
    state_map = _rule_to_map(state.rule)
    state_windows = window_padded(state.grid, 3, 1)
    new_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    return StateECA(new_state_grid, state.rule)
end

# Iterate the state for a number of steps, don't record the history, return only the final state
function iter_state(state::StateECA, n_steps::Int64)
    new_grid = deepcopy(state.grid)
    state_map = _rule_to_map(state.rule)
    for _ in 1:n_steps
        state_windows = window_padded(new_grid, 3, 1)
        new_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    end
    return StateECA(new_grid, state.rule)
end

# Iterate the state for a number of steps'; return the entire history as a matrix
function iter_states(state::StateECA, n_steps::Integer)::BitMatrix
    history = [state.grid]
    new_grid = deepcopy(state.grid)
    state_map = _rule_to_map(state.rule)
    for _ in 1:n_steps
        state_windows = window_padded(new_grid, 3, 1)
        # displayln(new_grid)
        # displayln(state_windows)
        
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

# UTIL: Map the number of a Wolfram rule (0-255) to the proper map
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

#= Expand =#

# Expand the vector: pad its ends with zeros if they are not zeros already and report whether its start and end were expanded
function expand_vector(v::Vector)::Tuple{Vector, Tuple{Bool, Bool}}
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
    return new_v, (start_expanded, end_expanded)
end


end