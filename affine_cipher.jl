
include("toolkit.jl")
using .Toolkit

struct Key
    # Key space restriction: gcd(a, modulus) = 1
    #   now there are only ϕ(modulus) possible values for a (Euler phi function)
    a:: Vector{Int}
    a_inv:: Vector{Int}
    b:: Vector{Int}
    modulus:: Int
    num_blocks:: Int
end

function generate_keys(num_blocks:: Int, mod:: Int)

    # Generate a keys restricted by gcd(a, mod) = 1
    a_keys = Int[]
    inverses = Int[]
    for _ in 1:num_blocks
        # builds one at a time. 
        # more efficient to vectorize n, accept/reject by in batches.
        while true
            a = rand(0: mod-1)
            accept, a_inv = Toolkit.mod_inverse(a, mod)
            if accept
                push!(a_keys, a)
                push!(inverses, a_inv)
                break
            end
        end
    end

    b = rand(0 : mod-1, num_blocks)
    return Key(a_keys, inverses, b, mod, num_blocks)
end

function encrypt(message:: Vector{Int}, keys:: Key):: Vector{Int}
    # e(x) = a*x + b (mod m)
    
    # Append message by 0 so that its length is divisible by block size
    extra_length = (keys.num_blocks - length(message) % keys.num_blocks) % keys.num_blocks
    mat = vcat(message, zeros(extra_length)) # Append zero
    mat = reshape(mat, keys.num_blocks, :) 

    # Encrypt function
    result = mat .* keys.a .+ keys.b
    result = mod.(vec(result), keys.modulus) 

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
    keys:: Key = generate_keys(8, 444)

    # Encrypt plaintext
    number_text = Toolkit.numerate_text(plaintext, keys.num_blocks)
    ciphertext = encrypt(number_text, keys)
    println(ciphertext)

    # Decrypt ciphertext
    bob_message = decrypt(ciphertext, keys)
    recovered_text = Toolkit.anti_numerate_text(bob_message)
    println(recovered_text)


    # Algorithm to build plaintext-ciphertext pairs.
    # I need 2*num_blocks pairs of text to crack the Affine cipher.
    # HOWEVER, these must be special pairs (x is plaintext, y is ciphertext): 
            # - gcd(x2 - x1, modulus) = 1
            # - gcd(y2 - y1, modulus) = 1
    coprime = Toolkit.find_coprimes(keys.modulus)
    i = 0
    keep = repeat([false], keys.num_blocks)
    sto_x1 = repeat([0], keys.num_blocks)
    sto_x2 = repeat([0], keys.num_blocks)
    sto_y1 = repeat([0], keys.num_blocks)
    sto_y2 = repeat([0], keys.num_blocks)

    while any(.!keep)
        i += 1
        # Generate ciphertext from plaintext subject to constraint: gcd(x2-x1, modulus) = 1
        x1 = repeat([1], keys.num_blocks)
        x2 = (x1 .+ coprime[i]) .% keys.modulus
        y1 = encrypt(x1, keys)
        y2 = encrypt(x2, keys)
        # Keep data where y2-y1 is coprime to the modulus
        gcd = Toolkit.greatest_common_divisor(y2 .- y1, keys.modulus)
        mask = (gcd .== 1) .& .!keep
        # Update storage
        keep[mask] .= true
        sto_x1[mask] = x1[mask]
        sto_x2[mask] = x2[mask]
        sto_y1[mask] = y1[mask]
        sto_y2[mask] = y2[mask]
    end
    
    println("CRACK CIPHER")
    crack_cipher_minimal(vcat(sto_x1', sto_x2'), vcat(sto_y1', sto_y2'), keys.num_blocks, keys.modulus)

    println("REAL KEYS")
    println(keys)

end

function crack_cipher_minimal(x:: Matrix{Int}, y:: Matrix{Int}, num_blocks:: Int, modulus:: Int):: Key
    """
    Crack the Affine cipher with minimal information
    1. num_blocks and modulus are required from the get-go.
    2. x & y are plaintext and ciphertext pairs.
       I need 2*num_blocks amount of text subject to the constraint that
       the difference between the two rows is coprime to the modulus
            - gcd(x2 - x1, modulus) = 1
            - gcd(y2 - y1, modulus) = 1
    """

    ### Mathematics of cipher breaking ###
    # a*x1 + b = y1 (mod m)
    # a*x2 + b = y2 (mod m)
    ### Solve with subtraction ###
    # a*(x2 - x1) = y2 - y1         (mod m)
    # a = (y2 - y1) * (x2 - x1)^-1  (mod m)
    ### Substitute and solve for b ###
    # b = y1 - a*x1 (mod m)

    x_sub:: Vector{Int} = (x[2,:] .- x[1,:]) .% modulus
    y_sub:: Vector{Int} = (y[2,:] .- y[1,:]) .% modulus
    x_sub_inv = Toolkit.mod_inverse(x_sub, modulus)[2]

    a = y_sub .* x_sub_inv
    a = Toolkit.positive_mod.(a, modulus)
    a_inv = Toolkit.mod_inverse(a, modulus)[2]

    b = (y[1,:] - a .* x[1,:])
    b = Toolkit.positive_mod.(b, modulus)

    return Key(a, a_inv, b, num_blocks, modulus)
end


function crack_cipher_backdoor(num_blocks:: Int, modulus:: Int):: Key
    """
    Crack the cipher when I have a lot of text that is not guarenteed to have the special property:
        - gcd(x2 - x1, modulus) = 1
        - gcd(y2 - y1, modulus) = 1
    
    This approach assumes I have tempory encrpytion privlages. I may create encrypted text from any
    plaintext of my choosing. 
    """

end

function crack_cipher(num_blocks:: Int, modulus:: Int):: Key
    """
    This approach reduces my knowledge to a large block of encrypted text without access to the plaintext.
    """
end
