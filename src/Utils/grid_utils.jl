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

function expand_vector_report(v::Vector)::Tuple{Vector, Bool, Bool}
    new_v = deepcopy(v)
    if v[1] != 0
        first_expanded = true; pushfirst!(new_v, 0)
    else 
        first_expanded = false
    end
    if v[end] != 0
        last_expanded = true; push!(new_v, 0)
    else 
        last_expanded = false
    end
    return (new_v, first_expanded, last_expanded)
end