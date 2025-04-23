using AtomicSystems
using PeriodicTable
using Test

function test_show(object)
    io = IOBuffer()
    show(io, object)  # Be sure it does not error here
    @test length(String(take!(io))) != 0  # Test that it prints something
end

@testset "atoms.jl" begin
    @testset "to_element" begin
        C = PeriodicTable.elements[:C]
        @test to_element(:C) === C
        @test to_element("C") === C
        @test to_element("carbon") === C
        @test to_element(6) === C
        @test to_element(C) === C
    end

    @testset "Atom" begin
        H = Atom(:H, 3, "H1")
        test_show(H)
        @test H.element === PeriodicTable.elements[:H]

        # Test atom indexing
        @test (1:5)[H] == 3

        # Test hash and comparison
        H_ = Atom(:H, 3, "H1")
        @test H_ == H
        @test hash(H_) == hash(H)
    end

    @testset "AtomicSystem" begin
        atom_symbols_str = ["C1", "C2", "H", "He"]
        atom_symbols_sym = [:C, :C, :H, :He]
        atom_numbers = [6, 6, 1, 2]

        for atom_symbols in [atom_symbols_str, atom_symbols_sym, atom_numbers]
            atoms = AtomicSystem(atom_symbols)
            test_show(atoms)
            @test length(atoms) == 4
            @test length(atoms[2:end]) == 3
            @test atoms[1].element == PeriodicTable.elements[:C]
            @test atoms[2].index == 2
            @test atoms[atoms[2].name] == atoms[2]
            @test atoms.elements[3] == PeriodicTable.elements[:H]
            @test atoms.masses[3] < atoms.masses[4]
            @test allunique(atoms.names)

            # Test iteration
            list = collect(atoms)
            @test list[1] === atoms[1]
        end

        masses = atom_masses(AtomicSystem([:H, :C, :Pb]))
        @test masses[1] < masses[2] < masses[3]

        # Test hash and comparison
        S1 = AtomicSystem([:H, :C, :O, :C])
        S2 = AtomicSystem([:H, :C, :O, :C])
        @test S1 == S2
        @test hash(S1) == hash(S2)
    end
end