const INTEGER = r"^\d+$"
function parse_atom(atom::String)
    haskey(elements, atom) && return elements[atom]
    !isnothing(match(INTEGER, atom)) && return elements[parse(Int, atom)]
    haskey(elements, Symbol(atom)) && return elements[Symbol(atom)]

    throw(ArgumentError("could not parse  $atom  as an atom (supported are Z, atom name and atom symbol)"))
end

"""
    read(filename::AbstractString, ::Type{AtomicSystem} ; units = u"Å", center = true)

Read an XYZ file and return the corresponding AtomicSystem and the geometry (as a (3, natoms) array).

If `center` is true, the geometry is shifted so that its center of mass is at (0, 0, 0).
"""
function Base.read(filename::AbstractString, ::Type{AtomicSystem} ; units = u"Å", center = true)
    lines = readlines(filename)[3:end]
    filter!(!isempty, lines)
    natoms = length(lines)
    atoms = fill("", natoms)
    data = zeros(3, natoms)

    for (k, line) in enumerate(lines)
        atoms[k], xyz... = split(line)
        data[:, k] = parse.(Float64, xyz)
    end

    system = AtomicSystem(parse_atom.(atoms))
    geometry = data*units

    if center
        masses = austrip.(atom_masses(system))
        cm = 1/sum(masses) .* sum(geometry .* reshape(masses, 1, :) ; dims = 2)
        geometry .-= cm
    end

    return system, geometry
end

function Base.write(io::IO, system::AtomicSystem, geometry::AbstractMatrix)
    geometry = ustrip.(u"Å", geometry)
    println(io, length(system))
    println(io, "File generated using Kolaru/AtomicSystem.jl")
    for A in system
        x, y, z = geometry[:, A]
        println(io, @sprintf("  %3s %20.10f %20.10f %20.10f", A.element.symbol, x, y, z))
    end
end

function Base.write(filename::AbstractString, system::AtomicSystem, geometry::AbstractMatrix, mode = "w")
    open(filename, mode) do file
        write(file, system, geometry)
    end
end