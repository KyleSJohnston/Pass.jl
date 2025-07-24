using Test
using Pass

function tempgpg(f)
    gpgdir = mktempdir()
    return withenv(f, "GNUPGHOME" => gpgdir)
end

configpath() = joinpath(dirname(@__FILE__), "gpgconfig.txt")

function create_gpgkey()
    config = configpath()
    # Generate the key
    run(`gpg --batch --generate-key $config`)

    output = IOBuffer(read(`gpg --list-secret-keys --keyid-format LONG`, String))
    # Parse the output to find the key ID
    key_id = extract_key_id(output)

    return key_id
end

function extract_key_id(gpg_output)
    for line in eachline(gpg_output)
        if startswith(line, "ssb")
            parts = split(line)
            for part in parts
                if occursin('/', part)
                    return split(part, '/')[2]
                end
            end
        end
    end
    error("No key id!")
end

@testset "Make a key" begin
    tempgpg() do
        key = create_gpgkey()
        println("using $key for gpg")
        passdir = mktempdir()
        store = PassStore(passdir)
        Pass.init(store, key)
        @test isnothing(get(store, "foo", nothing))
    end
end