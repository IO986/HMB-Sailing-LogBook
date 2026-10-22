/// Decides when the map camera should jump to a previewed voyage.
///
/// A preview can be started from outside the map (the route icon in the
/// voyage detail), and then the camera stayed where the boat is instead of
/// where the voyage is. The camera is moved once per preview, as soon as its
/// points are known, and never again: after that the person steers the map.
class PreviewFocusTracker {
  String? _focused;

  /// [key] identifies the preview (`null` when none is shown). Returns `true`
  /// exactly once per preview, when [hasPoints] first holds.
  bool shouldFocus(String? key, {required bool hasPoints}) {
    if (key == null) {
      // Leaving a preview forgets it, so previewing the same voyage again
      // centres the map again.
      _focused = null;
      return false;
    }
    if (!hasPoints || key == _focused) return false;
    _focused = key;
    return true;
  }
}
