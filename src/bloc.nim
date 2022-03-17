import sdl2
import opengl
import std/math
import util/glutils
import util/types

discard sdl2.init(INIT_EVERYTHING)

var screenWidth: cint = 600
var screenHeight: cint = 600

discard SDL_GL_CONTEXT_MAJOR_VERSION.glSetAttribute(4)
discard SDL_GL_CONTEXT_MINOR_VERSION.glSetAttribute(6)
var window = createWindow("haha triangle", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL)
discard window.glCreateContext()

loadExtensions()

hex3f:
  var vertices: array[36, GLfloat] = [
    -0.5'f32, -0.5 * sqrt(3.0) / 3,     0.0, !0x007700,
    0.5,      -0.5 * sqrt(3.0) / 3,     0.0, !0x770000,
    0.0,       0.5 * sqrt(3.0) * 2 / 3, 0.0, !0x000077,
    -0.5 / 2,  0.5 * sqrt(3.0) / 6,     0.0, !0x770077,
    0.5 / 2,   0.5 * sqrt(3.0) / 6,     0.0, !0x007777,
    0.0,      -0.5 * sqrt(3.0) / 3,     0.0, !0x777700
  ]

var indeces: array[9, GLuint] = [
  0'u32, 3, 5,
  3, 2, 4,
  5, 4, 1
]

shader shaderProgram:
  vert "src/shaders/main.vert"
  uniform "scale"
  frag "src/shaders/main.frag"

var VAO1 = initvao()
bindvao VAO1

var VBO1 = initvbo(addr vertices, sizeof vertices)
var EBO1 = initebo(addr indeces, sizeof indeces)

VAO1.linkattrib(VBO1, 0, 3, cGL_FLOAT, 6 * sizeof GLfloat, cast[pointer](0))
VAO1.linkattrib(VBO1, 1, 3, cGL_FLOAT, 6 * sizeof GLfloat, cast[pointer](3 * sizeof GLfloat))

unbindvao VAO1
unbindbuf VBO1
unbindbuf EBO1

proc render() =
  hex4fa glClearColor(!0x111111)
  glClear(GL_COLOR_BUFFER_BIT)
  useshader shaderProgram
  glUniform1f(shaderProgram["scale"], 1.5)
  bindvao VAO1
  glDrawElements(GL_TRIANGLES, 9, GL_UNSIGNED_INT, nil)

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
delshader shaderProgram

destroy window
