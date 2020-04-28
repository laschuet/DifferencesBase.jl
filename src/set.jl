"""
    SetDifference{T} <: AbstractDifference

Set difference.
"""
struct SetDifference{T} <: AbstractDifference
    comvals::Set{T}
    addvals::Set{T}
    remvals::Set{T}
end
SetDifference(comvals::AbstractVector{T}, addvals::AbstractVector{T},
            remvals::AbstractVector{T}) where {T} =
    SetDifference(Set(comvals), Set(addvals), Set(remvals))

# Set difference equality operator
==(a::SetDifference, b::SetDifference) =
    a.comvals == b.comvals && a.addvals == b.addvals && a.remvals == b.remvals

# Set difference hash code
hash(a::SetDifference, h::UInt) =
    hash(a.comvals, hash(a.addvals, hash(a.remvals, hash(:SetDifference, h))))

"""
    common(a::SetDifference)

Access the modified elements.
"""
common(a::SetDifference) = a.comvals

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
diff(a::AbstractSet, b::AbstractSet) =
    intersect(a, b), setdiff(b, a), setdiff(a, b)
