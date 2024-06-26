"""
    AbstractDifference

Supertype for differences.
"""
abstract type AbstractDifference end

"""
    VectorDifference{Tm<:AbstractVector,Ta<:AbstractVector,Tr<:AbstractVector} <: AbstractDifference

Vector difference.
"""
struct VectorDifference{Tm<:AbstractVector,Ta<:AbstractVector,Tr<:AbstractVector} <: AbstractDifference
    modinds::Vector{Int}
    addinds::Vector{Int}
    reminds::Vector{Int}
    modvals::Tm
    addvals::Ta
    remvals::Tr
end

"""
    MatrixDifference{Tm<:AbstractVector,Ta<:AbstractVector,Tr<:AbstractVector} <: AbstractDifference

Matrix difference.
"""
struct MatrixDifference{Tm<:AbstractVector,Ta<:AbstractVector,Tr<:AbstractVector} <: AbstractDifference
    modinds::NTuple{2,Vector{Int}}
    addinds::NTuple{2,Vector{Int}}
    reminds::NTuple{2,Vector{Int}}
    modvals::Tm
    addvals::Ta
    remvals::Tr
end

"""
    DictDifference{Tm<:AbstractDict,Ta<:AbstractDict,Tr<:AbstractDict} <: AbstractDifference

Dictionary difference.
"""
struct DictDifference{Tm<:AbstractDict,Ta<:AbstractDict,Tr<:AbstractDict} <: AbstractDifference
    modvals::Tm
    addvals::Ta
    remvals::Tr
end

"""
    NamedTupleDifference{Tm<:NamedTuple,Ta<:NamedTuple,Tr<:NamedTuple} <: AbstractDifference

Named tuple difference.
"""
struct NamedTupleDifference{Tm<:NamedTuple,Ta<:NamedTuple,Tr<:NamedTuple} <: AbstractDifference
    modvals::Tm
    addvals::Ta
    remvals::Tr
end

"""
    SetDifference{Ta,Tr} <: AbstractDifference

Set difference.
"""
struct SetDifference{Ta,Tr} <: AbstractDifference
    addvals::Set{Ta}
    remvals::Set{Tr}
end

# Equality operator
function Base.:(==)(a::Ta, b::Tb) where {Ta<:AbstractDifference,Tb<:AbstractDifference}
    a === b && return true
    nameof(Ta) == nameof(Tb) || return false
    fields = fieldnames(Ta)
    fields === fieldnames(Tb) || return false
    for f in fields
        getfield(a, f) == getfield(b, f) || return false
    end
    return true
end

# Hash code
function Base.hash(a::T, h::UInt) where {T<:AbstractDifference}
    hashval = hash(:T, h)
    for f in fieldnames(T)
        hashval = hash(getfield(a, f), hashval)
    end
    return hashval
end

"""
    added_indices(a::Union{VectorDifference,MatrixDifference})

Access the added indices.
"""
added_indices(a::Union{VectorDifference,MatrixDifference}) = a.addinds

"""
    removed_indices(a::Union{VectorDifference,MatrixDifference})

Access the removed indices.
"""
removed_indices(a::Union{VectorDifference,MatrixDifference}) = a.reminds

"""
    modified_indices(a::Union{VectorDifference,MatrixDifference})

Access the modified indices.
"""
modified_indices(a::Union{VectorDifference,MatrixDifference}) = a.modinds

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
    modified(a::Union{VectorDifference,MatrixDifference,DictDifference,NamedTupleDifference})

Access the modified elements.
"""
modified(a::Union{VectorDifference,MatrixDifference,DictDifference,NamedTupleDifference}) = a.modvals
