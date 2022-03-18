import sdl2
import opengl
import std/os
import glm
import util/utils
import types/[buffer, shader, texture, vao]

getAppDir().parentDir().setCurrentDir()

var screenWidth: cint = 600
var screenHeight: cint = 600

discard sdl2.init(INIT_VIDEO or INIT_EVENTS or INIT_TIMER)

discard SDL_GL_CONTEXT_MAJOR_VERSION.glSetAttribute(4)
discard SDL_GL_CONTEXT_MINOR_VERSION.glSetAttribute(6)
var window = createWindow("opened gl", 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL)
discard window.glCreateContext()

loadExtensions()

# vertex array, featuring fancy hex -> float color expansion
hex3f:
  var vertices: array[40, GLfloat] = [
    # pos(3), color(3), tex coords(2)
    -0.5'f, 0, 0.5, !0x776655, 0, 0,
    -0.5, 0, -0.5, !0x776655, 5, 0,
    0.5, 0, -0.5, !0x776655, 0, 0,
    0.5, 0, 0.5, !0x776655, 5, 0,
    0, 0.8, 0, !0xCCBBAA, 2.5, 5
  ]

# index array, specifies what vertices triangles will be drawn between
var indeces: array[18, GLuint] = [
  0'u32, 1, 2,
  0, 2, 3,
  0, 1, 4,
  1, 2, 4,
  2, 3, 4,
  3, 0, 4
]

shader shaderProgram:
  vert "src/shaders/main.vert"
  uniform "scale", "model", "view", "proj"
  frag "src/shaders/main.frag"
  uniform "tex0"

# set up vertex array object, vertex buffer object, element buffer object
var VAO1 = initvao()
bindvao VAO1

var VBO1 = initvbo(addr vertices, sizeof vertices)
var EBO1 = initebo(addr indeces, sizeof indeces)

# define what parts of vertices[] should be assigned to which layout in main.vert
VAO1.linkattrib(VBO1, 0, 3, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](0))
VAO1.linkattrib(VBO1, 1, 3, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](3 * sizeof GLfloat))
VAO1.linkattrib(VBO1, 2, 2, cGL_FLOAT, 8 * sizeof GLfloat, cast[pointer](6 * sizeof GLfloat))

unbindvao VAO1
unbindbuf VBO1
unbindbuf EBO1

# create texture, assign sampler
var tex = inittex("src/resources/astrabotpfp3.png")

useshader shaderProgram
glUniform1i(shaderProgram["tex0"], 0)

glEnable GL_DEPTH_TEST

var rot:float = 0

timercallback addrot:
  rot += 0.5
  return interval

proc render() =
  hex4fa glClearColor(!0x111111)
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT)
  useshader shaderProgram

  # perspective projection stuff
  var model, view, proj: Mat4[GLfloat]
  model = mat4(1'f)
  view = mat4(1'f)
  proj = mat4(1'f)
  model = model.rotate(radians(rot), vec3(0'f, 1, 0))
  view = view.translate(0, -0.5, -2)
  proj = perspective(GLfloat radians(45.0), (screenWidth / screenHeight), 0.1, 100)

  glUniformMatrix4fv(shaderProgram["model"], 1, GL_FALSE, caddr model)
  glUniformMatrix4fv(shaderProgram["view"], 1, GL_FALSE, caddr view)
  glUniformMatrix4fv(shaderProgram["proj"], 1, GL_FALSE, caddr proj)

  glUniform1f(shaderProgram["scale"], 1.5)
  bindtex tex
  bindvao VAO1
  glDrawElements(GL_TRIANGLES, GLsizei len indeces, GL_UNSIGNED_INT, nil)

  window.glSwapWindow()


var
  evt = sdl2.defaultEvent
  runGame = true

var rottimer = addTimer(30, addrot, nil)

while runGame:
  while pollEvent(evt):
    if evt.kind == QuitEvent:
      runGame = false
      break

  render()

# clean up GL and SDL stuff
delvao VAO1
delbuf VBO1
delbuf EBO1
deltex tex
delshader shaderProgram
discard removeTimer rottimer
destroy window
