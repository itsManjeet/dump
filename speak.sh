#!/bin/sh
speak() {
	aplay /tmp/test.wav
}
exec 2>/dev/null
pico2wave -l=en-US -w=/tmp/test.wav "$1"
speak
