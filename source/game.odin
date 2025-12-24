/*
This file is the starting point of your game.

Some important procedures are:
- game_init: Opens the window and sets up the game state
- game_update: Run once per frame
- game_should_close: For stopping your game when close button is pressed
- game_shutdown: Shuts down game and frees memory
- game_shutdown_window: Closes window

The procs above are used regardless if you compile using the `build_release`
script or the `build_hot_reload` script. However, in the hot reload case, the
contents of this file is compiled as part of `build/hot_reload/game.dll` (or
.dylib/.so on mac/linux). In the hot reload cases some other procedures are
also used in order to facilitate the hot reload functionality:

- game_memory: Run just before a hot reload. That way game_hot_reload.exe has a
	pointer to the game's memory that it can hand to the new game DLL.
- game_hot_reloaded: Run after a hot reload so that the `g` global
	variable can be set to whatever pointer it was in the old DLL.

NOTE: When compiled as part of `build_release`, `build_debug` or `build_web`
then this whole package is just treated as a normal Odin package. No DLL is
created.
*/

package game

import "core:fmt"

import sdl 	"vendor:sdl3"
import	gl 	"vendor:OpenGL"
import glm  "core:math/linalg/glsl"
 



Game_Memory :: struct {
	some_number: int,
	run: bool,

	window: ^sdl.Window,
	glContext: sdl.GLContext,
	vao : u32,
	program : u32,
}

g: ^Game_Memory

update :: proc() {
	event: sdl.Event
	for sdl.PollEvent(&event){
		#partial switch event.type{
		case .QUIT:
			g.run = false
		case.KEY_UP:
			#partial switch event.key.scancode{
				case .ESCAPE:
					g.run = false
				case .TAB:
					g.run = false
				case .R:
					should_reload = true
				case .T:
					should_restart = true
			}
		}
	}
}

draw :: proc() {
	gl.ClearColor(0.065, 0.065, 0.065, 1.0)
	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	transform: glm.mat4 = 1
	transform *= glm.mat4Translate({0.0, -0.0, 0.0})
	time := f32(sdl.GetPerformanceCounter()) /
     f32(sdl.GetPerformanceFrequency())
	transform *= glm.mat4Rotate({0, 0, 1}, time*1)

	gl.Clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT)

	gl.UseProgram(g.program)
	ShaderSetMat4(g.program, "transform", transform)
	
		
	gl.BindVertexArray(g.vao)
	gl.DrawElements(gl.TRIANGLES, 6, gl.UNSIGNED_SHORT, nil)

	sdl.GL_SwapWindow(g.window)
}

@(export)
game_update :: proc() {
	draw()
	update()


	// Everything on tracking allocator is valid until end-of-frame.
	free_all(context.temp_allocator)
}


