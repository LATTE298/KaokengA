import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, debugPrint;
import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

// เครื่องเสียงสำรอง: TTS engine ในเครื่อง (Google TTS บน Android / speechSynthesis
// บนเว็บ) ใช้เมื่อ build โดยไม่มีคีย์ GOOGLE_TTS_API_KEY หรือ Cloud TTS ล้มเหลวกลางทาง
// คุณภาพเสียงด้อยกว่า Neural2 แต่ทำให้แอป "มีเสียงเสมอ" — สำคัญเพราะเด็กกลุ่มเป้าหมาย
// พึ่งเสียงเป็นช่องทางหลักในการเรียนรู้ และแท็บเล็ตบ้าน/โรงเรียนมักออฟไลน์
//
// สัญญาเดียวกับ TtsService: speak ครั้งใหม่ตัดเสียงเดิมเสมอ และห้าม throw ออกไปหา
// ผู้เรียก — เครื่องที่ไม่มีเสียงไทย/ไม่มี engine จะแค่เงียบพร้อม log ห้ามทำแอปล้ม
//
// ⚠️ ข้อเท็จจริงจากซอร์ส flutter_tts 4.2.5 ที่โค้ดนี้ต้องชดเชย (อย่าลบทิ้ง):
// 1) สเกล rate ต่างกันต่อแพลตฟอร์ม: เว็บส่งตรงเข้า utterance.rate (1.0 = ปกติ)
//    แต่ Android plugin คูณ 2 ให้ (0.5 = ปกติ) — ใช้ค่าเดียวกันไม่ได้
// 2) บนเว็บ _speak ถูก "ทิ้งเงียบๆ" ถ้าสถานะภายในยังเป็น playing และ _stop ไม่เซ็ต
//    สถานะเป็น stopped ทันที (รอ event onEnd/onError แบบ async) → ต้อง stop เอง
//    แล้วเว้นจังหวะสั้นๆ ก่อน speak ไม่งั้นคำใหม่หาย (อาการ "กดหลายครั้งกว่าจะพูด")
class DeviceTtsService implements TtsSpeaker {
  DeviceTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  Future<void>? _init;
  var _voiceChosen = false;
  var _generation = 0;
  var _disposed = false;

  Future<void> _ensureInit() {
    return _init ??= () async {
      await _tts.setLanguage('th-TH');
      if (kIsWeb) {
        // เว็บ: 1.0 = ความเร็วปกติ — 0.9 ช้ากว่านิดเดียวพอให้เด็กฟังทัน
        // (ห้ามใช้ 0.45 แบบ Android: จะกลายเป็นพูดยืดครึ่งเท่า เสียงแย่มาก)
        await _tts.setSpeechRate(0.9);
        // เสียง neural ของเบราว์เซอร์ไวต่อการดัด pitch → คงไว้ที่ธรรมชาติ
        await _tts.setPitch(1.0);
      } else {
        // Android: plugin คูณ 2 → engine ได้ 0.9 (ช้ากว่าปกติเล็กน้อย
        // เทียบเคียง speakingRate 0.9 ของฝั่ง Cloud — ดู GoogleTtsClient)
        await _tts.setSpeechRate(0.45);
        // เทียบเคียง pitch +2 semitone (~1.12 เท่า) ของฝั่ง Cloud
        await _tts.setPitch(1.1);
      }
    }();
  }

  // บนเว็บ setLanguage (utterance.lang) อย่างเดียวไม่พอ: ถ้าไม่ set voice ตรงๆ
  // เบราว์เซอร์มักหยิบ voice default ของระบบ (เช่น ภาษาอังกฤษ) มาอ่านข้อความไทย
  // → เงียบ/อ่านเพี้ยน ต้องไล่รายการ voice แล้วเลือกตัวภาษาไทยเอง โดยเลือกเสียง
  // neural ของเบราว์เซอร์ (ชื่อมี "Natural"/"Neural" เช่น Edge Premwadee) ก่อน
  // เสียง SAPI ธรรมดาซึ่งคุณภาพต่ำกว่ามาก
  //
  // ทำเฉพาะเว็บ: บน Android การ setLanguage เลือกเสียงไทยให้ถูกอยู่แล้ว
  //
  // คืน false เมื่อยังหาไม่เจอ (รายการ voice บนเว็บโหลดแบบ async อาจยังว่างช่วงแรก)
  // เพื่อให้ speak ครั้งถัดไปลองใหม่
  Future<bool> _pickThaiVoiceForWeb() async {
    try {
      final voices = await _tts.getVoices;
      if (voices is! List) return false;
      Map<dynamic, dynamic>? thaiVoice;
      for (final voice in voices) {
        if (voice is! Map) continue;
        final locale = (voice['locale'] ?? '').toString().toLowerCase();
        if (!locale.startsWith('th')) continue;
        thaiVoice ??= voice;
        final name = (voice['name'] ?? '').toString().toLowerCase();
        if (name.contains('natural') || name.contains('neural')) {
          thaiVoice = voice;
          break;
        }
      }
      if (thaiVoice == null) {
        if (kDebugMode) {
          debugPrint(
            'DeviceTts: no Thai voice in this browser yet '
            '(voices=${voices.length}) — will retry on next speak',
          );
        }
        return false;
      }
      await _tts.setVoice({
        'name': (thaiVoice['name'] ?? '').toString(),
        'locale': (thaiVoice['locale'] ?? '').toString(),
      });
      return true;
    } on Object catch (e, st) {
      developer.log(
        'DeviceTtsService voice lookup failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
      return false;
    }
  }

  @override
  Future<void> speak(String text) async {
    if (_disposed) return;
    final generation = ++_generation;
    try {
      await _ensureInit();
      if (kIsWeb && !_voiceChosen) {
        _voiceChosen = await _pickThaiVoiceForWeb();
      }
      // flush ของค้างเองเสมอ (latest wins) — โดยเฉพาะเว็บที่ plugin ไม่มีคิว/flush
      // และจะทิ้ง speak เงียบๆ ถ้าคิดว่ายังพูดอยู่ (ดูหมายเหตุหัวไฟล์ ข้อ 2)
      await _tts.stop();
      if (kIsWeb) {
        // รอ event ภายใน plugin เปลี่ยนสถานะเป็น stopped ก่อน ไม่งั้นคำใหม่โดนทิ้ง
        await Future<void>.delayed(const Duration(milliseconds: 80));
        // ระหว่างรอ อาจมีคำใหม่กว่าแทรกเข้ามาแล้ว — คำนี้กลายเป็นของเก่า ห้ามพูด
        if (_disposed || generation != _generation) return;
      }
      await _tts.speak(text);
    } on Object catch (e, st) {
      developer.log(
        'DeviceTtsService.speak failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
      // ทิ้งผล init ที่ล้มเหลว ให้ลองตั้งค่าใหม่รอบหน้า — เผื่อ engine เพิ่งพร้อมทีหลัง
      _init = null;
    }
  }

  @override
  Future<void> cancel() async {
    if (_disposed) return;
    _generation++;
    try {
      await _tts.stop();
    } on Object catch (e, st) {
      developer.log(
        'DeviceTtsService.cancel failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    _generation++;
    try {
      await _tts.stop();
    } on Object catch (e, st) {
      developer.log(
        'DeviceTtsService.dispose failed',
        name: 'tts',
        error: e,
        stackTrace: st,
      );
    }
  }
}
