import opengl
import std/tables

type
  Shader* = object
    id: GLuint
    uniforms: Table[string, GLint]
  GLbuf = object of RootObj
    id: GLuint
    buftype: GLenum
  VBO* = object of GLbuf
  EBO* = object of GLbuf
  VAO* = object
    id: GLuint

proc initbuf(buf: var GLbuf, data: ptr, size: GLsizeiptr) =
  glGenBuffers(1, addr buf.id)
  glBindBuffer(buf.buftype, buf.id)
  glBufferData(buf.buftype, size, data, GL_STATIC_DRAW)

proc initvbo*(data: ptr, size: GLsizeiptr): VBO =
  result.buftype = GL_ARRAY_BUFFER

  initbuf(result, data, size)

proc initebo*(data: ptr, size: GLsizeiptr): EBO =
  result.buftype = GL_ELEMENT_ARRAY_BUFFER

  initbuf(result, data, size)

proc bindbuf*(buf: GLbuf) =
  glBindBuffer(buf.buftype, buf.id)

proc unbindbuf*(buf: GLbuf) =
  glBindBuffer(buf.buftype, 0)

proc delbuf*(buf: var GLbuf) =
  glDeleteBuffers(1, addr buf.id)

proc initvao*(): VAO =
  var ao: VAO

  glGenVertexArrays(1, addr ao.id)

  return ao

proc linkattrib*(ao: VAO, bo: VBO, layout: GLuint, numComponents: GLint, `type`: GLenum, stride: GLsizei, offset: pointer) =
  bindbuf bo
  glVertexAttribPointer(layout, numComponents, `type`, GL_FALSE, stride, offset)
  glEnableVertexAttribArray(layout)
  unbindbuf bo

proc bindvao*(ao: VAO) =
  glBindVertexArray(ao.id)

proc unbindvao*(ao: VAO) =
  glBindVertexArray(0)

proc delvao*(ao: var VAO) =
  glDeleteVertexArrays(1, addr ao.id)

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
