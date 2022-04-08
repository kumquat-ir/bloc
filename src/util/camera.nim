import glm
import opengl
import sdl2

type
  Camera* = object
    winw, winh: cint
    pos, orient, up: Vec3[GLfloat]
    speed, sensitivity: float32

func initCamera*(winw, winh: cint, ipos: Vec3[GLfloat]): Camera =
  result.orient = vec3(0'f, 0, -1)
  result.up = vec3(0'f, 1, 0)
  result.speed = 0.025
  result.sensitivity = 100.0
  result.winw = winw
  result.winh = winh
  result.pos = ipos

proc setupMatrices*(cam: Camera, matuni: GLint, fov: float = 45.0, nearplane = 0.1, farplane: float = 100) =
  var view, proj, final: Mat4[GLfloat]
  view = mat4(1'f)
  proj = mat4(1'f)
  final = mat4(1'f)

  view = lookAt(cam.pos, cam.pos + cam.orient, cam.up)
  proj = perspective(GLfloat radians(fov), (cam.winw / cam.winh), nearplane, farplane)
  final = proj * view

  glUniformMatrix4fv(matuni, 1, GL_FALSE, caddr final)

func handleKbd*(cam: var Camera, kbd: ptr array[0..512, uint8]) =
  if kbd[ord(SDL_SCANCODE_UP)] == 1:
    cam.pos += cam.speed * cam.orient
  
  if kbd[ord(SDL_SCANCODE_DOWN)] == 1:
    cam.pos -= cam.speed * cam.orient
  
  if kbd[ord(SDL_SCANCODE_RIGHT)] == 1:
    cam.pos += cam.speed * normalize(cross(cam.orient, cam.up))
  
  if kbd[ord(SDL_SCANCODE_LEFT)] == 1:
    cam.pos -= cam.speed * normalize(cross(cam.orient, cam.up))
  
  if kbd[ord(SDL_SCANCODE_PAGEUP)] == 1:
    cam.pos += cam.speed * cam.up
  
  if kbd[ord(SDL_SCANCODE_PAGEDOWN)] == 1:
    cam.pos -= cam.speed * cam.up
  
  if kbd[ord(SDL_SCANCODE_LSHIFT)] == 1:
    cam.speed = 0.1
  
  if kbd[ord(SDL_SCANCODE_LSHIFT)] == 0:
    cam.speed = 0.025

func mat3[T](m4: Mat4[T]): Mat3[T] =
  return mat3(vec3(m4[0][0], m4[0][1], m4[0][2]),
              vec3(m4[1][0], m4[1][1], m4[1][2]),
              vec3(m4[2][0], m4[2][1], m4[2][2]))

func rotate[T](vec: Vec[3, T], angle: SomeFloat, normal: Vec[3, T]): Vec[3, T] =
  return mat3[T](rotate(mat4[T](1), angle, normal)) * vec

func angle[N, T](a: Vec[N, T], b: Vec[N, T]): T =
  return arccos(clamp(dot(a, b), T(-1), T(1)))

func handleMouse*(cam: var Camera, relx, rely: int32) =
  if relx == 0 and rely == 0:
    return
  var rotx = relx / cam.winw * cam.sensitivity
  var roty = rely / cam.winh * cam.sensitivity

  var vorient = cam.orient.rotate(radians(roty), normalize(cross(cam.orient, cam.up)))
  if abs(angle(vorient, cam.up) - radians(90.0)) <= radians(85.0):
    cam.orient = vorient
  cam.orient = cam.orient.rotate(radians(rotx), cam.up)
