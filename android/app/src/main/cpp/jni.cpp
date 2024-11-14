#include <jni.h>
#include "Metronome.h"

extern "C" {
    static Metronome metronomeBuffer;

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_addSubdivision(JNIEnv* env, jobject, jstring key, jint option, jfloat volume) {
        metronomeBuffer.addSubdivision(env->GetStringUTFChars(key, nullptr), option, volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_removeSubdivision(JNIEnv* env, jobject, jstring key) {
        metronomeBuffer.removeSubdivision(env->GetStringUTFChars(key, nullptr));
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setBpm(JNIEnv*, jobject, jint bpm) {
        metronomeBuffer.setBpm(bpm);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setSubdivisionOption(JNIEnv* env, jobject, jstring key, jint option) {
        metronomeBuffer.setSubdivisionOption(env->GetStringUTFChars(key, nullptr), option);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setSubdivisionVolume(JNIEnv* env, jobject, jstring key, jfloat volume) {
        metronomeBuffer.setSubdivisionVolume(env->GetStringUTFChars(key, nullptr), volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setVolume(JNIEnv*, jobject, float volume) {
        metronomeBuffer.setVolume(volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_startPlayback(JNIEnv*, jobject) {
        metronomeBuffer.startPlayback();
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_stopPlayback(JNIEnv*, jobject) {
        metronomeBuffer.stopPlayback();
    }
}
