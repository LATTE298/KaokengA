import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:flutter/services.dart' show AssetBundle, rootBundle;

import 'tts_service.dart';

const String kTtsAssetDir = 'assets/tts';
const String kTtsManifestPath = '$kTtsAssetDir/tts_manifest.json';

// client เสียงไทยอัดล่วงหน้า (เจนจาก Google AI Studio — ดู docs/TTS_CLIPS.md):
// หาไฟล์ใน assets/tts/ ตาม manifest ก่อน โดย key ของ manifest คือ "ข้อความที่พูด
// ตรงเป๊ะทุกตัวอักษร" — ไม่อยู่ใน manifest หรือไฟล์ยังไม่ถูกวาง จะส่งต่อ [network]
// (GoogleTtsClient เมื่อมีคีย์ / NoOpTtsClient เมื่อไม่มี ซึ่งคืนค่าว่างแล้ว TtsService
// จะตกไปใช้เสียง engine ในเครื่องเอง) — ทีมจึงทยอยเติมไฟล์เสียงทีละคลิปได้ แอปไม่พัง
class BundledTtsClient implements TtsClient {
  BundledTtsClient({TtsClient? network, AssetBundle? bundle})
    : _network = network,
      _bundle = bundle ?? rootBundle;

  final TtsClient? _network;
  final AssetBundle _bundle;
  Future<Map<String, String>>? _manifest;

  Future<Map<String, String>> _loadManifest() {
    return _manifest ??= () async {
      try {
        final raw = await _bundle.loadString(kTtsManifestPath);
        final decoded = jsonDecode(raw);
        final clips = decoded is Map<String, dynamic> ? decoded['clips'] : null;
        if (clips is! Map) return const <String, String>{};
        return clips.map(
          (key, value) => MapEntry(key.toString(), value.toString()),
        );
      } on Object catch (e, st) {
        developer.log(
          'BundledTtsClient manifest load failed',
          name: 'tts',
          error: e,
          stackTrace: st,
        );
        return const <String, String>{};
      }
    }();
  }

  @override
  Future<Uint8List> synthesize(String text) async {
    final manifest = await _loadManifest();
    final fileName = manifest[text];
    if (fileName != null) {
      try {
        final data = await _bundle.load('$kTtsAssetDir/$fileName');
        return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      } on Object {
        // อยู่ใน manifest แต่ไฟล์เสียงยังไม่ถูกวาง — ใช้ทางถัดไปเงียบๆ
      }
    }
    final network = _network;
    if (network == null) {
      throw TtsException('no bundled audio for "$text"');
    }
    return network.synthesize(text);
  }
}
