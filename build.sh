#!/bin/sh

nasm -f elf32 projeto.asm -o projeto.o
gcc -m32 projeto.o -o projeto

