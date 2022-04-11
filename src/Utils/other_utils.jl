f ← x = f(x)

function displayln(x)
    display(x);println()
end

function min_and_max(xs::Vector{T} where {T <: Number})
    return (min(xs...), max(xs...))
end 

Base.:+(t1::Tuple{Vararg{Number}}, t2::Tuple{Vararg{Number}}) = map(x -> +(x...), Tuple(x for x in zip(t1, t2)))

Base.:+(r1::UnitRange, r2::UnitRange) = (first(r1)+first(r2)):(last(r1)+last(r2))

Base.:+(r::UnitRange, n::Real) = (first(r)+n):(last(r)+n)

Base.:+(r::UnitRange, n::Real) = (first(r)-n):(last(r)-n)

shift_range(r::UnitRange, offset::Real) = (first(r)+offset):(last(r)+offset)

#TODO: improve/refine this
function window(v, window_size::Int64, window_stride::Int64)
    @assert 0 ≤ window_size && 1 ≤ window_stride
    
    n_strides = ceil(length(v) / window_stride) + 1
    while ((n_strides - 1) * window_stride + window_size > length(v))
        n_strides -= 1
    end
    windows = [v[
        Int(i*window_stride+1) : Int(i*window_stride+window_size)
        ] for i in 0:(n_strides-1)]
    return windows
end

#TODO: Improve/generalize this
function window_padded(v, window_size::Integer, window_stride::Integer)
    window(cat([0], v, [0], dims=1), window_size, window_stride)
    # window(cat(zeros(window_size-1), v, zeros(window_size-1), dims=1), window_size, window_stride)
end

function mosaic4(x::Matrix, padding::Integer=1)
    @assert 0 ≤ padding
    vcatted = vcat(x, zeros(padding, size(x)[2]), reverse(x, dims=1)) 
    hcat(vcatted, zeros(size(vcatted)[1], padding), reverse(vcatted, dims=2))
end

function mosaic2(x::Matrix, padding::Integer=1, dim::Integer=1)
    @assert 0 ≤ padding
    @assert 1 ≤ dim ≤ 2
    x_zeros = zeros(padding, size(x)[dim%2+1])
    if (dim == 2) x_zeros = x_zeros' end
    x_rev = reverse(x, dims=dim)
    cat(x, x_zeros, x_rev, dims=dim)
end