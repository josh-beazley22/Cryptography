
include("toolkit.jl")
using .Toolkit

struct Key
    # Key space restriction: gcd(a, modulus) = 1
    #   now there are only ϕ(modulus) possible values for a
    b:: Vector{Int}
    modulus:: Int
    num_blocks:: Int
end

function generate_keys(num_blocks:: Int, mod:: Int)
    # Generate keys uniform and random

    b = rand(0 : mod-1, num_blocks)
    return Key(b, mod, num_blocks)
end

function encrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # e(x) = x + b (mod m)
    
    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, zeros(extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)

    # Encrypt function
    result = mat .+ keys.b
    result = mod.(vec(result), keys.modulus) 

    # Trim result
    return result[1 : length(message)]
end

function decrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # d(x) = x - b (mod m)

    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, zeros(extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)

    # Decrypt function
    result = mat .- keys.b
    result = mod.(vec(result), keys.modulus) 

    # Trim result
    return result[1 : length(message)]
end

function debug()

    plaintext = "And I ran, I ran so far away
        I just ran, I ran all night and day
        I couldn't get away"
    keys:: Key = generate_keys(8, 444)

    # Encrypt plaintext
    number_text = Toolkit.numerate_text(plaintext, keys.num_blocks)
    ciphertext = encrypt(number_text, keys)
    println(ciphertext)

    # Decrypt ciphertext
    bob_message = decrypt(ciphertext, keys)
    recovered_text = Toolkit.anti_numerate_text(bob_message)
    println(recovered_text)

end

function ciphertext_only_attack(ciphertext:: Vector{Int})

    # TODO: Use hobbit_Ch1.txt to generate an ASCII probability table
    # TODO: Given 1 plaintext-ciphertext pair, solve for the secret key.

    # There are only 128 possible keys. Less. 
    # 128 - (max - min)     possible keys. Exhaustive search.
    # Use nlp library to check if this is English text.
end

function known_text_attack(x:: Matrix{Int}, y:: Matrix{Int}, num_blocks:: Int, modulus:: Int):: Key

    # assert matrix is dimension (any, num_blocks)
end
