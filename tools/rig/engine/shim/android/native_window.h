// Linux stand-in for <android/native_window.h>
#pragma once
#include <stdint.h>
#ifdef __cplusplus
extern "C" {
#endif
typedef struct ANativeWindow ANativeWindow;
static inline int32_t ANativeWindow_getWidth(ANativeWindow*) { return 0; }
static inline int32_t ANativeWindow_getHeight(ANativeWindow*) { return 0; }
static inline void ANativeWindow_release(ANativeWindow*) {}
#ifdef __cplusplus
}
#endif
