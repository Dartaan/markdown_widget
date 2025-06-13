import 'package:flutter/material.dart';
import 'package:markdown/markdown.dart' as m show Node;

///the basic node
abstract class SpanNode {
  InlineSpan build();

  SpanNode? _parent;

  TextStyle? style;

  m.Node? _markdownNode;

  TextStyle? get parentStyle => _parent?.style;

  SpanNode? get parent => _parent;

  m.Node? get markdownNode => _markdownNode;

  ///use [_acceptParent] to accept a parent
  void _acceptParent(SpanNode node, m.Node markdownNode) {
    _parent = node;
    _markdownNode = markdownNode;
    onAccepted(node);
  }

  ///when this node was accepted by it's parent, [onAccepted] will be triggered
  void onAccepted(SpanNode parent) {}
}

///this node will accept other SpanNode as children
abstract class ElementNode extends SpanNode {
  final List<SpanNode> children = [];

  ///use [accept] to add a child
  void accept(SpanNode? node, m.Node markdownNode) {
    if (node != null) children.add(node);
    node?._acceptParent(this, markdownNode);
  }

  @override
  InlineSpan build() => childrenSpan;

  TextSpan get childrenSpan => TextSpan(
      children:
          List.generate(children.length, (index) => children[index].build()));
}

///the default concrete node for ElementNode
class ConcreteElementNode extends ElementNode {
  final String tag;

  ConcreteElementNode({this.tag = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() => childrenSpan;
}

///text node only displays text
class TextNode extends SpanNode {
  final String text;

  TextNode({this.text = '', TextStyle? style}) {
    this.style = style ?? const TextStyle();
  }

  @override
  InlineSpan build() => TextSpan(text: text, style: style?.merge(parentStyle));
}
