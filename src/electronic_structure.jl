# TODO Remove once PR is merged: https://github.com/JuliaAtoms/AtomicLevels.jl/pull/128
function AtomicLevels.Configuration(element::Element)
    return parse(Configuration{Orbital}, element.el_config)
end

# TODO PR This type pirated greatness to AtomicLevels.jl
function Base.getindex(configuration::Configuration, orbital::Orbital)
    i = findfirst(==(orbital), orbitals(configuration))
    isnothing(i) && return (0, :open)
    return (configuration.occupancy[i], configuration.states[i])
end

# TODO PR This ?
function Base.:(+)(configuration::Configuration, orbital::Orbital)
    return configuration + Configuration(orbital, 1)
end

function Base.isfull(configuration::Configuration, orbital::Orbital)
    return num_electrons(configuration, orbital) == degeneracy(orbital)
end

abstract type ElectronicTransition end

struct Photoionization <: ElectronicTransition
    atom::Element
    cross_section::Float64
    emitted_electron_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

function Base.show(io::IO, ph::Photoionization)
    print(io, """
    Photoionization
      cross section: $(ph.cross_section) a.u.
      photoelectron energy: $(ph.emitted_electron_energy) a.u.
      initial configuration: $(ph.initial_configuration)
      final configuration: $(ph.final_configuration)
    """)
end

cross_section(ph::Photoionization) = ph.cross_section

struct AugerDecay <: ElectronicTransition
    atom::Element
    rate::Float64
    emitted_electron_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

struct FluorescenceDecay <: ElectronicTransition
    atom::Element
    rate::Float64
    emitted_photon_energy::Float64
    initial_configuration::Configuration
    final_configuration::Configuration
end

rate(decay::Union{AugerDecay, FluorescenceDecay}) = decay.rate

isa_photoionization(event::ElectronicTransition) = false
isa_photoionization(event::Photoionization) = true

isa_auger_decay(event::ElectronicTransition) = false
isa_auger_decay(event::AugerDecay) = true

isa_fluorescence(event::ElectronicTransition) = false
isa_fluorescence(event::FluorescenceDecay) = true

"""
    ejected_orbital(transition::Photoionization)

Return the orbital from which an electron was ejected by the photoionization.
"""
function ejected_orbital(transition::Photoionization)
    for (orbital, n_initial, _) in transition.initial_configuration
        n_final, _ = transition.final_configuration[orbital]
        n_final == n_initial - 1 && return orbital
    end

    throw(ArgumentError("could not find an orbital losing an electron in the transition $transition"))
end

"""
    ejected_orbital(transition::AugerDecay)

Return the orbital from which an electron was ejected by the Auger decay.

In Auger decays, one electron decay and one is ejected.
Which is which is undistinguishable, so by convention we considered that the least bound
gets ejected.
"""
function ejected_orbital(transition::AugerDecay)
    orbital = nothing

    for (orb, n_initial, _) in transition.initial_configuration
        n_final, _ = transition.final_configuration[orb]
        if n_final < n_initial
"""
    calculate_decays(backend::ElectronicStructureBackend, atom, [configuration::Configuration])

Use the given backend to calculate the possible electronic transition for an atom in a given configuration.

Return a list of `ElectronicTransition`.
"""
            orbital = orb
        end
    end

    !isnothing(orbital) && return orbital

    throw(ArgumentError("could not find an orbital losing an electron in the transition $transition"))
end

"""
    abstract type ElectronicStructureBackend end

Supertype for the backend computing the electronic structures required by the problem.

Must implement `calculate_photoionization`, `calculate_decays` and `calculate_orbital_energies`.
"""
abstract type ElectronicStructureBackend end

"""
    calculate_photoionizations(xatom::ElectronicStructureBackend, photon_energy::Quantity, atom::Element [, configuration::Configuration])

Use the given backend to calculate the possible electronic transition for an atom in a given configuration.

Return a list of `Photoionization`.
"""
function calculate_photoionizations end

function calculate_photoionizations(backend, photon_energy, atom::Atom, configuration::Configuration)
    return calculate_photoionizations(backend, photon_energy, atom.element, configuration)
end


"""
    calculate_auger_decays(backend::ElectronicStructureBackend, atom, [configuration::Configuration])

Use the given backend to calculate the possible Auger decays for an atom in a given configuration.

Return a list of `AugerDecay`.
"""
function calculate_auger_decays end

function calculate_auger_decays(backend, atom::Atom, configuration::Configuration)
    return calculate_auger_decays(backend, atom.element, configuration)
end

"""
    calculate_fluorescence_decays(backend::ElectronicStructureBackend, atom, [configuration::Configuration])

Use the given backend to calculate the possible fluorescence decays for an atom in a given configuration.

Return a list of `FluorescenceDecay`.
"""
function calculate_fluorescence_decays end

function calculate_fluorescence_decays(backend, atom::Atom, configuration::Configuration)
    return calculate_fluorescence_decays(backend, atom.element, configuration)
end

"""
    calculate_orbital_energies(backend::ElectronicStructureBackend, atom::Element [, configuration::Configuration])

Use the given backend to calculate the the orbital energies of an atom in a given configuration.

Return a dictionnary `Orbital => energy`, with the energy of each orbital in atomic units.

TODO Relax the unit requirement, and allow unitful quantities
"""
function calculate_orbital_energies end

function calculate_orbital_energies(backend, atom::Atom, configuration::Configuration)
    return calculate_orbital_energies(backend, atom.element, configuration)
end

"""
    calculate_decays(backend::ElectronicStructureBackend, atom, [configuration::Configuration])

Use the given backend to calculate the possible electronic transition for an atom in a given configuration.

Return a list of `ElectronicTransition`.
"""
function calculate_decays(backend, atom, configuration::Configuration)
    return vcat(
        calculate_auger_decays(backend, atom, configuration),
        calculate_fluorescence_decays(backend, atom, configuration)
    )
end

"""
    highest_occupied_orbital(backend, atom::Element, configuration::Configuration)

Return the occupied orbital with the highest energy.
"""
function highest_occupied_orbital(backend, atom, configuration)
    isempty(configuration) && return nothing
    energies = calculate_orbital_energies(backend, atom, configuration)
    filter!(energies) do (orb, energy)
        configuration[orb][1] > 0
    end
    return argmax(energies)  # Return the key, which is an orbital
end

# TODO Doc the following
function total_orbital_energy(backend, atom, configuration)
    energies = calculate_orbital_energies(backend, atom, configuration)
    return sum(configuration ; init = 0.0) do (orb, n, state)
        return n * energies[orb]
    end
end

function binding_energy(backend, atom, configuration, orbital)
    !(orbital in configuration) && throw(ArgumentError(
        "trying to compute the binding energy of orbital $orbital " *
        "not present in configuration $configuration"))

    energy_before = total_orbital_energy(backend, atom, configuration)
    energy_after = total_orbital_energy(backend, atom, configuration - orbital) 
    return energy_before - energy_after
end

function closest_orbitals(backend, atom, configuration, target_energy)
    energies = calculate_orbital_energies(backend, atom, configuration)
    orbitals = collect(keys(energies))

    return sort(orbitals, by = (orbital -> abs(energies[orbital] - target_energy)))
end