import std/macros

proc hexadd4f(val: BiggestInt): seq[NimNode] =
  let r = float(val shr 24 and 0xFF) / 255.0
  let g = float(val shr 16 and 0xFF) / 255.0
  let b = float(val shr 8 and 0xFF) / 255.0
  let a = float(val and 0xFF) / 255.0
  for node in [newLit a, newLit b, newLit g, newLit r]:
    result.add(node)

proc hexadd4fa(val: BiggestInt): seq[NimNode] =
  return hexadd4f(val shl 8 or 0xFF)

proc hexadd3f(val: BiggestInt): seq[NimNode] =
  let r = float(val shr 16 and 0xFF) / 255.0
  let g = float(val shr 8 and 0xFF) / 255.0
  let b = float(val and 0xFF) / 255.0
  for node in [newLit b, newLit g, newLit r]:
    result.add(node)

proc hextraverse(root: NimNode, nodegenfn: proc) =
  var found: seq[int]
  for i, child in root.pairs:
    if child.kind == nnkPrefix and child[0].kind == nnkIdent and child[0] == ident("!"):
      found.add i
    elif child.len > 0:
      hextraverse(child, nodegenfn)
  
  var offset = 0
  for i in found:
    let idx = i + offset
    let val: int64 = root[idx][1].intVal
    root.del(idx)
    offset -= 1
    for node in nodegenfn(val):
      root.insert(idx, node)
      offset += 1

macro hex4f*(code: untyped) =
  result = code
  hextraverse(result, hexadd4f)

macro hex4fa*(code: untyped) =
  result = code
  hextraverse(result, hexadd4fa)

macro hex3f*(code: untyped) =
  result = code
  hextraverse(result, hexadd3f)

template timercallback*(name: untyped, body:untyped) {.dirty.} =
  var name: TimerCallback = proc(interval: uint32; param: pointer): uint32 {.cdecl.} =
    body
