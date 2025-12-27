#!/usr/bin/env python3

import argparse

args_parser = argparse.ArgumentParser(
	prog = "build.py",
	description = "Odin hot reload build script.",
	epilog = "Made by Karl Zylinski. Modified by Hubert Krzykalski")

args_parser.add_argument("-hot-reload",        action="store_true",   help="Build hot reload game DLL. Also builds executable if game not already running. If the game is running, it will hot reload the game DLL.")
args_parser.add_argument("-release",           action="store_true",   help="Build release game executable. Note: Deletes everything in the 'build/release' directory to make sure you get a clean release.")
args_parser.add_argument("-run",               action="store_true",   help="Run the executable after compiling it.")
args_parser.add_argument("-debug",             action="store_true",   help="Create debuggable. Makes it possible to debug hot reload and release build in a debugger. Debug mode comes with a performance penalty.")

import urllib.request
import os
import zipfile
import shutil
import platform
import subprocess
import functools
from enum import Enum

args = args_parser.parse_args()

num_build_modes = 0
if args.hot_reload:
	num_build_modes += 1
if args.release:
	num_build_modes += 1

if num_build_modes > 1:
	print("Can only use one of: -hot-reload, -release.")
	exit(1)
elif num_build_modes == 0:
	print("You must use one of: -hot-reload, -release")
	exit(1)

SYSTEM = platform.system()
IS_WINDOWS = SYSTEM == "Windows"
IS_OSX = SYSTEM == "Darwin"
IS_LINUX = SYSTEM == "Linux"

assert IS_WINDOWS or IS_OSX or IS_LINUX, "Unsupported platform."

def main():

	exe_path = ""
	
	if args.release:
		exe_path = build_release()
	elif args.hot_reload:
		exe_path = build_hot_reload()
	
	if exe_path != "" and args.run:
		print("Starting " + exe_path)
		subprocess.Popen(exe_path)


path_join = os.path.join


def build_hot_reload():

	

	out_dir = "build/hot_reload"

	if not os.path.exists(out_dir):
		make_dirs(out_dir)

	exe = "game_hot_reload" + executable_extension()
	dll_final_name = out_dir + "/game" + dll_extension()
	dll = dll_final_name

	if IS_LINUX or IS_OSX:
		dll = out_dir + "/game_tmp" + dll_extension()

	# Only used on windows
	pdb_dir = out_dir + "/game_pdbs"
	pdb_number = 0
	
	dll_extra_args = ""

	if args.debug:
		dll_extra_args += " -debug"

	game_running = process_exists(exe)

	if IS_WINDOWS:
		if not game_running:
			out_dir_files = os.listdir(out_dir)

			for f in out_dir_files:
				if f.endswith(".dll"):
					os.remove(os.path.join(out_dir, f))

			if os.path.exists(pdb_dir):
				shutil.rmtree(pdb_dir)

		if not os.path.exists(pdb_dir):
			make_dirs(pdb_dir)
		else:
			pdb_files = os.listdir(pdb_dir)

			for f in pdb_files:
				if f.endswith(".pdb"):
					n = int(f.removesuffix(".pdb").removeprefix("game_"))

					if n > pdb_number:
						pdb_number = n

		# On windows we make sure the PDB name for the DLL is unique on each
		# build. This makes debugging work properly.
		dll_extra_args += " -pdb-name:%s/game_%i.pdb" % (pdb_dir, pdb_number + 1)

	print("Building " + dll_final_name + "...")
	execute("odin build source -build-mode:dll -out:%s %s" % (dll, dll_extra_args))

	if IS_LINUX or IS_OSX:
		os.rename(dll, dll_final_name)

	if game_running:
		print("Hot Reload Succesful")

		# Hot reloading means the running executable will see the new dll.
		# So we can just return empty string here. This makes sure that the main
		# function does not try to run the executable, even if `run` is specified.
		return ""

	exe_extra_args = ""

	if IS_WINDOWS:
		exe_extra_args += " -pdb-name:%s/main_hot_reload.pdb" % out_dir

	if args.debug:
		exe_extra_args += " -debug"

	print("Building " + exe + "...")
	execute("odin build source/main_hot_reload -strict-style -vet -out:%s %s" % (exe, exe_extra_args))



	return "./" + exe

def build_release():
	out_dir = "build/release"

	print("Start release build")

	if os.path.exists(out_dir):
		shutil.rmtree(out_dir)

	make_dirs(out_dir)

	exe = out_dir + "/game_release" + executable_extension()

	print("Building " + exe + "...")

	extra_args = ""

	if not args.debug:
		extra_args += " -no-bounds-check -o:speed"

		if IS_WINDOWS:
			extra_args += " -subsystem:windows"
	else:
		extra_args += " -debug"

	execute("odin build source/main_release -out:%s -strict-style -vet %s" % (exe, extra_args))


	return exe

def execute(cmd):
	res = os.system(cmd)
	if res != 0:
		print("Failed running:" + cmd)
		exit(1)

def dll_extension():
	if IS_WINDOWS:
		return ".dll"

	if IS_OSX:
		return ".dylib"

	return ".so"

def executable_extension():
	if IS_WINDOWS:
		return ".exe"

	return ".bin"

def process_exists(process_name):
	if IS_WINDOWS:
		call = 'TASKLIST', '/NH', '/FI', 'imagename eq %s' % process_name
		return process_name in str(subprocess.check_output(call))
	else:
		out = subprocess.run(["pgrep", "-f", process_name], capture_output=True, text=True).stdout
		return out != ""


	return False

def make_dirs(path):
	n = os.path.normpath(path)
	s = n.split(os.sep)
	p = ""

	for d in s:
		p = os.path.join(p, d)

		if not os.path.exists(p):
			os.mkdir(p)

def copy_file_if_different(src, dest):
	do_copy = False
	if not os.path.exists(dest):
		do_copy = True
	elif os.path.getsize(dest) != os.path.getsize(src) or os.path.getmtime(dest) != os.path.getmtime(src):
		do_copy = True

	if do_copy:
		print("Copying %s to %s" % (src, dest))
		shutil.copyfile(src, dest)
	return

print = functools.partial(print, flush=True)

main()
