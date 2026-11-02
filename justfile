default:
    @just --list

init:
    wit-bindgen moonbit wit/world.wit --out-dir .
    mkdir -p gen/interface/fluor/fun/handler
    cp guest/impl.mbt gen/interface/fluor/fun/handler/impl.mbt
    cp guest/abi.mbt gen/interface/fluor/fun/handler/abi.mbt
    python3 guest/patch_ffi.py gen/interface/fluor/fun/handler/ffi.mbt gen/interface/fluor/fun/handler/moon.pkg

build: init
    mkdir -p out
    moon build --target wasm --release
    wasm-tools component embed wit _build/wasm/release/build/gen/gen.wasm -o _build/{{project-name}}.embedded.wasm
    wasm-tools component new _build/{{project-name}}.embedded.wasm -o out/{{project-name}}.wasm

inspect: build
    wasm-tools component wit out/{{project-name}}.wasm
