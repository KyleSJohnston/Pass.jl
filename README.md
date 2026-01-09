# Pass.jl

A Julia interface to the `pass` command-line password manager.

## Overview

Pass.jl provides a simple, dictionary-like interface to retrieve passwords and secrets stored in the standard Unix `pass` password store. It allows Julia programs to securely access stored credentials without manual intervention.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/kylesjohnston/Pass.jl")
```

## Usage

```julia
using Pass

const PASS = PassStore()

# Retrieve a password (throws KeyError if not found)
password = PASS["my-service/username"]

# Retrieve a password with a default fallback
password = get(PASS, "my-service/username", "default-password")

# Example: Using with database connections
db_password = PASS["database/production"]
connection = connect_to_db("user", db_password)

# Example: Handling missing passwords gracefully
api_key = get(PASS, "services/api-key", nothing)
if api_key === nothing
    @warn "API key not found in password store"
else
    # Use the API key
end

# Example: Check if password exists before accessing
if haskey(PASS, "optional/service")
    password = PASS["optional/service"]
    # Use the password
end
```

## Requirements

- The `pass` command must be installed and configured on your system
- Your password store must be initialized (`pass init`)
- Passwords must be stored using standard `pass` commands (e.g., `pass insert my-service/username`)

## API Reference

`PassStore()` provides access to the default password store.
`PassStore(dir)` provides access to the password store in `dir`.

**Methods:**
- `store[key]` - Retrieve password for the given key (throws `KeyError` if not found)
- `get(store, key, default)` - Retrieve password or return default if not found
- `haskey(store, key)` - Check if a password exists for the given key

## Error Handling

- `KeyError` is thrown when accessing a non-existent password entry
- Other process-related errors are re-thrown as-is

## Security Notes

- Passwords are retrieved directly from the `pass` command
- No passwords are cached or stored persistently by this package
- Ensure your `pass` store is properly secured with GPG encryption
