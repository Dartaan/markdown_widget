import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:markdown/markdown.dart' as m;
import 'package:markdown_widget/markdown_widget.dart';

import 'html_support.dart';

class CustomTextNode extends ElementNode {
  final String text;
  final MarkdownConfig config;
  final WidgetVisitor visitor;
  bool isTable = false;

  CustomTextNode(this.text, this.config, this.visitor);

  @override
  InlineSpan build() {
    if (isTable) {
      //deal complex table tag with html core widget
      return WidgetSpan(
        child: HtmlWidget(text),
      );
    } else {
      return super.build();
    }
  }

  @override
  void onAccepted(SpanNode parent) {
    final textStyle = config.p.textStyle.merge(parentStyle);
    children.clear();
    if (!text.contains(htmlRep)) {
      // Создаем простой текстовый узел markdown
      final mTextNode = m.Text(text);
      accept(TextNode(text: text, style: textStyle), mTextNode);
      return;
    }
    //Intercept as table tag
    if (text.contains(tableRep)) {
      isTable = true;
      // Используем текущий markdownNode или создаем новый
      final mNode = markdownNode ?? m.Text(text);
      accept(parent, mNode);
      return;
    }

    //The remaining ones are processed by the regular HTML processing.
    // Создаем markdown узел из текста
    final mTextNode = m.Text(text);
    final spans = parseHtml(
      mTextNode,
      visitor: WidgetVisitor(
        config: visitor.config,
        generators: visitor.generators,
        richTextBuilder: visitor.richTextBuilder,
      ),
      parentStyle: parentStyle,
    );
    spans.forEach((element) {
      isTable = false;
      // Используем одинаковый markdown узел для всех элементов
      accept(element, mTextNode);
    });
  }
}
