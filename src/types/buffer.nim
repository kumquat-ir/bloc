import opengl

type
  GLbuf = object of RootObj
    id: GLuint
    buftype: GLenum
  VBO* = object of GLbuf
  EBO* = object of GLbuf

proc initbuf(buf: var GLbuf, data: ptr, size: GLsizeiptr) =
  glGenBuffers(1, addr buf.id)
  glBindBuffer(buf.buftype, buf.id)
  glBufferData(buf.buftype, size, data, GL_STATIC_DRAW)

proc initvbo*(data: ptr, size: GLsizeiptr): VBO =
  result.buftype = GL_ARRAY_BUFFER

  initbuf(result, data, size)

template initvbo*(data: typed): VBO =
  initvbo(addr data, sizeof data)

proc initebo*(data: ptr, size: GLsizeiptr): EBO =
  result.buftype = GL_ELEMENT_ARRAY_BUFFER

  initbuf(result, data, size)

template initebo*(data: typed): EBO =
  initebo(addr data, sizeof data)

proc bindbuf*(buf: GLbuf) =
  glBindBuffer(buf.buftype, buf.id)

proc unbindbuf*(buf: GLbuf) =
  glBindBuffer(buf.buftype, 0)

proc delbuf*(buf: var GLbuf) =
  glDeleteBuffers(1, addr buf.id)
