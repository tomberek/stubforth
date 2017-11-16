#ifndef CONFIG_H
#define CONFIG_H

#include ".rev.h"

#define FORTHNAME "stubforth"

#define PAD_SIZE 0 /* The size of the PAD (core-ext.m4) alloca'd on
		       first use in a VM instance. */

// TOM: was all 1024
#define RETURN_STACK_SIZE 16
#define PARAM_STACK_SIZE 8
#define DICTIONARY_SIZE 100

#include <stdint.h>

typedef intptr_t vmint;
typedef uintptr_t uvmint;
typedef int64_t dvmint;

#endif
