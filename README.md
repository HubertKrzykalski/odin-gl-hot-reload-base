# Odin + Raylib + Hot Reload template
`Forked from Karl Zylinski raylib hot reload templete.
Instead of varius .bat/.sh script I ported it to the use his sokol template build.py`

This is an [Odin](https://github.com/odin-lang/Odin) + game template with Opengl and SDL3. It makes it possible to reload gameplay code while the game is running.

I had a bit of a problem porting it to gl, as you require a `game_reload_gl` for it to work correctly, thats why this exists.

Karl used this kind of hot reloading while developing his game, be sure to check it out [CAT & ONION](https://store.steampowered.com/app/2781210/CAT__ONION/).

Supported platforms: Windows, macOS(untested), Linux

Supported editors and debuggers: [Sublime Text](#sublime-text), [VS Code](#vs-code) and [RAD Debugger](#rad-debugger).

Based of Karl Zylinski hot reload examples with [odin+raylib](https://github.com/karl-zylinski/odin-raylib-hot-reload-game-template) and [odin+sokol](https://github.com/karl-zylinski/odin-sokol-hot-reload-template)


## Hot reload changes from Karl templates
If you want to see the hot reload in action build with Odin Hot Reload, and then you could change the time*1 to other number in the game.odin file, then build again. 
>
`game_reload_gl` added for the opengl window to not terminate on hot reload.  
## Sublime Text

For those who use Sublime Text there's a project file: `project.sublime-project`.

How to use:
- Open the project file in sublime
- Choose the build system `Main Menu -> Tools -> Build With... -> Odin Hot Reload ` (you can rename the build system by editing `project.sublime-project` manually)
- Compile and run by pressing using F7 / Ctrl + B / Cmd + B
- After you make code changes and want to hot reload, just hit F7 / Ctrl + B / Cmd + B again