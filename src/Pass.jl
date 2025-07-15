module Pass

export PASS

struct PassStore end

function Base.getindex(::PassStore, key::String)
    error_buffer = IOBuffer()
    try
        return readchomp(pipeline(`pass $key`, stderr=error_buffer))
    catch e
        if e isa ProcessFailedException
            throw(KeyError(key))
        else
            rethrow(e)
        end
    end
end

function Base.get(pass::PassStore, key::String, default)
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
