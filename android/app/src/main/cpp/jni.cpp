#include <jni.h>

#include "Metronome.h"

extern "C" {
static Metronome metronome;

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_addSubdivision(JNIEnv *env, jobject, jstring key, jint option,
                                                  jfloat volume) {
    metronome.addSubdivision(env->GetStringUTFChars(key, nullptr), option, volume);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_removeSubdivision(JNIEnv *env, jobject, jstring key) {
    metronome.removeSubdivision(env->GetStringUTFChars(key, nullptr));
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setBpm(JNIEnv *, jobject, jint bpm) {
    metronome.setBpm(bpm);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setSample(JNIEnv *env, jobject, jboolean isDownbeat,
                                             jstring sampleName) {
    metronome.setSample(isDownbeat, env->GetStringUTFChars(sampleName, nullptr));
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setState(JNIEnv *env, jobject, jint bpm,
                                            jstring downbeatSampleName,
                                            jstring subdivisionSampleName,
                                            jstring subdivisionsAsJsonString,
                                            jfloat volume) {
    metronome.setState(bpm, env->GetStringUTFChars(downbeatSampleName, nullptr),
                       env->GetStringUTFChars(subdivisionSampleName,
                                              nullptr),
                       env->GetStringUTFChars(subdivisionsAsJsonString,
                                              nullptr), volume);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setSubdivisionOption(JNIEnv *env, jobject, jstring key,
                                                        jint option) {
    metronome.setSubdivisionOption(env->GetStringUTFChars(key, nullptr), option);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setSubdivisionVolume(JNIEnv *env, jobject, jstring key,
                                                        jfloat volume) {
    metronome.setSubdivisionVolume(env->GetStringUTFChars(key, nullptr), volume);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_setVolume(JNIEnv *, jobject, jfloat volume) {
    metronome.setVolume(volume);
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_startPlayback(JNIEnv *, jobject) {
    metronome.startPlayback();
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_stopPlayback(JNIEnv *, jobject) {
    metronome.stopPlayback();
}

JNIEXPORT void JNICALL
Java_com_lvnlx_tempus_MainActivity_loadAudioFrames(JNIEnv *env, jobject, jstring fileName,
                                                   jfloatArray audioFrames) {
    jsize arrayFramesLength = env->GetArrayLength(audioFrames);
    jfloat *arrayFramesPointer = env->GetFloatArrayElements(audioFrames, nullptr);
    metronome.audioFrames[env->GetStringUTFChars(fileName, nullptr)] = Sample(
            std::vector<float>(arrayFramesPointer, arrayFramesPointer + arrayFramesLength),
            arrayFramesLength);
    env->ReleaseFloatArrayElements(audioFrames, arrayFramesPointer, 0);
}
}
