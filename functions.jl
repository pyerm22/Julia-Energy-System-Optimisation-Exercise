using Random, Distributions

function availability_factor(
    failure_rate::Real,
    repair_rate::Real,
    nT::Integer,
    n::Integer,
    twist_add::Integer,
)
    rng = MersenneTwister(n + twist_add)
    x = fill(NaN, nT)
    current_state = rand(
        rng, Binomial(1, failure_rate / (failure_rate + repair_rate))
    )
    t = 1
    for i in 1:nT
        t > nT && break

        # Calculate state duration
        rate = (current_state == true ? repair_rate : failure_rate)
        state_duration = Int(round(-1 / rate * log(rand(rng))))

        # Apply it
        t_next = t + state_duration
        t_next > nT && (t_next = nT)
        next_state = (current_state == true ? false : true)
        x[t:t_next] .= next_state

        # For next loop
        t = t_next + 1
        current_state = next_state
    end
    return x
end

function availability_factor(n::Integer)
    G = ["1", "2"]
    nT = 24
    failure_rate = Dict(zip(G, [0.008, 0.035]))
    repair_rate = Dict(zip(G, [0.01, 0.05]))
    return Dict(
        G[i] => availability_factor(
            failure_rate[G[i]], repair_rate[G[i]], nT, n, i
        ) for i in 1:length(G)
    )
end
