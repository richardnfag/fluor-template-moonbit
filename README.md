# {{project-name}}

Starter template for a Fluor function in MoonBit using `wit-bindgen` and `wasm-tools`.

## Requirements

- MoonBit toolchain
- `wit-bindgen-cli`: `cargo install wit-bindgen-cli`
- `wasm-tools`: `cargo install wasm-tools`
- Ensure `moon` is available on `PATH` (for example `export PATH="$HOME/.moon/bin:$PATH"`)

## Build

```bash
just build
```

This template generates the MoonBit bindings, copies `guest/impl.mbt` into place, and produces `out/{{project-name}}.wasm`. `wit-bindgen` 0.63 exchanges MoonBit strings as UTF-16, so the build rewrites that marshalling to the UTF-8 canonical ABI before compiling.

The generated component targets Fluor's `v2` contract with an exported `handler` interface and typed `request`/`response` records.
