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

const PASS = PassStore()

end # module Pass
