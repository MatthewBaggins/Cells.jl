module Expand 


#= Expand =#

# Expand the vector: pad its ends with zeros if they are not zeros already and report whether its start and end were expanded
function expand_vector(v::AbstractVector)::Tuple{Vector, Tuple{Bool, Bool}}
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


# Expand a matrix and report whether the first row and col were expanded
function expand_matrix(m::A)::Tuple{A, Tuple{Int64, Int64}} where {A <: AbstractMatrix}
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
function pad_matrix(m::AbstractMatrix, target_size::Tuple{Int64, Int64}, target_pos::Tuple{Int64, Int64})
    m_size = size(m)
    m_padded = deepcopy(m)
    
    # Pad rows above
    m_padded = vcat(zeros(
        target_pos[1]-1, m_size[2]
    ), m_padded)

    # Pad rows below
    m_padded = vcat(m_padded, zeros(
        target_size[1]-target_pos[1]-m_size[1]+1, m_size[2]
    ))
    m_size = size(m_padded)
    
    # Pad cols from left
    m_padded = hcat(zeros(
        m_size[1], target_pos[2]-1,
    ), m_padded)
    
    # Pad cols from right
    m_padded = hcat(m_padded, zeros(
        m_size[1], target_size[2]-target_pos[2]-m_size[2]+1
    ))
    
    return m_padded
end


end