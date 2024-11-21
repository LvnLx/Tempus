package com.lvnlx.tempus

import android.content.res.AssetManager
import java.io.InputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

class FileHandler(private val assetManager: AssetManager) {
    fun loadAudioFrames(fileName: String): FloatArray {
        val inputStream: InputStream = assetManager.open("flutter_assets/audio/${fileName}.wav")

        val byteArray: ByteArray = inputStream.readBytes()
        inputStream.close()

        val byteBuffer = ByteBuffer.wrap(byteArray)
        byteBuffer.order(ByteOrder.LITTLE_ENDIAN)

        byteBuffer.position(12)

        var descriptor: String
        var size: Int
        while (true) {
            descriptor = readDescriptor(byteBuffer)
            size = byteBuffer.getInt()

            if (descriptor == "data") break else byteBuffer.position(byteBuffer.position() + size)
        }

        val floatArray = FloatArray(size / 4)
        for (i in floatArray.indices) {
            floatArray[i] = byteBuffer.getFloat()
        }

        return floatArray
    }

    private fun readDescriptor(byteBuffer: ByteBuffer): String {
        val descriptorChars = CharArray(4)
        for (i in descriptorChars.indices) {
            descriptorChars[i] = byteBuffer.get().toInt().toChar()
        }
        return String(descriptorChars)
    }
}