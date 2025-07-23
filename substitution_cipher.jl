
include("toolkit.jl")
using .Toolkit
using Random

struct Key
    perm:: Matrix{Int}
    perm_inv:: Matrix{Int}
    # Modulus must be at least the range of the text numeration algorithm.
    # Larger modulus just means a sample of range from 1:mod
    modulus:: Int
    num_blocks:: Int
end

function generate_keys(num_blocks:: Int, mod:: Int) 
    # TODO: storage datatypes must be fixed!
    # Matrix has shape (num_blocks, mod)
    perm_storage = []
    perm_inv_storage = []

    # Generate num_blocks many random permutations.
    for _ in 1:num_blocks
        perm = randperm(mod)
        push!(perm_storage, perm)

        # Find the inverse of the permutation
        perm_inv = zeros(mod)
        for i in 1:mod
            perm_inv[perm[i]] = i
        end
        push!(perm_inv_storage, perm_inv)
    end
    # splat the vectors as columns into a matrix of shape (num_blocks, mod)
    perm_mat = hcat(perm_storage...)'
    perm_inv_mat = hcat(perm_inv_storage...)'

    return Key(perm_mat, perm_inv_mat, mod, num_blocks)
end

function encrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # Append message by 0 so that its length is divisible by block size
    # Reshape message into a matrix of size (num_blocks, :)
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, ones(Int64, extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)

    # Encrypt function
    result = similar(mat, Int64)
    for i in 1:keys.num_blocks
        substitution = keys.perm[i, :]
        index = mat[i,:]
        result[i,:] = substitution[index]
    end

    # Trim result
    return vec(result)[1 : length(message)]
end

function decrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, ones(Int64, extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :)

    # Decrypt function
    result = similar(mat, Int64)
    for i in 1:keys.num_blocks
        substitution = keys.perm_inv[i, :]
        index = mat[i,:]
        result[i,:] = substitution[index]
    end

    # Trim result
    return vec(result)[1 : length(message)]
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