"""
    AbstractDifference

Supertype for differences.
"""
abstract type AbstractDifference end

"""
    ArrayDifference{Tm<:AbstracArray,Ta<:AbstractArray,Tr<:AbstractArray} <: AbstractDifference

Array difference.
"""
struct ArrayDifference{Tm<:AbstractArray,Ta<:AbstractArray,Tr<:AbstractArray} <: AbstractDifference
    modvals::Tm
    addvals::Ta
    remvals::Tr
end
const VectorDifference = ArrayDifference
const MatrixDifference = ArrayDifference

"""
    NamedTupleDifference <: AbstractDifference

Named tuple difference.
"""
struct NamedTupleDifference{Tm<:NamedTuple,Ta<:NamedTuple,Tr<:NamedTuple} <: AbstractDifference
    modvals::Tm
    addvals::Ta
    remvals::Tr
end

"""
    SetDifference{T} <: AbstractDifference

Set difference.
"""
struct SetDifference{Tc,Ta,Tr} <: AbstractDifference
    comvals::Set{Tc}
    addvals::Set{Ta}
    remvals::Set{Tr}
end

# Equality operator
Base.:(==)(a::Union{ArrayDifference,NamedTupleDifference}, b::Union{ArrayDifference,NamedTupleDifference}) =
    a.modvals == b.modvals && a.addvals == b.addvals && a.remvals == b.remvals
Base.:(==)(a::SetDifference, b::SetDifference) =
    a.comvals == b.comvals && a.addvals == b.addvals && a.remvals == b.remvals

# Hash code
Base.hash(a::ArrayDifference, h::UInt) =
    hash(a.modvals, hash(a.addvals, hash(a.remvals, hash(:MatrixDifference, h))))
Base.hash(a::NamedTupleDifference, h::UInt) =
    hash(a.modvals, hash(a.addvals, hash(a.remvals, hash(:NamedTupleDifference, h))))
Base.hash(a::SetDifference, h::UInt) =
    hash(a.comvals, hash(a.addvals, hash(a.remvals, hash(:SetDifference, h))))

"""
    added(a::AbstractDifference)

Access the added elements.
"""
added(a::AbstractDifference) = a.addvals

"""
    removed(a::AbstractDifference)

Access the removed elements.
"""
removed(a::AbstractDifference) = a.remvals

"""
    modified(a::Union{ArrayDifference,NamedTupleDifference})

Access the modified elements.
"""
modified(a::Union{ArrayDifference,NamedTupleDifference}) = a.modvals

"""
    common(a::SetDifference)

Access the common elements.
"""
common(a::SetDifference) = a.comvals