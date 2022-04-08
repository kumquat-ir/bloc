import opengl
import std/tables

type
  Shader* = object
    id: GLuint
    uniforms: Table[string, GLint]

func initshader*(id: GLuint): Shader =
  result.id = id

proc useshader*(shader: Shader) =
  glUseProgram(shader.id)

proc delshader*(shader: Shader) =
  glDeleteProgram(shader.id)

proc adduniforms*(shader: var Shader, names: varargs[string]) =
  for name in names:
    shader.uniforms[name] = glGetUniformLocation(shader.id, cstring name)

func `[]`*(shader: Shader, name: string): GLint =
  return shader.uniforms[name]

template shader*(shadername: untyped, parts: untyped) =
  ## Creates a shader program.
  ##
  ## `shadername` should be an undeclared identifier, which the program will be assigned to
  ##
  ## `parts` should be a code block containing `shaderpart`, `uniform`, `vert`, and/or `frag` statements
  
  var shadername: Shader
  # to avoid namespace pollution, since injecting is required for this syntax to work properly
  block:
    let shaderid {.inject.} = glCreateProgram()
    var todel {.inject.}: seq[GLuint]
    var uniforms {.inject.}: seq[string]
    parts
    shaderid.glLinkProgram()
    for shaderdel in todel:
      glDeleteShader shaderdel
    shadername = initshader(shaderid)
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
