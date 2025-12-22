# Odin + OpenGL + SDL3 template
`Heavily Based of Karl Zylinski hot reload examples with [odin+raylib](https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template) and [odin+sokol](https://github.com/karl-zylinski/odin-sokol-hot-reload-template)`

This is an [Odin](https://github.com/odin-lang/Odin) + Opengl and SDL3. It makes it possible to reload gameplay code while the game is running.

I had a bit of a problem porting it to opengl, as you require a `game_reload_gl` for it to work correctly, thats why this exists.

Karl used this kind of hot reloading while developing his game, be sure to check it out [CAT & ONION](https://store.steampowered.com/app/2781210/CAT__ONION/).
If you want to learn more about Odin, there is also [his book](https://odinbook.com), 

Supported platforms: Windows, macOS(untested), Linux

Supported editors and debuggers: [Sublime Text](#sublime-text), [VS Code](#vs-code) and [RAD Debugger](#rad-debugger).

## Hot reload changes from Karl templates
If you want to see the hot reload in action build with Odin Hot Reload, and then you could change the time*1 to other number in the game.odin file, then build again

`game_reload_gl` added for the opengl window to not terminate on hot reload.  
## Sublime Text

There are 3 build variants :
  -"Odin", simple old fashioned build,
  -"Hot Reload", uses game.odin as a .dll that will be reloaded if there are changes on it on build,
  -"Release", use this to build finial .exe for you project
For those who use Sublime Text there's a project file: `project.sublime-project`.

How to use:
- Open the project file in sublime
- Choose the build system `Main Menu -> Tools -> Build With... -> Odin Hot Reload ` (you can rename the build system by editing `project.sublime-project` manually)
- Compile and run by pressing using F7 / Ctrl + B / Cmd + B
- After you make code changes and want to hot reload, just hit F7 / Ctrl + B / Cmd + B again

## PS
I dont do a lot of this github stuff, if there is question make an issue, I will make sure to answer.
