// Linux stand-in for <android/native_window_jni.h>
#pragma once
#include <jni.h>
#include "native_window.h"
#ifdef __cplusplus
extern "C" {
#endif
static inline ANativeWindow* ANativeWindow_fromSurface(JNIEnv*, jobject) { return 0; }
#ifdef __cplusplus
}
#endif