@(export)
game_init :: proc() {
	if !sdl.Init({.VIDEO}){
		fmt.panicf("sdl.Init error: ", sdl.GetError())
	}

	//Specify OpenGL Version and Profile
    sdl.GL_SetAttribute(.CONTEXT_PROFILE_MASK,  i32(sdl.GL_CONTEXT_PROFILE_CORE))
	sdl.GL_SetAttribute(.CONTEXT_MAJOR_VERSION, 3)
	sdl.GL_SetAttribute(.CONTEXT_MINOR_VERSION, 3)

	g = new(Game_Memory)
	g.run = true
	g.window = sdl.CreateWindow("LearningOpengl", 800, 600, {.HIGH_PIXEL_DENSITY, .OPENGL, .RESIZABLE, .ALWAYS_ON_TOP})
	if g.window == nil{
		fmt.panicf("sdl.CreateWindow error: ", sdl.GetError())
	}
	g.glContext = sdl.GL_CreateContext(g.window)
	if g.glContext == nil{
		fmt.panicf("Gl_CreateContext failed: ", sdl.GetError())
	}
	gl.load_up_to(3,3, sdl.gl_set_proc_address)

	gl.Viewport(0, 0, 800, 600)
	gl.Enable(gl.DEPTH_TEST)
	sdl.GL_SetSwapInterval(1)

	vertices : = []VERTEX{
        { {-0.5, -0.5, 0.0}, {0.0, 0.0, 1.0} },
        { { 0.5, -0.5, 0.0}, {0.0, 1.0, 0.5} },
        { { 0.5,  0.5, 0.0}, {1.0, 0.0, 0.0} },
        { {-0.5,  0.5, 0.0}, {1.0, 0.0, 0.0} },
	}
	indices := []u16{
		0,1,3,
		1,2,3,
	}

	vbo : u32
	gl.GenBuffers(1, &vbo)
	gl.BindBuffer(gl.ARRAY_BUFFER, vbo)
	gl.BufferData(
		gl.ARRAY_BUFFER,						// 
        len(vertices) * size_of(vertices[0]),	// byte size of our vertices, triangle = 3 * size_of*float, rect 4 * size_of * flot
        raw_data(vertices),						// actual vertex data we want to pass
        gl.STATIC_DRAW, 							// how frequently will we usage (static, dynamic,fixed)
	)

	vao : u32
	gl.GenVertexArrays(1, &vao)
	gl.BindVertexArray(vao)
	gl.EnableVertexAttribArray(0)
	gl.VertexAttribPointer(						//
	    0,                         				// attribute index
	    3,                         				// size (vec3)
	    gl.FLOAT,                  				// type
	    false,                     				// normalized?
	    size_of(VERTEX),           				// stride (bytes per vertex)
	    offset_of(VERTEX, pos),     				// offset (bytes into struct)
	)
	gl.EnableVertexAttribArray(1)				// bind vertex color
	gl.VertexAttribPointer(						//
	    1,                         				// attribute index
	    3,                         				// size (vec3)
	    gl.FLOAT,                  				// type
	    false,                     				// normalized?
	    size_of(VERTEX),           				// stride (bytes per vertex)
	    offset_of(VERTEX, color),     			// offset (bytes into struct)
	)

	ebo : u32
	gl.GenBuffers(1, &ebo)
	gl.BindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo)
	gl.BufferData(gl.ELEMENT_ARRAY_BUFFER, len(indices) * size_of(indices), raw_data(indices), gl.STATIC_DRAW)
	
	// Uncomment for debug
	//gl.PolygonMode(gl.FRONT_AND_BACK, gl.LINE)
	
	program, ok := gl.load_shaders_source(vertex_shader,  fragment_shader)
	if !ok{
		fmt.panicf("Failded to creat GLSL program")
	}
	gl.UseProgram(program)
	g.vao = vao
	g.program = program

	game_hot_reloaded(g)
}
@(export)
game_reload_gl :: proc() {
	gl.load_up_to(3, 3, sdl.gl_set_proc_address)
}

@(export)
game_should_run :: proc() -> bool {
	return g.run
}

@(export)
game_shutdown :: proc() {
	free(g)
	sdl.Quit()
}

@(export)
game_memory :: proc() -> rawptr {
	return g
}

@(export)
game_memory_size :: proc() -> int {
	return size_of(Game_Memory)
}

@(export)
game_hot_reloaded :: proc(mem: rawptr) {
	g = (^Game_Memory)(mem)

	// Here you can also set your own global variables. A good idea is to make
	// your global variables into pointers that point to something inside `g`.
}


should_reload : bool
should_restart: bool
@(export)
game_force_reload :: proc() -> bool {
	return should_reload 
}

@(export)
game_force_restart :: proc() -> bool {
	return should_restart
}



ShaderSetMat4 :: proc(id: u32, name: cstring, mat: glm.mat4) {
	lc := mat
	gl.UniformMatrix4fv(gl.GetUniformLocation(id, name), 1, gl.FALSE, raw_data(&lc))
}
VERTEX :: struct
{
	pos: [3]f32,
	color: [3]f32,
}

///				Shaders 			///
vertex_shader := `#version 330 core
layout (location = 0) in vec3 aPosition;
layout (location = 1) in vec3 aColor;

out vec3 pColor;

uniform mat4 transform;

void main()
{
    pColor = aColor;
    gl_Position = transform * vec4(aPosition, 1.0);
}
`

fragment_shader := `#version 330 core
in vec3 pColor;
out vec4 FragColor;

void main()
{
    FragColor = vec4(pColor, 1.0);
}

`