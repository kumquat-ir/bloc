import opengl
import ./buffer

type
  VAO* = object
    id: GLuint

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

