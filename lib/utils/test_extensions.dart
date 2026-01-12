import 'package:flutter/material.dart';

extension MaestroTestable on Widget {
  /// Crash-safe test id wrapper
  Widget withId(String id) {
    // Do NOT wrap ParentDataWidgets
    if (this is ParentDataWidget) {
      return this;
    }

    return Semantics(
      identifier: id,
      explicitChildNodes: true,
      container: true,
      child: this,
    );
  }
}
