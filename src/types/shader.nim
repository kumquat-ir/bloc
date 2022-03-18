import opengl
import std/tables

type
  Shader* = object
    id: GLuint
    uniforms: Table[string, GLint]

proc initshader*(id: GLuint): Shader =
  result.id = id

proc useshader*(shader: Shader) =
  glUseProgram(shader.id)

proc delshader*(shader: Shader) =
  glDeleteProgram(shader.id)

proc adduniforms*(shader: var Shader, names: varargs[string]) =
  for name in names:
    shader.uniforms[name] = glGetUniformLocation(shader.id, name)

proc `[]`*(shader: Shader, name: string): GLint =
  return shader.uniforms[name]

template shader*(shadername: untyped, parts: untyped) =
  ## Creates a shader program.
  ##
  ## `shadername` should be an undeclared identifier, which the program will be assigned to
  ##
  ## `parts` should be a code block containing `shaderpart`, `uniform`, `vert`, and/or `frag` statements

  let shaderid_shadertmp {.inject.} = glCreateProgram()
  var todel_shadertmp {.inject.}: seq[GLuint]
  var uniforms_shadertmp {.inject.}: seq[string]
  parts
  shaderid_shadertmp.glLinkProgram()
  for shaderdel in todel_shadertmp:
    glDeleteShader shaderdel
  var shadername = initshader(shaderid_shadertmp)
  shadername.adduniforms(uniforms_shadertmp)

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

  shaderid_shadertmp.glAttachShader(shader)
  todel_shadertmp.add(shader)

template uniform*(names: varargs[string]) =
  ## Adds one or more uniforms to the shader object defined inside a `shader:` template
  ##
  ## Just calls `adduniforms(Shader, varargs[string])` but with nicer syntax

  uniforms_shadertmp.add(names)
