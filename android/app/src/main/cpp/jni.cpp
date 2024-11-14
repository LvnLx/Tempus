#include <jni.h>

#include "Metronome.h"

extern "C" {
    static Metronome metronome;

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_addSubdivision(JNIEnv* env, jobject, jstring key, jint option, jfloat volume) {
        metronome.addSubdivision(env->GetStringUTFChars(key, nullptr), option, volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_removeSubdivision(JNIEnv* env, jobject, jstring key) {
        metronome.removeSubdivision(env->GetStringUTFChars(key, nullptr));
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setBpm(JNIEnv*, jobject, jint bpm) {
        metronome.setBpm(bpm);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setSubdivisionOption(JNIEnv* env, jobject, jstring key, jint option) {
        metronome.setSubdivisionOption(env->GetStringUTFChars(key, nullptr), option);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setSubdivisionVolume(JNIEnv* env, jobject, jstring key, jfloat volume) {
        metronome.setSubdivisionVolume(env->GetStringUTFChars(key, nullptr), volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_setVolume(JNIEnv*, jobject, jfloat volume) {
        metronome.setVolume(volume);
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_startPlayback(JNIEnv*, jobject) {
        metronome.startPlayback();
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_stopPlayback(JNIEnv*, jobject) {
        metronome.stopPlayback();
    }

    JNIEXPORT void JNICALL
    Java_com_lvnlx_metronomic_MainActivity_loadAudioFrames(JNIEnv* env, jobject, jstring fileName, jfloatArray audioFrames) {
        jsize arrayFramesLength = env->GetArrayLength(audioFrames);
        jfloat* arrayFramesPointer = env->GetFloatArrayElements(audioFrames, nullptr);
        metronome.audioFrames[env->GetStringUTFChars(fileName, nullptr)] = std::vector<float>(arrayFramesPointer, arrayFramesPointer + arrayFramesLength);
        env->ReleaseFloatArrayElements(audioFrames, arrayFramesPointer, 0);
    }
}
