import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:crypto/crypto.dart';

class CryptoEngine {
  static const int _chunkSize = 1024 * 1024; // 1MB Chunks

  static enc.Key deriveKeyFromPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return enc.Key(Uint8List.fromList(digest.bytes));
  }

  static Future<void> encryptFile({
    required File sourceFile,
    required File targetFile,
    required enc.Key encryptionKey,
    required enc.IV initializationVector,
    Function(double progress)? onProgress,
  }) async {
    final encrypter = enc.Encrypter(enc.AES(encryptionKey, mode: enc.AESMode.cbc));
    final int totalBytes = await sourceFile.length();
    final RandomAccessFile sourceStream = await sourceFile.open(mode: FileMode.read);
    final RandomAccessFile targetStream = await targetFile.open(mode: FileMode.write);

    try {
      int bytesProcessed = 0;
      await targetStream.writeFrom(initializationVector.bytes);

      while (bytesProcessed < totalBytes) {
        final int remaining = totalBytes - bytesProcessed;
        final int currentChunkSize = remaining > _chunkSize ? _chunkSize : remaining;
        
        final Uint8List chunk = await sourceStream.read(currentChunkSize);
        final enc.Encrypted encryptedChunk = encrypter.encryptBytes(chunk, iv: initializationVector);
        
        final Uint8List frameSizeBuffer = Uint8List(4);
        ByteData.view(frameSizeBuffer.buffer).setUint32(0, encryptedChunk.bytes.length);
        
        await targetStream.writeFrom(frameSizeBuffer);
        await targetStream.writeFrom(encryptedChunk.bytes);
        
        bytesProcessed += currentChunkSize;
        if (onProgress != null && totalBytes > 0) {
          onProgress(bytesProcessed / totalBytes);
        }
      }
    } finally {
      await sourceStream.close();
      await targetStream.close();
    }
  }

  static Future<void> decryptFile({
    required File encryptedSource,
    required File decryptedTarget,
    required enc.Key encryptionKey,
    Function(double progress)? onProgress,
  }) async {
    final int totalBytes = await encryptedSource.length();
    final RandomAccessFile sourceStream = await encryptedSource.open(mode: FileMode.read);
    final RandomAccessFile targetStream = await decryptedTarget.open(mode: FileMode.write);

    try {
      final Uint8List ivBytes = await sourceStream.read(16);
      final enc.IV iv = enc.IV(ivBytes);
      final encrypter = enc.Encrypter(enc.AES(encryptionKey, mode: enc.AESMode.cbc));
      
      int bytesProcessed = 16;

      while (bytesProcessed < totalBytes) {
        final Uint8List frameSizeBuffer = await sourceStream.read(4);
        if (frameSizeBuffer.length < 4) break;
        
        final int frameSize = ByteData.view(frameSizeBuffer.buffer).getUint32(0);
        final Uint8List encryptedFrame = await sourceStream.read(frameSize);
        
        final List<int> decryptedChunk = encrypter.decryptBytes(enc.Encrypted(encryptedFrame), iv: iv);
        await targetStream.writeFrom(decryptedChunk);
        
        bytesProcessed += 4 + frameSize;
        if (onProgress != null && totalBytes > 0) {
          onProgress(bytesProcessed / totalBytes);
        }
      }
    } finally {
      await sourceStream.close();
      await targetStream.close();
    }
  }
}
