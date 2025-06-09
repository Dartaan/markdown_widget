import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:markdown_widget/toc_widget.dart';

import '../widget/blocks/leaf/heading.dart';
import '../widget/markdown.dart';

///[TocController] combines [TocWidget] and [MarkdownWidget],
///you can use it to control the jump between the two,
/// and each [TocWidget] corresponds to a [MarkdownWidget].
class TocController extends ChangeNotifier {
  ///key is index of widgets, value is [Toc]
  final LinkedHashMap<int, Toc> _index2toc = LinkedHashMap();

  final ValueNotifier<int?> currentScrollIndex = ValueNotifier(null);
  final ValueNotifier<int?> jumpIndex = ValueNotifier(null);

  List<Toc> get tocList => _index2toc.values.toList(growable: false);

  void setTocList(List<Toc> list) {
    _index2toc
      ..clear()
      ..addEntries(list.map((e) => MapEntry(e.widgetIndex, e)));
    notifyListeners();
  }

  void onScrollIndexChanged(int index) {
    currentScrollIndex.value = getTocByWidgetIndex(index)?.widgetIndex;
  }

  int? getNodeIndex(HeadingNode node) {
    for (var entry in _index2toc.entries) {
      if (entry.value.node == node) {
        return entry.key;
      }
    }
    return null;
  }

  void jumpToIndex(int index) {
    jumpIndex.value = getTocByWidgetIndex(index)?.widgetIndex;
  }

  void jumpToWidgetIndex(int widgetIndex) {
    jumpIndex.value = widgetIndex;
  }

  Toc? getTocByWidgetIndex(int index) {
    if (_index2toc.containsKey(index)) {
      return _index2toc[index];
    }
    return null;
  }

  /// Find a Toc entry by its slug
  Toc? getTocBySlug(String slug) {
    for (var toc in _index2toc.values) {
      if (toc.slug == slug) {
        return toc;
      }
    }
    return null;
  }

  /// Jump to a heading identified by its slug
  void jumpToSlug(String slug) {
    final toc = getTocBySlug(slug);
    if (toc != null) {
      jumpIndex.value = toc.widgetIndex;
    }
  }

  @override
  void dispose() {
    currentScrollIndex.dispose();
    jumpIndex.dispose();
    super.dispose();
  }
}

///config for toc
class Toc {
  ///the HeadingNode
  final HeadingNode node;

  ///index of [MarkdownGenerator]'s _children
  final int widgetIndex;

  ///index of [TocController.tocList]
  final int selfIndex;

  /// URL-friendly slug generated from heading text
  late final String? slug;

  Toc({
    required this.node,
    this.widgetIndex = 0,
    this.selfIndex = 0,
  }) {
    // Generate slug from heading text
    slug = generateSlug(node.textContent);
  }

  /// Generates a URL-friendly slug from heading text
  static String? generateSlug(String? text) {
    if (text == null || text.isEmpty) return null;
    
    // Convert to lowercase, replace spaces with hyphens, remove special characters
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '') // Remove special characters
        .replaceAll(RegExp(r'\s+'), '-')     // Replace spaces with hyphens
        .replaceAll(RegExp(r'-+'), '-')      // Replace multiple hyphens with single hyphen
        .trim();
  }
}
