module State1D

using ..Abstract
using ..Utils
using Images
using Colors
using ImageView, Gtk.ShortNames

#= Wolfram's 1D automata =#
export State1DWolfram
struct State1DWolfram <: AbstractState1D
    grid::Vector{Bool}
    rule::UInt8
    State1DWolfram(grid::Vector{T} where {T <: Real}, rule) = new(
        map(x -> x == 0 ? false : true, grid), rule)
end

#= Map a Wolfram rule number (0-255) to the proper map =#
export wr2map
function wr2map(wr::UInt8)::Dict{Tuple{Bool, Bool, Bool}, Bool}
    global _WOLFRAM_STATES
    state_map = Dict(
        context => (nextcell == '0' ? false : true) for (context, nextcell) in zip(
            _WOLFRAM_STATES, string(wr, base=2, pad=8)))
    return state_map
end

global _WOLFRAM_STATES = (
    (true, true, true),
    (true, true, false),
    (true, false, true),
    (true, false, false),
    (false, true, true),
    (false, true, false),
    (false, false, true),
    (false, false, false))

#= Map a vector of 8 Boolean values to the Wolfram rule number =#
export vec2wr
function vec2wr(v::Vector{Bool})::UInt8
    if length(v) != 8
        throw(ArgumentError("The vector's length is $(length(v)), should be 8."))
    end
    return parse(UInt8, join(map(x -> x ? 1 : 0, v)), base=2)
end
vec2wr(v::Vector{T} where {T <: Number}) = vec2wr(map(x -> x == 0 ? false : true, v))

#= Iterators =#

export iter_state, iter_states

function iter_state(state::State1DWolfram)
    state_map = wr2map(state.rule)
    state_windows = window_padded(state.grid, 3, 1)
    next_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    return State1DWolfram(next_state_grid, state.rule)
end

function iter_state(state::State1DWolfram, n_steps::Int64)
    state_map = wr2map(state.rule)
    next_state_grid = deepcopy(state.grid)
    for step in 1:n_steps
        state_windows = window_padded(next_state_grid, 3, 1)
        next_state_grid = expand_vector([state_map[Tuple(w)] for w in state_windows])
    end
    return State1DWolfram(next_state_grid, state.rule)
end

function iter_states(state::State1DWolfram, n_steps::Integer)::Matrix{Bool}
    state_map = wr2map(state.rule)
    next_state_grid = deepcopy(state.grid)
    history = [next_state_grid]
    for _ in 1:n_steps
        # println(next_state_grid)
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

end