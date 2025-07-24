module Pass

using Logging

export PASS, PassStore
public init

struct PassStore
    dir::Union{String,Nothing}

    function PassStore(dir=nothing)
        if isnothing(dir)
            return new(nothing)
        else
            if !isdir(dir)
                throw(ArgumentError("$dir is not a directory"))
            end
            return new(String(dir))
        end
    end
end


function init(pass::PassStore, gpgid::AbstractString)
    cmd = pipeline(addenv(`pass init $gpgid`, "PASSWORD_STORE_DIR" => pass.dir), stderr=IOBuffer())
    result = readchomp(cmd)
    @info result
    return
end


# function insert(pass::PassStore, key::AbstractString, value::AbstractString)
#     cmd = pipeline(addenv(`pass insert $key`, "PASSWORD_STORE_DIR" => pass.dir), stderr=IOBuffer())
#     result = readchomp(cmd)
#     @info result
#     return
# end


function Base.getindex(pass::PassStore, key::AbstractString)
    cmd = pipeline(addenv(`pass show $key`, "PASSWORD_STORE_DIR" => pass.dir), stderr=IOBuffer())
    try
        return readchomp(cmd)
    catch e
        if e isa ProcessFailedException
            throw(KeyError(key))
        else
            rethrow(e)
        end
    end
end

function Base.get(pass::PassStore, key::AbstractString, default)
    try
        return getindex(pass, key)
    catch e
        if e isa KeyError
            return default
        else
            rethrow(e)
        end
    end
end

"""
    PASS

A global instance of `PassStore` that provides dictionary-like access to the system's `pass` password store.

# Examples

```julia
# Retrieve a password (throws KeyError if not found)
password = PASS["my-service/username"]

# Retrieve a password with default fallback
password = get(PASS, "my-service/username", "default-password")

# Check if a password exists
if haskey(PASS, "my-service/username")
    password = PASS["my-service/username"]
end
```

# Methods
- `PASS[key]`: Retrieve password for the given key
- `get(PASS, key, default)`: Retrieve password or return default if not found

# Throws
- `KeyError`: When the requested password entry does not exist in the password store
"""
const PASS = PassStore()

end # module Pass
