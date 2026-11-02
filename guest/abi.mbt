///|
pub struct AbiString {
  ptr : Int
  len : Int
}

///|
pub fn mbt_ffi_ptr2str(ptr : Int, len : Int) -> String {
  if len <= 0 {
    return ""
  }
  let raw = FixedArray::make(len, b'\x00')
  for i = 0; i < len; i = i + 1 {
    raw[i] = (mbt_ffi_load8_u(ptr + i) & 0xFF).to_byte()
  }
  @utf8.decode_lossy(raw.unsafe_reinterpret_as_bytes())
}

///|
pub fn abi_string(value : String) -> AbiString {
  let bytes = @utf8.encode(value)
  let len = bytes.length()
  let ptr = mbt_ffi_malloc(len)
  let mut index = 0
  for byte in bytes {
    mbt_ffi_store8(ptr + index, byte.to_int())
    index = index + 1
  }
  { ptr, len }
}
