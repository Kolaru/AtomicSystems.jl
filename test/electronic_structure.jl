@testset "Photoionization" begin
    ph = Photoionization(
        elements[:C],
        0.1,
        12.3,
        c"1s2 2s2 2p2",
        c"1s1 2s2 2p2"
    )

    @test isa_photoionization(ph)
    @test !isa_auger_decay(ph)
    @test !isa_fluorescence(ph)

    @test ejected_orbital(ph) == o"1s"
end

@testset "Auger decay" begin
    au = AugerDecay(
        elements[:C],
        1.2,
        0.98,
        c"1s1 2s2 2p2",
        c"1s2 2s1 2p1"
    )

    @test !isa_photoionization(au)
    @test isa_auger_decay(au)
    @test !isa_fluorescence(au)

    @test ejected_orbital(au) == o"2p"

    au = AugerDecay(
        elements[:C],
        1.2,
        0.98,
        c"1s1 2s2 2p2",
        c"1s2 2s2"
    )

    @test ejected_orbital(au) == o"2p"
end

struct DummyBackend <: ElectronicStructureBackend
    photoionzations::Vector    
    decays::Vector
    energies::Dict
end

function AtomicSystems.calculate_orbital_energies(backend::DummyBackend, ::Element, ::Configuration, active_space = nothing)
    return backend.energies
end

function AtomicSystems.calculate_total_energy(backend::DummyBackend, ::Element, config::Configuration)
    return sum(config) do (orbital, n, state)
        return n * backend.energies[orbital]
    end
end

@testset "Interface" begin
    backend = DummyBackend(
        [],
        [],
        Dict(
            o"1s" => -100.0,
            o"2s" => -60.0,
            o"2p" => -50.0,
            o"3s" => -20.0
        )
    ) 

    config = Configuration(
        collect(keys(backend.energies)),
        ones(Int, length(backend.energies))
    )
    elem = elements[:Na]

    @test total_orbital_energy(backend, elem, config) == -230
    @test binding_energy(backend, elem, config, o"1s") == -100
    @test highest_occupied_orbital(backend, elem, config) == o"3s"
    @test first(closest_orbitals(backend, elem, config, -51.0)) == o"2p"
end