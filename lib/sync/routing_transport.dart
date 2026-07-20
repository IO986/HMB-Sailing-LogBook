import 'package:hmb_core/hmb_core.dart' hide LocationService;

import 'sync_entity_types.dart';

/// Splits a batch by `entityType` between the cloud-export branch and
/// everything else, then merges the results — see `docs/plan_cloud_export.md`
/// §1. Deliberately thin: no policy logic of its own. Each branch passed in
/// is expected to already be wrapped in its own `SyncPolicyTransport`, with
/// its own enable toggle — that's what lets disabling backend sync leave
/// cloud export running, and vice versa.
class RoutingTransport implements SyncTransport {
  RoutingTransport({required this.cloudTransport, required this.defaultTransport});

  final SyncTransport cloudTransport;
  final SyncTransport defaultTransport;

  @override
  // A handful of files a day for either branch — no need to sub-batch here,
  // each inner transport already has its own batchSize.
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async {
    final cloudOk = await cloudTransport.isReachable();
    if (cloudOk) return true;
    return defaultTransport.isReachable();
  }

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async {
    final cloudItems = <OutboxItem>[];
    final otherItems = <OutboxItem>[];
    for (final item in batch) {
      (item.entityType == SyncEntityType.cloudExport ? cloudItems : otherItems).add(item);
    }

    // Sequential, not Future.wait: volume is a handful of items a day, and
    // this keeps the two branches from racing each other's HTTP clients
    // for no benefit. The engine pairs results by itemId, not by the order
    // returned here (see SyncTransport.push's contract).
    final cloudResults = await cloudTransport.push(cloudItems);
    final otherResults = await defaultTransport.push(otherItems);
    return [...cloudResults, ...otherResults];
  }
}
