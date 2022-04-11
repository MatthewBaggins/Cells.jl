#TODO: should this update origin?
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
        m_size[1], target_pos[2]-1 
    ), m)
    
    # Pad cols from right
    m = hcat(m, zeros(
        m_size[1], target_size[2]-target_pos[2]-m_size[2]+1
    ))
    
    return m

end

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


# function expand_grid(grid::Array{T, 2})::Array{Int64, 2} where {T <: Real}
#     expanded_grid = deepcopy(grid)
#     if sum(grid[1,:]) != 0
#         expanded_grid = vcat(zeros(1, size(expanded_grid)[2]), expanded_grid)
#     end
#     if sum(grid[end,:]) != 0
#         expanded_grid = vcat(expanded_grid, zeros(1, size(expanded_grid)[2]))
#     end
#     if sum(grid[:,1]) != 0
#         expanded_grid = hcat(zeros(size(expanded_grid)[1], 1), expanded_grid)
#     end
#     if sum(grid[:,end]) != 0
#         expanded_grid = hcat(expanded_grid, zeros(size(expanded_grid)[1], 1))
#     end
    
#     return expanded_grid 
# end

