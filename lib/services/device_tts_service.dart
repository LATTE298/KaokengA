import 'dart:developer' as developer;

import 'package:flutter_tts/flutter_tts.dart';

import 'tts_service.dart';

// เครื่องเสียงสำรอง: TTS engine ในเครื่อง (Google TTS บน Android / speechSynthesis
// บนเว็บ) ใช้เมื่อ build โดยไม่มีคีย์ GOOGLE_TTS_API_KEY หรือ Cloud TTS ล้มเหลวกลางทาง
// คุณภาพเสียงด้อยกว่า Neural2 แต่ทำให้แอป "มีเสียงเสมอ" — สำคัญเพราะเด็กกลุ่มเป้าหมาย
// พึ่งเสียงเป็นช่องทางหลักในการเรียนรู้ และแท็บเล็ตบ้าน/โรงเรียนมักออฟไลน์
//
// สัญญาเดียวกับ TtsService: speak ครั้งใหม่ตัดเสียงเดิมเสมอ (engine ใช้ QUEUE_FLUSH
// เป็นค่าเริ่มต้นอยู่แล้ว) และห้าม throw ออกไปหาผู้เรียก — เครื่องที่ไม่มีเสียงไทย/
// ไม่มี engine จะแค่เงียบพร้อม log ห้ามทำแอปล้ม
class DeviceTtsService implements TtsSpeaker {
  DeviceTtsService([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  Future<void>? _init;
  var _disposed = false;

  Future<void> _ensureInit() {
    return _init ??= () async {
      await _tts.setLanguage('th-TH');
      // สเกลของ flutter_tts: 0.5 = ความเร็วปกติ — ช้ากว่าปกติเล็กน้อยให้เด็กฟังทัน
      // เทียบเคียง speakingRate 0.9 ของฝั่ง Cloud (ดู GoogleTtsClient)
      await _tts.setSpeechRate(0.45);
      // เทียบเคียง pitch +2 semitone (~1.12 เท่า) ของฝั่ง Cloud ให้โทนเสียงใกล้กัน
      await _tts.setPitch(1.1);
    }();
  }

  @override
  Future<void> speak(String text) async {
    if (_disposed) return;
    try {
      await _ensureInit();
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
