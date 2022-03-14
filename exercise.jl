using Pkg
Pkg.activate(@__DIR__)
Pkg.instantiate()
using JuMP, HiGHS, Suppressor

# This script runs an economic dispatch model to determine the expected energy
# not served of a fictitious power system. Or at least it should - you need 
# to fill in the gaps in order for it to work. Those gaps are:
# - the optimisation problem formulation (1 constraint is missing)
# - calculating the expected energy not served
# In addition this is a test of your general coding abilities (e.g. to setup Julia, use Git).

include(joinpath(@__DIR__, "functions.jl"))
mean(vcat(values(availability_factor(1))...))

function run_economic_dispatch(n=1)
    # Define input data
    G = ["1", "2"]
    T = 1:24
    c = Dict(zip(G, [60, 100])) # euros/MWh
    cap = Dict(zip(G, [400, 200])) # MW
    VOLL = 1_000
    D = [
        9232,
        8747,
        8393,
        8173,
        8077,
        8307,
        8695,
        9073,
        9481,
        9688,
        9985,
        9854,
        9717,
        9567,
        9572,
        9621,
        10248,
        10603,
        10573,
        10228,
        9742,
        10058,
        10211,
        9711,
    ] ./ 25
    AF = availability_factor(n)

    # Write down optimisation problem
    m = Model(HiGHS.Optimizer)
    q = @variable(m, [g = G, t = T], lower_bound = 0, base_name = "q")
    ls = @variable(m, [t = T], lower_bound = 0, base_name = "ls")

    @objective(
        m,
        Min,
        sum(c[g] * q[g, t] for g in G, t in T) + sum(ls[t] * VOLL for t in T)
    )

    @constraint(m, [g = G, t = T], sum(q[g, t]) <= AF[g][t] * cap[g])

    @suppress optimize!(m)

    lsvals = value.(ls)
    ENS = NaN
    return ENS
end

function run_economic_dispatches(n_samples=1)
    ENS_vec = Float64[]
    for i in 1:n_samples
        push!(ENS_vec, run_economic_dispatch(i))
    end
    EENS = NaN
    return EENS
end

println(run_economic_dispatches(10))

# Bonus points: parallelise this using the Distributed package and `pmap`.
