import std/macros
import opengl
from ./types import Shader, initshader

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

template shader*(shadername: untyped, parts: untyped) =
  ## Creates a shader program.
  ## 
  ## `shadername` should be an undeclared identifier, which the program will be assigned to
  ## 
  ## `parts` should be a code block containing `shaderpart`, `vert`, and/or `frag` statements

  let shaderid {.inject.} = glCreateProgram()
  var todel {.inject.}: seq[GLuint]
  var uniforms {.inject.}: seq[string]
  parts
  shaderid.glLinkProgram()
  for shaderdel in todel:
    glDeleteShader shaderdel
  var shadername = initshader(shaderid)
  shadername.adduniforms(uniforms)

template frag*(path: string) =
  ## Adds a fragment shader to a shader program inside a `shader:` template
  ## 
  ## `path` should be a file path to the shader file
  
  shaderpart(path, GL_FRAGMENT_SHADER)

template vert*(path: string) =
  ## Adds a vertex shader to a shader program inside a `shader:` template
  ## 
  ## `path` should be a file path to the shader file
  
  shaderpart(path, GL_VERTEX_SHADER)

template shaderpart*(path: string, shadertype: GLenum) =
  ## Adds a shader to a shader program inside a `shader:` template
  ## 
  ## `path` should be a file path to the shader file
  ## 
  ## `shadertype` should be a GLenum value specifying the type of shader  
  ## (This value is passed to `glCreateShader`)

  let sfile = open(path)
  let ssrc = allocCStringArray [sfile.readAll()]
  sfile.close()

  let shader = glCreateShader(shadertype)
  shader.glShaderSource(1, ssrc, nil)
  shader.glCompileShader()
  deallocCStringArray ssrc

  shaderid.glAttachShader(shader)
  todel.add(shader)

template uniform*(names: varargs[string]) =
  ## Adds one or more uniforms to the shader object defined inside a `shader:` template
  ## 
  ## Just calls `adduniforms(Shader, varargs[string])` but with nicer syntax

  uniforms.add(names)

proc `+`*(a: pointer, b: pointer): pointer =
  return cast[pointer](cast[int](a) + cast[int](b))
