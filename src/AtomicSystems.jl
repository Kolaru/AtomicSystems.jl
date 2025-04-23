module AtomicSystems

using PeriodicTable

export Atom, AtomicSystem
export iselement, to_element, atom_colors, atom_masses
export equivalent_systems

"""
    to_element(identifier::Union{Integer, String, Symbol, PeriodicTable.Element})

Return the PeriodicTable.Element corresponding to the identifier.

Can interpret strings as both an atom name and an atom symbol.
"""
to_element(identifier) = PeriodicTable.elements[identifier]
to_element(element::PeriodicTable.Element) = element

function to_element(str::AbstractString)
    haskey(PeriodicTable.elements, str) && return PeriodicTable.elements[str]
    sym = Symbol(str)
    haskey(PeriodicTable.elements, sym) && return PeriodicTable.elements[sym]
    throw(ArgumentError(
        "string $(str) unknown as either an atom name or an atom symbol."))
end

"""
    Atom

Represent an atom, together with its index in an AtomicSystem a unique name.

Can be used to index any array.
"""
struct Atom
    element::PeriodicTable.Element
    index::Int
    name::String
end

Atom(element::Union{AbstractString, Symbol, Integer}, index, name) = Atom(to_element(element), index, name)

iselement(A::Atom, elem) = (A.element.number == to_element(elem).number)
iselement(elem) = (A -> iselement(A, elem))

function Base.show(io::IO, ::MIME"text/plain", atom::Atom)
    if get(io, :compact, false)
        show(io, atom)
    else
        print(io, "$(atom.name) - $(atom.element.name) atom with index $(atom.index)")
    end
end

# Show method for vectors and arrays
Base.show(io::IO, atom::Atom) = print(io, "$(atom.name) ($(atom.element.name))")

Base.isless(A::Atom, B::Atom) = A.index < B.index

# Allow to index any array with an Atom
function Base.to_indices(A, inds, I::Tuple{Atom, Vararg{Any}})
    return Base.to_indices(A, inds, (I[1].index, Base.tail(I)...))
end

function Base.checkindex(::Type{Bool}, inds::AbstractUnitRange, A::Atom)
    return checkindex(Bool, inds, A.index)
end

function Base.:(==)(A1::Atom, A2::Atom)
    A1.element == A2.element && A1.index == A2.index && A1.name == A2.name
end

Base.hash(A::Atom, h::UInt) = hash([A.element, A.index, A.name], h)

"""
    AtomicSystem

A system of atoms.

Atoms carry with them full information about their element and have a unique
name to make reference to them easier.

Can be index both by atom index and by atom name.
"""
struct AtomicSystem
    atoms::Vector{Atom}
    name_to_index::Dict{String, Int}
end

AtomicSystem(atoms::Vector{Atom}) = AtomicSystem([A.name for A in atoms], [A.element for A in atoms])
function AtomicSystem(system::AtomicSystem, names::Vector{String})
    AtomicSystem(names, [A.element for A in system])
end

function AtomicSystem(names::Vector{String})
    !allunique(names) && error("Some atom names are not unique")
    elements = to_element.(strip.(isdigit, names))
    atoms = Atom.(elements, 1:length(elements), names)
    return AtomicSystem(atoms, Dict([name => i for (i, name) in enumerate(names)]))
end

function AtomicSystem(names::Vector{String}, elements::Vector)
    !allunique(names) && error("Some atom names are not unique")
    atoms = Atom.(elements, 1:length(elements), names)
    return AtomicSystem(atoms, Dict([name => i for (i, name) in enumerate(names)]))
end

function AtomicSystem(element_symbols::Vector ; name_prefix="")
    counters = Dict()
    counts = []

    for sym in element_symbols
        if !haskey(counters, sym)
            counters[sym] = 1
        else
            counters[sym] += 1
        end
        push!(counts, counters[sym])
    end

    names = map(zip(counts, element_symbols)) do (k, sym)
        if counters[sym] == 1
            return "$name_prefix$sym"
        else
            return "$name_prefix$sym$k"
        end
    end

    return AtomicSystem(names, element_symbols)
end

function AtomicSystem(element_numbers::Vector{<:Integer} ; name_prefix="")
    element_symbols = map(element_numbers) do num
        return Symbol(PeriodicTable.elements[num].symbol)
    end
    return AtomicSystem(element_symbols ; name_prefix=name_prefix)
end

function Base.getproperty(system::AtomicSystem, sym::Symbol)
    sym === :elements && return getproperty.(system, :element)
    sym === :masses && return getproperty.(system.elements, :atomic_mass)
    sym === :names && return getproperty.(system, :name)

    # Fallback to getfield
    return getfield(system, sym)
end

# Iterator interface
Base.getindex(system::AtomicSystem, inds...) = getindex(system.atoms, inds...)
Base.lastindex(system::AtomicSystem) = length(system)
Base.length(system::AtomicSystem) = length(system.atoms)
Base.filter(f, system::AtomicSystem) = filter(f, system.atoms)

# Retrieval by name
function Base.getindex(system::AtomicSystem, name::String)
    haskey(system.name_to_index, name) && return system[system.name_to_index[name]]
    # Try without the final 1 or adding a final 1
    if name[end] == '1' && haskey(system.name_to_index, name[1:end-1])
        return system[system.name_to_index[name[1:end-1]]]
    end

    if !(name[end] in '0':'9') && haskey(system.name_to_index, name * "1")
        return system[system.name_to_index[name * "1"]]
    end

    throw(ArgumentError("invalid atom name $name not found in $(keys(system.name_to_index))"))
end

# Retrieval by element
function Base.getindex(system::AtomicSystem, element::Element)
    return [A for A in system if A.element == element]
end

function Base.show(io::IO, ::MIME"text/plain", system::AtomicSystem)
    print(io, "Atomic system with $(length(system)) atoms")
    for atom in system
        println(io)
        print("  ")
        show(io, atom)
    end
end

function Base.iterate(system::AtomicSystem, state=1)
    state > length(system) && return nothing
    return system[state], state + 1
end

function Base.:(==)(sys1::AtomicSystem, sys2::AtomicSystem)
    all(sys1.atoms .== sys2.atoms) && sys1.name_to_index == sys2.name_to_index
end

function Base.hash(system::AtomicSystem, h::UInt)
    hash(system.atoms, hash(system.name_to_index, h))
end

Base.eltype(::AtomicSystem) = Atom

atom_masses(system::AtomicSystem) = [A.element.atomic_mass for A in system]
atom_colors(system::AtomicSystem) = [A.element.cpk_hex for A in system]

"""
    equivalent_system(system::AtomicSystem)

Generate a list of all rearrangement of atoms such that atom at the same index
keep the same element.
"""
function equivalent_systems(system)
    elems = sort(unique(system.elements))
    mapping = Dict(elem => k for (k, elem) in enumerate(elems))
    ks = [mapping[elem] for elem in system.elements]
    elem_counts = counts(ks)

    perms = []
    current = 1
    for count in elem_counts
        push!(perms, permutations(current:(current + count - 1)))
        current += count
    end

    return Iterators.map(Iterators.product(perms...)) do inds
        return reduce(vcat, inds)
    end |> collect |> vec
end

end # module AtomicSystem
