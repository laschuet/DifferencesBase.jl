"""
    diff(a::AbstractVector, b::AbstractVector)

Compute the difference between vector `a` and vector `b`, and return a tuple
containing the elements that have been modified, added, and removed.
"""
function Base.diff(a::AbstractVector, b::AbstractVector)
    return diff(a, b, collect(1:size(a, 1)), collect(1:size(b, 1)))
end

"""
    diff(a::AbstractVector, b::AbstractVector, ia::AbstractVector, ib::AbstractVector)

Like [`diff`](@ref), but provide integer vectors that number the rows of the
vectors `a` and `b`. The vectors `ia` and `ib` represent the row numbers of
`a` and `b` respectively. The position of each vector element refers to the
row index of `a` or `b`.
"""
function Base.diff(
    a::AbstractVector, b::AbstractVector, ia::AbstractVector, ib::AbstractVector
)
    if length(a) == 0 || length(b) == 0
        T = promote_type(eltype(a), eltype(b))
        vab = sparse(view(T[], :))
        va = view(a, :)
        vb = view(b, :)
        ei = Int[]
        length(a) == 0 && return VectorDifference(ei, ei, ei, vab, vb, va)
        length(b) == 0 && return VectorDifference(ei, ei, ei, vab, va, vb)
    end

    mapa = Dict(zip(ia, 1:length(ia)))
    mapb = Dict(zip(ib, 1:length(ib)))

    # Compute modified indices and values
    modinds = intersect(ia, ib)
    mapped_modindsa = getindex.(Ref(mapa), modinds)
    mapped_modindsb = getindex.(Ref(mapb), modinds)
    modvals = sparse(view(a, mapped_modindsa) - view(b, mapped_modindsb))

    # Compute added indices and values
    addinds = setdiff(ib, ia)
    mapped_addinds = getindex.(Ref(mapb), addinds)
    addvals = view(b, mapped_addinds)

    # Compute removed indices and values
    reminds = setdiff(ia, ib)
    mapped_reminds = getindex.(Ref(mapa), reminds)
    remvals = view(a, mapped_reminds)

    return VectorDifference(modinds, addinds, reminds, modvals, addvals, remvals)
end

"""
    diff(A::AbstractMatrix, B::AbstractMatrix)

Compute the difference between matrix `A` and matrix `B`, and return a tuple
containing the elements that have been modified, added (per row and column), and
removed (per row and column).
"""
function Base.diff(A::AbstractMatrix, B::AbstractMatrix)
    ia = collect(1:size(A, 1))
    ja = collect(1:size(A, 2))
    ib = collect(1:size(B, 1))
    jb = collect(1:size(B, 2))
    return diff(A, B, ia, ja, ib, jb)
end

"""
    diff(A::AbstractMatrix, B::AbstractMatrix, ia::AbstractVector, ja::AbstractVector, ib::AbstractVector, jb::AbstractVector)

Like [`diff`](@ref), but provide integer vectors that number the rows and
columns of the matrices `A` and `B`. The vector `ia` represents the row numbers
of `A`, and the vector `jb` represents the column numbers of `B` etc. The
position of each vector element refers to the row index (or column index
respectively) of `A` or `B`.
"""
function Base.diff(
    A::AbstractMatrix,
    B::AbstractMatrix,
    ia::AbstractVector,
    ja::AbstractVector,
    ib::AbstractVector,
    jb::AbstractVector,
)
    if size(A) == (0, 0) || size(B) == (0, 0)
        T = promote_type(eltype(A), eltype(B))
        vab = sparse(view(T[], :))
        va = view(A, :)
        vb = view(B, :)
        ei = Int[]
        size(A) == (0, 0) &&
            return MatrixDifference((ei, ei), (ei, ei), (ei, ei), vab, vb, va)
        size(B) == (0, 0) &&
            return MatrixDifference((ei, ei), (ei, ei), (ei, ei), vab, va, vb)
    end

    mapia = Dict(zip(ia, 1:length(ia)))
    mapja = Dict(zip(ja, 1:length(ja)))
    mapib = Dict(zip(ib, 1:length(ib)))
    mapjb = Dict(zip(jb, 1:length(jb)))

    # Compute modified indices and values
    i = intersect(ia, ib)
    j = intersect(ja, jb)
    ia2 = getindex.(Ref(mapia), i)
    ja2 = getindex.(Ref(mapja), j)
    ib2 = getindex.(Ref(mapib), i)
    jb2 = getindex.(Ref(mapjb), j)
    modvals = sparse(vec(view(A, ia2, ja2) - view(B, ib2, jb2)))

    # Compute added indices and values
    addinds = (setdiff(ib, ia), setdiff(jb, ja))
    indicesb = CartesianIndices(B)
    modindicesb = CartesianIndex.(Iterators.product(ib2, jb2))
    addindices = setdiff(indicesb, modindicesb)
    addvals = view(B, addindices)

    # Compute removed indices and values
    reminds = (setdiff(ia, ib), setdiff(ja, jb))
    indicesa = CartesianIndices(A)
    modindicesa = CartesianIndex.(Iterators.product(ia2, ja2))
    remindices = setdiff(indicesa, modindicesa)
    remvals = view(A, remindices)

    return MatrixDifference((i, j), addinds, reminds, modvals, addvals, remvals)
end

"""
    diff(a::NamedTuple, b::NamedTuple)

Compute the difference between named tuple `a` and named tuple `b`, and return a
tuple containing the unique elements that have been modified, added, and
removed.
"""
function Base.diff(a::NamedTuple, b::NamedTuple)
    modnames = intersect(keys(a), keys(b))
    addnames = setdiff(keys(b), keys(a))
    remnames = setdiff(keys(a), keys(b))

    # Compute modified values
    modvalues = []
    for n in modnames
        typeof(a[n]) != typeof(b[n]) &&
            throw(ArgumentError("type of values of common names in `a` and `b` must match"))
        v = typeof(a[n]) <: Number ? a[n] - b[n] : diff(a[n], b[n])
        push!(modvalues, v)
    end
    modvals = (; zip(modnames, modvalues)...)

    # Compute added values
    addvalues = []
    for n in addnames
        push!(addvalues, b[n])
    end
    addvals = (; zip(addnames, addvalues)...)

    # Compute removed values
    remvalues = []
    for n in remnames
        push!(remvalues, a[n])
    end
    remvals = (; zip(remnames, remvalues)...)

    return NamedTupleDifference(modvals, addvals, remvals)
end

"""
    diff(a::AbstractSet, b::AbstractSet)

Compute the difference between set `a` and set `b`, and return a tuple
containing the unique elements that have been shared, added, and removed.

# Examples
```jldoctest
julia> diff(Set([1, 2, 3, 3]), Set([4, 2, 1]))
(Set([1, 2]), Set([4]), Set([3]))
```
"""
Base.diff(a::AbstractSet, b::AbstractSet) =
    SetDifference(intersect(a, b), setdiff(b, a), setdiff(a, b))
