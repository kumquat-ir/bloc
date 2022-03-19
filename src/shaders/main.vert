#version 460

layout (location = 0) in vec3 aPos;
layout (location = 1) in vec3 aColor;
layout (location = 2) in vec2 aTex;

out vec3 color;
out vec2 texCoord;

uniform float scale;

// perspective projection matrices
uniform mat4 cam;

void main() {
	gl_Position = cam * vec4(aPos, 1.0);
	
	color = aColor;
	texCoord = aTex;
}
