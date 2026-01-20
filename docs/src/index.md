# Pass.jl

Pass is a Julia interface to the unix `pass` command.
This package provides `PassStore`, a read-only Dict-like object inspired by `Base.EnvDict`.

## Installation

Pass.jl can be installed using `Pkg`.

```julia
pkg> add Pass
```

Installation of Pass.jl does _not_ attempt to install `pass` (or `gpg`) on your system.
`pass` needs to be available at the command line in order for Pass.jl to operate successfully.

## Example Usage

As an example, assume that you've previously stored an API key for a service in the default location for `pass`.

```bash
$ echo 'EXAMPLE-API-KEY' | pass insert -e service/api_key
```

!!! warning
    Running the command above puts `EXAMPLE-API-KEY` into your history, which stores your secrets on disk in plaintext.
    For production use, it would be better to store the key interactively.

    ```bash
    pass insert service/api_key
    <...>
    ```

If configured correctly, this key can be retrieved at the command line.

```bash
$ pass show service/api_key
EXAMPLE-API-KEY
```

From Julia, Pass.jl provides access to the same information.

```julia
using Pass
store = PassStore()  # default `pass` location
api_key = store["service/api_key"]  # "EXAMPLE-API-KEY"
```


!!! tip
    For ease of use, you may want to add your default `PassStore` to [`startup.jl`](https://docs.julialang.org/en/v1/manual/command-line-interface/#Startup-file).

    ```julia
    using Pass
    const PASS = PassStore()
    ```

    `PASS` can be used just like `ENV` to retrieve secrets.
    ```julia
    api_key = PASS["service/api_key"]
    ```

Pass.jl does not cache or store any of the values, for both simplicity and security.

## API

```@index
```

```@autodocs
Modules = [Pass]
Private = false
Order   = [:type, :module]
```

## Setup

!!! danger
    Pass.jl is only as secure as your `pass` configuration, which is your responsibility to manage.
    The examples here and in the unit tests are meant to serve as a starting point for moving away from plaintext credential storage.
    Review `man gpg` and `man pass` to learn about the options that are right for you.
    Note that the example configuration in the unit tests are only meant to  

Approximate steps:
1. Generate a new gpg key `gpg --full-generate-key`
1. Show the id for the generated key `gpg --list-keys --keyid-format LONG`
1. Initialize the password store `pass init <KEYID>`
1. Insert a secret `pass insert <path-to-secret>`
1. Retrieve the secret `pass show <path-to-secret>`
