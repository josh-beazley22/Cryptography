
function monograms(text:: Vector{Int}):: Dict{Tuple, Int}

    storage = Dict()
    for i in 1:length(text)

        letter = tuple(text[i])
        if haskey(storage, letter)
            storage[letter] += 1
        else
            storage[letter] = 1
        end
    end
    return storage
end

function bigrams(text:: Vector{Int}):: Dict{Tuple, Int}

    storage = Dict()
    for i in 1:length(text)-1

        letter = tuple(text[i], text[i+1])
        if haskey(storage, letter)
            storage[letter] += 1
        else
            storage[letter] = 1
        end
    end
    return storage
end

function trigrams(text:: Vector{Int}):: Dict{Tuple, Int}

    storage = Dict()
    for i in 1:length(text)-2

        letter = tuple(text[i], text[i+1], text[i+2])
        if haskey(storage, letter)
            storage[letter] += 1
        else
            storage[letter] = 1
        end
    end
    return storage
end

function analyze_text(filename:: String)

    filename = "books/hobbit_Ch1.txt"
    text = read(filename, String)
    text = Int.(collect(text)) # convert to ASCII encoding of Int64
    println(typeof(text))

    @time mono = monograms(text)
    @time bi = bigrams(text)
    @time tri = trigrams(text)

    println(collect(keys(mono)))
end

# Break ciphers by guessing intelligently using the entire Hobbit text. 
# Bigram and Trigram guessing.