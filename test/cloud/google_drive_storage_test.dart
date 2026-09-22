import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:hmb_sailing_log/features/cloud/data/google_drive_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_testing;

/// Exercises `uploadToDrive`/`_ensureFolder` against a fake Drive REST API —
/// no real sign-in or network, just canned JSON responses keyed on method +
/// path, mirroring how strapi_transport_test.dart fakes Dio.
class _FakeDrive {
  _FakeDrive({
    this.existingFolders = const {},
    this.filesInFolder = const {},
    this.fileContents = const {},
  });

  /// Folder names the fake "already has" (id => name), so `files.list`
  /// returns a match instead of empty.
  final Map<String, String> existingFolders;

  /// Non-folder files the fake "already has" under a given parent id (`''`
  /// for root) — what `listDriveFiles` should see once the folder path
  /// resolves.
  final Map<String, List<Map<String, String>>> filesInFolder;

  /// Bytes `files.get(..., alt: media)` returns for a given file id.
  final Map<String, List<int>> fileContents;

  final List<http.Request> requests = [];
  var folderCreateCalls = 0;
  var uploadCalls = 0;

  drive.DriveApi get api => drive.DriveApi(http_testing.MockClient(_handle));

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final isUpload = request.url.path.contains('/upload/');
    final isMedia = request.url.queryParameters['alt'] == 'media';
    final isList = request.method == 'GET' && request.url.queryParameters.containsKey('q');

    if (isMedia) {
      final fileId = request.url.pathSegments.last;
      final bytes = fileContents[fileId];
      if (bytes == null) {
        return http.Response('no such file: $fileId', 404);
      }
      return http.Response.bytes(bytes, 200,
          headers: {'content-type': 'application/octet-stream'});
    }
    if (isList) {
      final q = request.url.queryParameters['q']!;
      final isFolderSearch = q.contains("mimeType = 'application/vnd.google-apps.folder'");
      if (isFolderSearch) {
        MapEntry<String, String>? match;
        for (final entry in existingFolders.entries) {
          if (q.contains("name = '${entry.value}'")) {
            match = entry;
            break;
          }
        }
        final files = match == null
            ? const <Map<String, String>>[]
            : [{'id': match.key, 'name': match.value}];
        return _json({'files': files});
      }
      // File listing (not a folder search): find which parent the query
      // asked for and return whatever's configured there.
      final parentId = q.contains("'root' in parents")
          ? ''
          : existingFolders.keys.firstWhere(
              (id) => q.contains("'$id' in parents"),
              orElse: () => '__none__',
            );
      return _json({'files': filesInFolder[parentId] ?? const []});
    }
    if (request.method == 'POST' && isUpload) {
      uploadCalls++;
      return _json({'id': 'uploaded-file-id', 'name': 'test.txt'});
    }
    if (request.method == 'POST') {
      folderCreateCalls++;
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({'id': 'created-${body['name']}', 'name': body['name']});
    }
    return http.Response('unexpected request: ${request.method} ${request.url}', 404);
  }

  http.Response _json(Object data) => http.Response(
        jsonEncode(data),
        200,
        headers: {'content-type': 'application/json'},
      );
}

void main() {
  late Directory tempDir;
  late File testFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('drive_test');
    testFile = File('${tempDir.path}/test.txt')..writeAsStringSync('hello drive');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  test('creates missing folders in the path, then uploads the file', () async {
    final fake = _FakeDrive();

    final fileId = await uploadToDrive(
      api: fake.api,
      file: testFile,
      fileName: 'test.txt',
      folderPath: const ['HMB Sailing Log', 'Plavba 2026'],
      mimeType: 'text/plain',
    );

    expect(fileId, 'uploaded-file-id');
    expect(fake.folderCreateCalls, 2, reason: 'both path segments were missing');
    expect(fake.uploadCalls, 1);
  });

  test('reuses an existing folder instead of creating a duplicate', () async {
    final fake = _FakeDrive(existingFolders: {'existing-id': 'HMB Sailing Log'});

    await uploadToDrive(
      api: fake.api,
      file: testFile,
      fileName: 'test.txt',
      folderPath: const ['HMB Sailing Log'],
      mimeType: 'text/plain',
    );

    expect(fake.folderCreateCalls, 0);
    expect(fake.uploadCalls, 1);
  });

  test('escapes a single quote in a folder name for the Drive query', () async {
    final fake = _FakeDrive();

    await uploadToDrive(
      api: fake.api,
      file: testFile,
      fileName: 'test.txt',
      folderPath: const ["Skipper's Trip"],
      mimeType: 'text/plain',
    );

    final listRequest = fake.requests.firstWhere(
      (r) => r.method == 'GET' && r.url.queryParameters.containsKey('q'),
    );
    expect(listRequest.url.queryParameters['q'], contains(r"Skipper\'s Trip"));
  });

  test('throws if the upload response has no file id', () async {
    final client = http_testing.MockClient((request) async {
      // No 'id' key — simulates a malformed/unexpected Drive response.
      return http.Response(jsonEncode({}), 200,
          headers: {'content-type': 'application/json'});
    });

    await expectLater(
      uploadToDrive(
        api: drive.DriveApi(client),
        file: testFile,
        fileName: 'test.txt',
        folderPath: const [],
        mimeType: 'text/plain',
      ),
      throwsStateError,
    );
  });

  group('listDriveFiles', () {
    test('returns empty when the folder was never created — no side effect',
        () async {
      final fake = _FakeDrive();

      final files = await listDriveFiles(
        api: fake.api,
        folderPath: const ['sync'],
      );

      expect(files, isEmpty);
      expect(fake.folderCreateCalls, 0,
          reason: 'listing must never create the folder it looked for');
    });

    test('lists files under an existing folder', () async {
      final fake = _FakeDrive(
        existingFolders: {'sync-id': 'sync'},
        filesInFolder: {
          'sync-id': [
            {'id': 'a', 'name': 'device-a.json', 'modifiedTime': '2026-09-01T10:00:00.000Z'},
            {'id': 'b', 'name': 'device-b.json'},
          ],
        },
      );

      final files = await listDriveFiles(api: fake.api, folderPath: const ['sync']);

      expect(files.map((f) => f.id), ['a', 'b']);
      expect(files.map((f) => f.name), ['device-a.json', 'device-b.json']);
      expect(files.first.modifiedTime, DateTime.utc(2026, 9, 1, 10));
      expect(files.last.modifiedTime, isNull);
    });

    test('lists root files when folderPath is empty', () async {
      final fake = _FakeDrive(filesInFolder: {
        '': [
          {'id': 'root-file', 'name': 'top.json'},
        ],
      });

      final files = await listDriveFiles(api: fake.api, folderPath: const []);

      expect(files.single.id, 'root-file');
    });
  });

  group('downloadFromDrive', () {
    test('returns the bytes of the requested file', () async {
      final fake = _FakeDrive(fileContents: {
        'file-id': utf8.encode('{"hello":"drive"}'),
      });

      final bytes = await downloadFromDrive(api: fake.api, fileId: 'file-id');

      expect(utf8.decode(bytes), '{"hello":"drive"}');
    });
  });
}
