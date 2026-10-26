import { useMemo } from 'react';
import {
  type NativeSyntheticEvent,
  type StyleProp,
  type ViewStyle,
} from 'react-native';
import NativeRichText, {
  type LinkPressEvent,
  type Md4cFlagsInternal,
  type SelectionMenuConfig,
  type AccessibilityLabelsProps,
} from './EnrichedMarkdownTextNativeComponent';
import { normalizeMarkdownStyle } from './normalizeMarkdownStyle';
import type { MarkdownStyle } from './types/MarkdownStyle';

export type TipTapMark = {
  type: string;
  attrs?: Record<string, unknown>;
};

export type TipTapNode = {
  type: string;
  text?: string;
  attrs?: Record<string, unknown>;
  marks?: TipTapMark[];
  content?: TipTapNode[];
};

const IGNORED_PARSER_FLAGS: Md4cFlagsInternal = {
  underline: false,
  superscript: false,
  subscript: false,
  latexMath: false,
  highlight: false,
  hardSoftBreaks: false,
  preserveBlankLines: false,
  admonitions: false,
};

const SELECTION_MENU: SelectionMenuConfig = {
  copyAsMarkdown: false,
  copyImageUrl: false,
  copyLabel: 'Copy',
  copyAsMarkdownLabel: 'Copy as Markdown',
  copyImageUrlLabel: 'Copy Image URL',
  copyImageUrlsLabel: 'Copy {count} Image URLs',
  copyImageUrlPluralTemplates: [],
};

const ACCESSIBILITY_LABELS: AccessibilityLabelsProps = {
  list: {
    bulletPoint: 'bullet',
    nestedBulletPoint: 'nested bullet',
    orderedItem: 'item {index}',
    nestedOrderedItem: 'nested item {index}',
  },
  blockquote: {
    quote: 'quote',
    nestedQuote: 'nested quote',
  },
  table: { row: 'row' },
  math: { equation: 'equation' },
  codeBlock: { wrap: 'wrap', unwrap: 'unwrap' },
  rotor: { headings: 'headings', links: 'links', images: 'images' },
};

export type RichTextProps = {
  /** TipTap document, or the same document already encoded as JSON. */
  document: TipTapNode | string;
  /** Partial style for the nodes this library renders. Missing keys use defaults. */
  textStyle?: MarkdownStyle;
  onLinkPress?: (url: string) => void;
  selectable?: boolean;
  allowFontScaling?: boolean;
  maxFontSizeMultiplier?: number;
  numberOfLines?: number;
  ellipsizeMode?: 'head' | 'middle' | 'tail' | 'clip';
  style?: StyleProp<ViewStyle>;
};

export function RichText({
  document,
  textStyle,
  onLinkPress,
  selectable = true,
  allowFontScaling = true,
  maxFontSizeMultiplier,
  numberOfLines,
  ellipsizeMode,
  style,
}: RichTextProps) {
  const documentJson =
    typeof document === 'string' ? document : JSON.stringify(document);
  const markdownStyle = useMemo(
    () => normalizeMarkdownStyle(textStyle ?? {}),
    [textStyle]
  );
  const handleLinkPress = useMemo(() => {
    if (!onLinkPress) {
      return undefined;
    }
    return (event: NativeSyntheticEvent<LinkPressEvent>) => {
      onLinkPress(event.nativeEvent.url);
    };
  }, [onLinkPress]);

  return (
    <NativeRichText
      document={documentJson}
      markdownStyle={markdownStyle}
      md4cFlags={IGNORED_PARSER_FLAGS}
      selectionMenuConfig={SELECTION_MENU}
      accessibilityLabels={ACCESSIBILITY_LABELS}
      onLinkPress={handleLinkPress}
      selectable={selectable}
      allowFontScaling={allowFontScaling}
      maxFontSizeMultiplier={maxFontSizeMultiplier}
      numberOfLines={numberOfLines}
      ellipsizeMode={ellipsizeMode}
      style={style}
    />
  );
}
