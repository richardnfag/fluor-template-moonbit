import pathlib
import sys

ffi_path, pkg_path = sys.argv[1:]
lines = pathlib.Path(ffi_path).read_text().splitlines(keepends=True)
output = []
index = 0
while index < len(lines):
    if "fn mbt_ffi_ptr2str" in lines[index]:
        index += 1
        while index < len(lines) and lines[index].startswith("#|"):
            index += 1
        continue
    output.append(lines[index])
    index += 1
ffi = "".join(output)
replacements = {
    """let ptr = mbt_ffi_str2ptr((iter_elem).name)
                        mbt_ffi_store32((iter_base) + 4, (iter_elem).name.length())
                        mbt_ffi_store32((iter_base) + 0, ptr)""": """let abi_name = abi_string((iter_elem).name)
                        mbt_ffi_store32((iter_base) + 4, abi_name.len)
                        mbt_ffi_store32((iter_base) + 0, abi_name.ptr)""",
    """let ptr6 = mbt_ffi_str2ptr((iter_elem).value)
                        mbt_ffi_store32((iter_base) + 12, (iter_elem).value.length())
                        mbt_ffi_store32((iter_base) + 8, ptr6)""": """let abi_value = abi_string((iter_elem).value)
                        mbt_ffi_store32((iter_base) + 12, abi_value.len)
                        mbt_ffi_store32((iter_base) + 8, abi_value.ptr)""",
    """let ptr8 = mbt_ffi_str2ptr((payload).body)
                  mbt_ffi_store32((return_area) + 20, (payload).body.length())
                  mbt_ffi_store32((return_area) + 16, ptr8)""": """let abi_body = abi_string((payload).body)
                  mbt_ffi_store32((return_area) + 20, abi_body.len)
                  mbt_ffi_store32((return_area) + 16, abi_body.ptr)""",
    """let ptr10 = mbt_ffi_str2ptr((payload9).message)
                  mbt_ffi_store32((return_area) + 12, (payload9).message.length())
                  mbt_ffi_store32((return_area) + 8, ptr10)""": """let abi_message = abi_string((payload9).message)
                  mbt_ffi_store32((return_area) + 12, abi_message.len)
                  mbt_ffi_store32((return_area) + 8, abi_message.ptr)""",
}
for old, new in replacements.items():
    if old not in ffi:
        raise SystemExit(f"missing generated string store:\n{old}")
    ffi = ffi.replace(old, new, 1)
pathlib.Path(ffi_path).write_text(ffi)

pkg = pathlib.Path(pkg_path)
text = pkg.read_text()
if "@utf8" not in text:
    pkg.write_text('import {\n  "moonbitlang/core/encoding/utf8" @utf8,\n}\n\n' + text)
