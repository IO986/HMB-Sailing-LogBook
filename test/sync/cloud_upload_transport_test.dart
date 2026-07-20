import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/features/cloud/domain/cloud_storage_provider.dart';
import 'package:hmb_sailing_log/sync/cloud_upload_transport.dart';
import 'package:hmb_sailing_log/sync/sync_entity_types.dart';

class _FakeCloudStorageProvider implements CloudStorageProvider {
  _FakeCloudStorageProvider({this.signedIn = true, this.uploadError});

  bool signedIn;
  Object? uploadError;
  final List<String> uploadedFileNames = [];
  final List<List<String>> uploadedFolderPaths = [];

  @override
  String get id => 'fake';

  @override
  String get displayName => 'Fake';

  @override
  Future<CloudAccount?> get currentAccount async =>
      signedIn ? const CloudAccount(email: 'skipper@example.com') : null;

  @override
  bool get isSignedInNow => signedIn;

  @override
  Future<CloudAccount?> signIn() async => const CloudAccount(email: 'skipper@example.com');

  @override
  Future<void> signOut() async => signedIn = false;

  @override
  Future<String> upload({
    required File file,
    required String fileName,
    required List<String> folderPath,
    required String mimeType,
  }) async {
    if (uploadError != null) throw uploadError!;
    uploadedFileNames.add(fileName);
    uploadedFolderPaths.add(folderPath);
    return 'uploaded-${uploadedFileNames.length}';
  }
}

void main() {
  late Directory tempDir;
  late File pdfFile;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('cloud_upload_test');
    pdfFile = File('${tempDir.path}/day.pdf')..writeAsBytesSync([1, 2, 3]);
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  OutboxItem itemWithAttachment({String id = 'item-1'}) => OutboxItem(
        id: id,
        entityType: SyncEntityType.cloudExport,
        entityId: 'day-1-pdf',
        operation: SyncOperation.create,
        payload: const {
          'kind': 'day_pdf',
          'dayLogId': 1,
          'folder': ['HMB Sailing Log', 'Plavba 2026'],
        },
        attachments: [
          Attachment(
            localPath: pdfFile.path,
            field: 'file',
            mimeType: 'application/pdf',
            sizeBytes: 3,
          ),
        ],
        createdAt: DateTime.now().toUtc(),
      );

  test('uploads and reports success with the provider\'s file id', () async {
    final provider = _FakeCloudStorageProvider();
    final transport = CloudUploadTransport(provider: provider);

    final results = await transport.push([itemWithAttachment()]);

    expect(results, hasLength(1));
    expect(results.single.outcome, SyncItemOutcome.success);
    expect(results.single.remoteId, 'uploaded-1');
    expect(provider.uploadedFileNames.single, 'day.pdf');
    expect(provider.uploadedFolderPaths.single, ['HMB Sailing Log', 'Plavba 2026']);
  });

  test('not signed in defers every item without calling upload at all', () async {
    final provider = _FakeCloudStorageProvider(signedIn: false);
    final transport = CloudUploadTransport(provider: provider);

    final results = await transport.push([itemWithAttachment()]);

    expect(results.single.outcome, SyncItemOutcome.deferred);
    expect(provider.uploadedFileNames, isEmpty);
  });

  test('a thrown exception from upload() is a retryable failure', () async {
    final provider = _FakeCloudStorageProvider(uploadError: Exception('network blip'));
    final transport = CloudUploadTransport(provider: provider);

    final results = await transport.push([itemWithAttachment()]);

    expect(results.single.outcome, SyncItemOutcome.failure);
    expect(results.single.retryable, isTrue);
  });

  test('an item with no attachment fails without being retried', () async {
    final provider = _FakeCloudStorageProvider();
    final transport = CloudUploadTransport(provider: provider);
    final noAttachmentItem = OutboxItem(
      id: 'item-2',
      entityType: SyncEntityType.cloudExport,
      operation: SyncOperation.create,
      payload: const {},
      createdAt: DateTime.now().toUtc(),
    );

    final results = await transport.push([noAttachmentItem]);

    expect(results.single.outcome, SyncItemOutcome.failure);
    expect(results.single.retryable, isFalse);
  });
}
