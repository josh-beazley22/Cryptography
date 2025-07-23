
include("toolkit.jl")
using .Toolkit

struct Key
    # Matrix size = (num_blocks, num_blocks) and contains Integers modulo m
    # A key has an inverse iff gcd(det(key), modulus) = 1

    key:: Matrix{Int}
    key_inv:: Matrix{Int}
    modulus:: Int
    num_blocks:: Int
end

function generate_keys(num_blocks:: Int, mod:: Int)

    # Generate a keys restricted by gcd(a, m) = 1

    mat = rand(0 : mod-1, num_blocks*num_blocks)
    mat = reshape(mat, (num_blocks, num_blocks))

    # TODO: invert matrix
    return Key(mat, mod, num_blocks)
end

function encrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # e(x) = a*x + b (mod m)
    
    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, zeros(extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)
    println(size(mat))

    # Encrypt function
    result = keys.matrix * mat
    result = mod.(result, keys.modulus) 
    println(size(mat))

    # Trim result
    return result[1 : length(message)]
end

function decrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # d(x) = a_inv * (x - b) (mod m)

    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, zeros(extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)

    # Decrypt function
    result = (mat .- keys.b) .* keys.a_inv
    result = mod.(vec(result), keys.modulus) 

    # Trim result
    return result[1 : length(message)]
end

function debug()

    plaintext = "And I ran, I ran so far away
        I just ran, I ran all night and day
        I couldn't get away"
    keys:: Key = generate_keys(8, 128)

    number_text = Toolkit.numerate_text(plaintext, keys.num_blocks)
    println(number_text)

    ciphertext = encrypt(number_text, keys)

    bob_message = decrypt(ciphertext, keys)
    println(bob_message)

    recovered_text = Toolkit.anti_numerate_text(bob_message)
    println(recovered_text)

end