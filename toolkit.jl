
module Toolkit
using BitIntegers

function euclid_algorithm(a:: Int, b:: Int)
    """
    Extended Euclidean Algorithm
    Returns (gcd, x, y) such that a*x + b*y = gcd
    """
    # Written by ChatGPT
    if a == 0
        return (b, 0, 1)
    else
        gcd, x1, y1 = euclid_algorithm(b % a, a)
        x = y1 - div(b, a) * x1
        y = x1
        return (gcd, x, y)
    end
end

function greatest_common_divisor(a:: Vector{Int}, b:: Int)
    """
    Returns the greatest common divisor of a & b
    """
    result = []
    for val in a
        gcd, x, y = euclid_algorithm(val, b)
        push!(result, gcd)
    end
    return result
end

function find_coprimes(mod:: Int)
    """
    Returns all numbers coprime to mod from 1:mod-1
    """
    domain = collect(1:mod-1)
    gcd = greatest_common_divisor(domain, mod)
    return domain[gcd .== 1]
end

function positive_mod(a:: Int, mod:: Int)
    result = a % mod
    if result < 0
        result += mod
    end
    return result
end

function mod_inverse(a:: Vector{Int}, m:: Int)
    """
    Finds the modular multiplicative inverse of a under modulo m
    Will return a boolean vector for each input evaluating gcd(a, m) ≠ 1
    Returns a vector x across all a such that (a * x) % m == 1
    """
    all_invertable = true
    result = Int[]
    for value in a
        can_inv, inv = mod_inverse(value, m)
        if can_inv
            push!(result, inv)
        else
            all_invertable = false
            push!(result, 0)
        end
    end
    return all_invertable, result
end

function mod_inverse(a:: Int, m:: Int)
    """
    Finds the modular multiplicative inverse of a under modulo m
    Will return false if gcd(a, m) ≠ 1
    Returns x such that (a * x) % m == 1
    """
    gcd, x, y = euclid_algorithm(a, m)

    if gcd != 1
        return false, 0
    else
        # ensures the result of x%m is always positive
        return true, (x % m + m) % m
    end
end

function factors(n:: Int)
    # Factors come in pairs, so only iterate up to sqrt(n)
    # Written by ChatGPT
    result = Int[]
    for d in 1:isqrt(n)
        if n % d == 0
            push!(result, d)
            if d != n ÷ d  # Avoid duplicate for perfect squares
                push!(result, n ÷ d)
            end
        end
    end
    return sort(result)  # Ensure the factors are in order
end

function primes(n:: Int)
    # Compute the first n primes
    primes = Int[2]
    i = 3
    while length(primes) < n
        if all(i .% primes .!= 0)
            # i is a prime number
            push!(primes, i)
        end
        i += 1
    end
    return primes
end

function prime_factors(n:: Int)
    # Compute the prime factors of n

    # 1. find primes < sqrt(n)
    # 2. perform successive divisions to find prime factor coeffs

    factorization = zeros(isqrt(n))
    primes = prime_finder(isqrt(n))
    for (i, prime) in enumerate(primes)
        while n % prime == 0
            factorization[i] += 1
            n = n / prime
        end
        # End the loop early when n is smaller than the current prime
        if n < prime
            break
        end
    end
    return hcat(primes, factorization)
end

function euler_phi_function(prime_list:: Vector{Int})
    # TODO: this is sus. where does the primes variable come from?
    @assert length(primes) >= length(prime_list) "Not enough stored primes to calculate ϕ(m) the Euler Phi Function"
    return prod(primes .^ (prime_list .- 1))
end

function numerate_text(text:: String, num_blocks:: Int):: Vector{Int}
    # Use ASCII 128 (7 bit) binary encoding of plaintext
    # Each Int represents exactly one numerated character

    return Int.(collect(text))
end

function anti_numerate_text(text:: Vector{Int}):: String
    # Use ASCII 128 (7 bit) binary encoding of plaintext
    # Each Int represents exactly one numerated character

    return join(Char.(text))
end

function serialize_text(text:: String):: Vector{UInt64}
    # Use ASCII 128 (7 bit) binary encoding of plaintext
    # Each UInt64 represents 9 characters encoded in ASCII
    # Leading bit is always 0

    serial = Int.(collect(text))

    # Append zeros to make the length a multiple of 9
    pad_length = (9 - length(serial) % 9) % 9
    serial = vcat(serial, zeros(Int, pad_length))

    # Reshape into a 9-row matrix
    serial_matrix = reshape(serial, :, 9)

    # Apply bit shifts to columns
    shifts = collect(0:7:56)'
    shifted_matrix = UInt64.(serial_matrix) .<< shifts

    # Sum across columns
    encoded_vector = vec(sum(shifted_matrix, dims=2)) 

    return encoded_vector
end

function anti_serialize_text(encode:: Vector{UInt64}):: String

    # Load appropriate binaries to extract the ASCII characters
    anti_shifts = fill(UInt64(0x7F), 9)
    shifts = collect(0:7:56)
    anti_shifts .<<= shifts

    # Extract the characters
    extracted_chars = encode .& anti_shifts'
    # Reverse the bit-shift operations
    encoded_chars = extracted_chars .>> shifts'

    # Call ASCII encoding dictionary
    c = Char.(encoded_chars')
    # Return as a String
    return join(c)
end

function print_hex(x:: Vector{<:Integer})
    println(string(x, base=16))
end
function print_binary(x:: Vector{<:Integer})
    println(bitstring(x))
end

end # module