module Pass

using Logging

export PASS, PassStore

struct PassStore
    dir::Union{String,Nothing}

    function PassStore(dir=nothing)
        # Validate pass command exists and works
        validate_pass_command()
        
        # Resolve store directory
        resolved_dir = resolve_store_directory(dir)
        validate_store_directory(resolved_dir)
        
        @debug "Using password store directory: $resolved_dir"
        
        return new(resolved_dir)
    end
end


function validate_pass_command()
    try
        run(pipeline(`pass --version`, stdout=devnull, stderr=devnull))
    catch e
        if e isa ProcessFailedException || e isa Base.IOError
            throw(SystemError("pass command not found or not working. Please install pass."))
        else
            rethrow(e)
        end
    end
end

function default_store_directory()
    return joinpath(homedir(), ".password-store")
end

function resolve_store_directory(dir)
    if dir isa AbstractString
        # Explicit directory provided
        return String(dir)
    elseif isnothing(dir)
        # Explicitly ignore environment variable, use default
        return default_store_directory()
    else
        # Use environment variable if set, otherwise default
        return get(ENV, "PASSWORD_STORE_DIR", default_store_directory())
    end
end

function validate_store_directory(dir::AbstractString)
    if !isdir(dir)
        throw(ArgumentError("Password store directory '$dir' does not exist"))
    end
    
    gpg_id_file = joinpath(dir, ".gpg-id")
    if !isfile(gpg_id_file)
        throw(ArgumentError("Password store not initialized. Run 'pass init <gpg-id>' first in directory '$dir'"))
    end
end



function Base.getindex(pass::PassStore, key::AbstractString)
    stderr_buffer = IOBuffer()
    cmd = pipeline(addenv(`pass show $key`, "PASSWORD_STORE_DIR" => pass.dir), stderr=stderr_buffer)
    
    try
        return readchomp(cmd)
    catch e
        if e isa ProcessFailedException
            stderr_output = String(take!(stderr_buffer))
            
            # Parse specific error types based on stderr content
            if contains(stderr_output, "is not in the password store")
                throw(KeyError(key))
            elseif contains(stderr_output, "gpg: decryption failed") || contains(stderr_output, "gpg: public key decryption failed")
                throw(ArgumentError("GPG decryption failed - check your GPG key and passphrase"))
            elseif contains(stderr_output, "gpg: No secret key") || contains(stderr_output, "gpg: secret key not available")
                throw(ArgumentError("GPG secret key not available for decryption"))
            else
                # Re-throw with more context
                error("pass command failed with exit code $(e.procs[1].exitcode): $stderr_output")
            end
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

function Base.haskey(pass::PassStore, key::AbstractString)
    try
        getindex(pass, key)
        return true
    catch KeyError
        return false
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
- `haskey(PASS, key)`: Check if a password exists for the given key

# Throws
- `KeyError`: When the requested password entry does not exist in the password store
"""
const PASS = PassStore()

end # module Pass
