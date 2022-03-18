import sdl2
import opengl
import util/utils
import types/[buffer, shader, texture, vao]

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 600
var screenHeight: cint = 600

discard SDL_GL_CONTEXT_MAJOR_VERSION.glSetAttribute(4)
discard SDL_GL_CONTEXT_MINOR_VERSION.glSetAttribute(6)
var window = createWindow("opened gl", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL)
discard window.glCreateContext()

loadExtensions()

hex3f:
  var vertices: array[32, GLfloat] = [
    -0.5'f32, -0.5, 0.0, !0xFF0000, 0, 0,
    -0.5, 0.5, 0.0, !0x00FF00, 0, 1,
    0.5, 0.5, 0.0, !0x0000FF, 1, 1,
    0.5, -0.5, 0.0, !0xFFFFFF, 1, 0
  ]

var indeces: array[6, GLuint] = [
  0'u32, 2, 1,
  0, 3, 2
]

shader shaderProgram:
  vert "src/shaders/main.vert"
  uniform "scale"
  frag "src/shaders/main.frag"
  uniform "tex0"

var VAO1 = initvao()
bindvao VAO1

var VBO1 = initvbo(addr vertices, sizeof vertices)
var EBO1 = initebo(addr indeces, sizeof indeces)

VAO1.linkattrib(VBO1, 0, 3, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](0))
VAO1.linkattrib(VBO1, 1, 3, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](3 * sizeof GLfloat))
VAO1.linkattrib(VBO1, 2, 2, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](6 * sizeof GLfloat))

unbindvao VAO1
unbindbuf VBO1
unbindbuf EBO1

var tex = inittex("src/resources/astrabotpfp3.png", GL_TEXTURE0)

useshader shaderProgram
glUniform1i(shaderProgram["tex0"], 0)

proc render() =
  hex4fa glClearColor(!0x111111)
  glClear(GL_COLOR_BUFFER_BIT)
  useshader shaderProgram
  glUniform1f(shaderProgram["scale"], 1.5)
  bindtex tex
  bindvao VAO1
  glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_INT, nil)

  window.glSwapWindow()


var
  evt = sdl2.defaultEvent
  runGame = true

while runGame:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break

  render()

delvao VAO1
delbuf VBO1
delbuf EBO1
deltex tex
delshader shaderProgram

destroy window
