/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/* 
 * File:   utils.h
 *
 * Created on 9. září 2025, 14:28
 */

#ifndef UTILS_H
#define UTILS_H
#include <sys/stat.h>  // 添加 mode_t 定义
#include <stdarg.h>    // 添加 va_list 定义
#include <stdlib.h>

int mkpath(mode_t mode, const char* fmt, ...);

#endif /* UTILS_H */

