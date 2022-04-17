module StateECAs


using ..Abstract
using ..Utils
using Images
using Colors
using ImageView, Gtk.ShortNames

#= Wolfram's Elementary Cellular Automata =#

struct StateECA <: AbstractStateECA
    grid::BitVector
    rule::UInt8
    rule_map::Dict{Tuple{Bool, Bool, Bool}, Bool}

    # Default constructor with the default rule
    StateECA() = StateECA(30)

    # Default constructor from a specified rule
    StateECA(rule::Unsigned) = StateECA(cat(falses(15), true, falses(15), dims=1), rule%256)

    # Constructors from a specified grid
    StateECA(grid::Union{Vector{T}, BitVector} where {T <: Real}, rule) = new(
        map(x -> x == 0 ? false : true, grid), 
        rule,
        _build_map(convert(UInt8, abs(rule)%256)))

end

# UTIL: Map the number of a Wolfram rule (0-255) to the proper map
function _build_map(rule::UInt8)::Dict{Tuple{Bool, Bool, Bool}, Bool}
    global _ECA_CONTEXTS
    state_map = Dict(
        context => (nextcell == '0' ? false : true) for (context, nextcell) in zip(
            _ECA_CONTEXTS, string(rule, base=2, pad=8)))
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


end