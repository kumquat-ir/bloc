import opengl
import stb_image/read as stbi

type
  Texture* = object
    id: GLuint
    textype: GLenum
    width, height, numch: int

proc inittex*(path: string, slot: GLenum = GL_TEXTURE0, textype: GLenum = GL_TEXTURE_2D, format: GLenum = GL_RGBA,
    pixtype: GLenum = GL_UNSIGNED_BYTE, filter: GLint = GL_LINEAR): Texture =
  result.textype = textype

  stbi.setFlipVerticallyOnLoad(true)
  var imgdata = stbi.load(path, result.width, result.height, result.numch, stbi.Default)

  glGenTextures(1, addr result.id)
  glActiveTexture(slot)
  glBindTexture(textype, result.id)

  glTexParameteri(textype, GL_TEXTURE_MIN_FILTER, filter)
  glTexParameteri(textype, GL_TEXTURE_MAG_FILTER, filter)

  glTexParameteri(textype, GL_TEXTURE_WRAP_S, GL_REPEAT)
  glTexParameteri(textype, GL_TEXTURE_WRAP_T, GL_REPEAT)

  glTexImage2D(textype, 0, GLint GL_RGBA, GLsizei result.width, GLsizei result.height, 0, format, pixtype, addr imgdata[0])
  glGenerateMipmap(textype)

  glBindTexture(textype, 0)

proc bindtex*(tex: Texture) =
  glBindTexture(tex.textype, tex.id)

proc unbindtex*(tex: Texture) =
  glBindTexture(tex.textype, 0)

proc deltex*(tex: var Texture) =
  glDeleteTextures(1, addr tex.id)
