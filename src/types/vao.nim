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

proc linkarr*(ao: VAO, bo: VBO, lens: varargs[GLint]) =
  var layout: GLuint = 0
  var offset = 0
  for llen in lens:
    ao.linkattrib(bo, layout, llen, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](offset))
    layout += 1
    offset += llen * sizeof GLfloat
