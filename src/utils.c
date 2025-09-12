/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
#include <string.h>
#include <errno.h>
#include <stdio.h>
#include <stdarg.h>
#include <stdlib.h>

#include "utils.h"

#if defined(_WIN32) || defined(_WIN64)
    #include <direct.h>
    #define MKDIR(path, mode) _mkdir(path)
#else
    #include <sys/stat.h>
    #include <sys/types.h>
    #define MKDIR(path, mode) mkdir(path, mode)
#endif

static int _mkpath(char* file_path, mode_t mode) {
    for (char* p = strchr(file_path + 1, '/'); p; p = strchr(p + 1, '/')) {
        *p = '\0';
        
        if (MKDIR(file_path, mode) == -1) {
            if (errno != EEXIST) {
                *p = '/';
                return -1;
            }
        }
        *p = '/';
    }
    return 0;
}

int mkpath(mode_t mode, const char* fmt, ...) {
    char * path = malloc(FILENAME_MAX);
    if (path == NULL) {
        return -1;
    }
    
    va_list args;
    va_start(args, fmt);
    vsnprintf(path, FILENAME_MAX, fmt, args);
    va_end(args);

    #if defined(_WIN32) || defined(_WIN64)
    for (char* p = path; *p; p++) {
        if (*p == '/') {
            *p = '\\';
        }
    }
    #endif
    
    int ret = _mkpath(path, mode);
    free(path);
    return ret;
}
