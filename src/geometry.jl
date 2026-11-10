function center_of_mass(system::AtomicSystem, positions::Matrix)
    masses = atomic_mass.(system)
    return dropdims(sum(positions .* reshape(masses, 1, :) ; dims = 2) ; dims = 2) ./ sum(masses)
end