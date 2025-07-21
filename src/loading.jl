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

    system = AtomicSystem(Symbol.(atoms))
    geometry = data*units

    if center
        masses = austrip.(atom_masses(system))
        cm = 1/sum(masses) .* sum(geometry .* reshape(masses, 1, :) ; dims = 2)
        geometry .-= cm
    end

    return system, geometry
end