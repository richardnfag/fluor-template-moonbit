default:
    @just --list

init:
    wit-bindgen moonbit wit/world.wit --out-dir .
    mkdir -p gen/interface/fluor/fun/handler
    printf '%s\n' '///|' 'pub fn handle(_request : Request) -> Result[Response, Error_] {' '  Ok({' '    status: 200,' '    headers: [],' '    body: "{\"message\":\"Hello from {{project-name}}\"}",' '  })' '}' > gen/interface/fluor/fun/handler/impl.mbt

build: init
    mkdir -p out
    moon build --target wasm --release
    wasm-tools component embed wit _build/wasm/release/build/gen/gen.wasm -o _build/{{project-name}}.embedded.wasm
    wasm-tools component new _build/{{project-name}}.embedded.wasm -o out/{{project-name}}.wasm

inspect: build
    wasm-tools component wit out/{{project-name}}.wasm
