function center_of_mass(system::AtomicSystem, positions::Matrix)
    masses = atom_masses(system)
    return dropdims(sum(positions .* reshape(masses, 1, :) ; dims = 2) ; dims = 2) ./ sum(masses)
end