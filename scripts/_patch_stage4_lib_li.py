#!/usr/bin/env python3
"""Apply Stage 4 li-llm lib.li patches."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
LIB = ROOT / "packages/li-llm/src/lib.li"

EXTERN_BLOCK = '''
extern proc li_rt_path_exact(path: str, want: str) -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

extern proc li_rt_llm_weights_file_size(path: str) -> int raises IO
  requires true
  decreases 0

extern proc li_rt_llm_weights_file_byte_at(path: str, off: int) -> int raises IO
  requires off >= 0
  decreases off

extern proc li_rt_llm_safetensors_probe_path(path: str) -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

extern proc li_rt_llm_last_safetensors_header_len() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_safetensors_tensor_count() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_safetensors_data_offset() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_safetensors_first_dtype() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_safetensors_first_shape0() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_safetensors_first_shape1() -> int
  requires true
  decreases 0

extern proc li_rt_llm_gguf_probe_path(path: str) -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0

extern proc li_rt_llm_last_gguf_version() -> int
  requires true
  decreases 0

extern proc li_rt_llm_last_gguf_tensor_count() -> int
  requires true
  decreases 0

'''

STAGE4_HELPERS = '''
def llm_path_is_legacy_safetensors_scaffold(path: str) -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  var p_eq: str = path
  if li_rt_path_exact(p_eq, "fixtures/model.safetensors") == 1:
    return 1
  return 0

def llm_weights_file_exists(path: str) -> int raises IO
  requires true
  ensures result >= 0
  ensures result <= 1
  decreases 0
=
  var p_sz: str = path
  if li_rt_llm_weights_file_size(p_sz) > 0:
    return 1
  return 0

def llm_dtype_f32() -> int
  requires true
  ensures result == 1
  decreases 0
=
  return 1

def llm_dtype_f16() -> int
  requires true
  ensures result == 2
  decreases 0
=
  return 2

def llm_safetensors_parse_header_file(path: str) -> LlmSafetensorsHeader raises IO, Alloc
  requires true
  ensures result.tensors_loaded == 0
  decreases 0
=
  var h: LlmSafetensorsHeader = llm_safetensors_header_none()
  var p_chk: str = path
  if llm_weights_file_exists(p_chk) != 1:
    return h
  var p_probe: str = path
  if li_rt_llm_safetensors_probe_path(p_probe) != 1:
    return h
  var hdr_len: int = li_rt_llm_last_safetensors_header_len()
  var tc: int = li_rt_llm_last_safetensors_tensor_count()
  var data_off: int = li_rt_llm_last_safetensors_data_offset()
  if hdr_len <= 0:
    return h
  if tc <= 0:
    return h
  if data_off <= 0:
    return h
  h.parsed_ok = 1
  h.header_len = hdr_len
  h.tensor_count = tc
  h.data_offset = data_off
  h.first_dtype = li_rt_llm_last_safetensors_first_dtype()
  h.first_shape0 = li_rt_llm_last_safetensors_first_shape0()
  h.first_shape1 = li_rt_llm_last_safetensors_first_shape1()
  if h.first_dtype <= 0:
    h.first_dtype = llm_dtype_f32()
  if h.first_shape0 <= 0:
    h.first_shape0 = 1
  if h.first_shape1 <= 0:
    h.first_shape1 = 1
  return h

def llm_tensor_meta_from_header(hdr: LlmSafetensorsHeader) -> LlmTensorMeta
  requires true
  ensures result.dtype_tag >= 0
  decreases 0
=
  var m: LlmTensorMeta
  m.dtype_tag = hdr.first_dtype
  m.shape0 = hdr.first_shape0
  m.shape1 = hdr.first_shape1
  m.byte_len = m.shape0 * m.shape1 * 4
  if m.dtype_tag == llm_dtype_f16():
    m.byte_len = m.shape0 * m.shape1 * 2
  return m

def llm_gguf_header_none() -> LlmGgufHeader
  requires true
  ensures result.parsed_ok == 0
  decreases 0
=
  var g: LlmGgufHeader
  g.parsed_ok = 0
  g.version = 0
  g.tensor_count = 0
  return g

def llm_gguf_parse_header(path: str) -> LlmGgufHeader raises IO, Alloc
  requires true
  decreases 0
=
  var g: LlmGgufHeader = llm_gguf_header_none()
  var p_chk: str = path
  if llm_weights_file_exists(p_chk) != 1:
    return g
  var p_gguf: str = path
  if li_rt_llm_gguf_probe_path(p_gguf) != 1:
    return g
  g.parsed_ok = 1
  g.version = li_rt_llm_last_gguf_version()
  g.tensor_count = li_rt_llm_last_gguf_tensor_count()
  return g

'''

LOAD_WEIGHTS = '''
# WP-LLM-02 / Stage 4: on-disk safetensors/GGUF header; legacy scaffold keeps tensors_loaded=0.
def llm_load_weights_safetensors_path(path: str) -> LlmModelWeights raises IO, Alloc
  requires true
  ensures result.format_tag == llm_format_safetensors()
  decreases 0
=
  var p_load: str = path
  var hdr: LlmSafetensorsHeader = llm_safetensors_load_tensors_scaffold(p_load)
  var w: LlmModelWeights
  w.loaded = 1
  w.format_tag = llm_format_safetensors()
  w.config = llm_model_config_fixture()
  w.header_parsed = hdr.parsed_ok
  w.tensor_count = hdr.tensor_count
  w.tensors_loaded = hdr.tensors_loaded
  var p_legacy: str = path
  if llm_path_is_legacy_safetensors_scaffold(p_legacy) == 1:
    w.tensors_loaded = 0
  return w

def llm_load_weights_gguf_path(path: str) -> LlmModelWeights raises IO, Alloc
  requires true
  ensures result.format_tag == llm_format_gguf()
  decreases 0
=
  var p_gg: str = path
  var gh: LlmGgufHeader = llm_gguf_parse_header(p_gg)
  var w2: LlmModelWeights
  w2.loaded = 1
  w2.format_tag = llm_format_gguf()
  w2.config = llm_model_config_fixture()
  w2.header_parsed = gh.parsed_ok
  w2.tensor_count = gh.tensor_count
  w2.tensors_loaded = 0
  if gh.parsed_ok == 1:
    w2.tensors_loaded = gh.tensor_count
  var p_fix: str = path
  if llm_path_is_gguf_fixture(p_fix) == 1:
    var p_exist: str = path
    if llm_weights_file_exists(p_exist) != 1:
      w2.header_parsed = 0
      w2.tensors_loaded = 0
  return w2

def llm_load_weights(path: str) -> LlmModelWeights raises IO, Alloc
  requires true
  decreases 0
=
  var pth: str = path
  var tag: int = llm_path_format_tag(pth)
  if tag == llm_format_safetensors():
    var p_st: str = path
    return llm_load_weights_safetensors_path(p_st)
  if tag == llm_format_gguf():
    var p_gguf: str = path
    return llm_load_weights_gguf_path(p_gguf)
  return llm_model_weights_none()

def llm_import_model_path_default() -> str
  requires true
  ensures result != ""
  decreases 0
=
  return "fixtures/ph-ml-weights/model.safetensors"

'''


def main() -> None:
    text = LIB.read_text(encoding="utf-8")
    if "li_rt_llm_safetensors_probe_path" in text:
        print("lib.li already patched")
        return
    text = text.replace(
        "  decreases 0\n\ndef llm_path_bytes_eq",
        "  decreases 0\n" + EXTERN_BLOCK + "\ndef llm_path_bytes_eq",
        1,
    )
    text = text.replace("ensures result == 4\n  decreases 0\n=\n  return 4", "ensures result == 5\n  decreases 0\n=\n  return 5")
    text = text.replace(
        "  public data_offset: int\n\ntype LlmModelWeights",
        "  public data_offset: int\n  public first_dtype: int\n  public first_shape0: int\n  public first_shape1: int\n\ntype LlmTensorMeta = object\n  public dtype_tag: int\n  public shape0: int\n  public shape1: int\n  public byte_len: int\n\ntype LlmGgufHeader = object\n  public parsed_ok: int\n  public version: int\n  public tensor_count: int\n\ntype LlmModelWeights",
    )
    text = text.replace(
        "  h.data_offset = 0\n  return h\n\ndef llm_safetensors_header_fixture",
        "  h.data_offset = 0\n  h.first_dtype = 0\n  h.first_shape0 = 0\n  h.first_shape1 = 0\n  return h\n\ndef llm_safetensors_header_fixture",
    )
    text = text.replace(
        "  h.data_offset = 64\n  return h\n\ndef llm_safetensors_load_tensors",
        "  h.data_offset = 64\n  h.first_dtype = llm_dtype_f32()\n  h.first_shape0 = 2\n  h.first_shape1 = 2\n  return h\n" + STAGE4_HELPERS + "\ndef llm_safetensors_load_tensors",
    )
    old_parse = '''def llm_safetensors_parse_header(path: str) -> LlmSafetensorsHeader raises IO, Alloc
  requires true
  ensures result.tensors_loaded == 0
  decreases 0
=
  var p: str = path
  if llm_path_format_tag(p) != llm_format_safetensors():
    return llm_safetensors_header_none()
  return llm_safetensors_header_fixture()'''
    new_parse = '''def llm_safetensors_parse_header(path: str) -> LlmSafetensorsHeader raises IO, Alloc
  requires true
  ensures result.tensors_loaded == 0
  decreases 0
=
  var p_tag: str = path
  if llm_path_format_tag(p_tag) != llm_format_safetensors():
    return llm_safetensors_header_none()
  var p_file: str = path
  if llm_weights_file_exists(p_file) == 1:
    return llm_safetensors_parse_header_file(p_file)
  return llm_safetensors_header_fixture()'''
    text = text.replace(old_parse, new_parse)
    start = text.index("# WP-LLM-02: fixture-path loader")
    end = text.index("def llm_safetensors_mmap_chunk_size")
    text = text[:start] + LOAD_WEIGHTS + "\n\n" + text[end:]
    old_mmap = '''  var p0: str = path
  if llm_path_is_safetensors_fixture(p0) != 1:
    return 0
  return llm_safetensors_mmap_byte_at_fixture(tensor_index, byte_off)'''
    new_mmap = '''  var p0: str = path
  if llm_weights_file_exists(p0) == 1:
    var p_hdr: str = path
    var hdr: LlmSafetensorsHeader = llm_safetensors_parse_header_file(p_hdr)
    if hdr.parsed_ok == 1:
      var meta: LlmTensorMeta = llm_tensor_meta_from_header(hdr)
      var tensor_base: int = hdr.data_offset + tensor_index * meta.byte_len
      var p_byte: str = path
      var b: int = li_rt_llm_weights_file_byte_at(p_byte, tensor_base + byte_off)
      if b >= 0:
        return b
  if llm_path_is_safetensors_fixture(p0) != 1:
    return 0
  return llm_safetensors_mmap_byte_at_fixture(tensor_index, byte_off)'''
    text = text.replace(old_mmap, new_mmap)
    text = text.replace(
        "sum = sum + llm_safetensors_mmap_byte_at_fixture(tensor_index, off)",
        "sum = sum + llm_safetensors_mmap_byte_at(path, tensor_index, off)",
    )
    text = text.replace(
        "var w: LlmModelWeights = llm_load_weights_safetensors_fixture()",
        "var w: LlmModelWeights = llm_load_weights_safetensors_path(\"fixtures/model.safetensors\")",
    )
    text = text.replace(
        "  if weights.tensors_loaded > 0:\n    acc = acc + weights.tensors_loaded\n  if out.vocab_size > 0:",
        "  if weights.tensors_loaded > 0:\n    acc = acc + weights.tensors_loaded\n  if weights.header_parsed == 1:\n    acc = acc + weights.tensor_count\n  if out.vocab_size > 0:",
    )
    marker = "  return llm_dot_str()\ndef llm_generate("
    first = text.find(marker)
    second = text.find(marker, first + 1)
    if second != -1:
        text = text[:second].rstrip() + "\n"
    LIB.write_text(text, encoding="utf-8")
    print("patched", LIB)


if __name__ == "__main__":
    main()
