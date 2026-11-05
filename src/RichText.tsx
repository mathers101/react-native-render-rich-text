import { useMemo } from 'react';
import { type NativeSyntheticEvent, type StyleProp, type ViewStyle } from 'react-native';
import NativeRichText, {
  type FactoidPressEvent,
  type LinkPressEvent,
  type MentionPressEvent,
  type Md4cFlagsInternal,
  type SelectionMenuConfig,
  type AccessibilityLabelsProps,
} from './EnrichedTiptapTextNativeComponent';
import { normalizeTiptapStyle } from './normalizeTiptapStyle';
import type { TiptapStyle } from './types/TiptapStyle';

export type TiptapMark = {
  type: string;
  attrs?: Record<string, unknown>;
};

export type TiptapNode = {
  type: string;
  text?: string;
  attrs?: Record<string, unknown>;
  marks?: TiptapMark[];
  content?: TiptapNode[];
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
  copyAsTiptap: false,
  copyImageUrl: false,
  copyLabel: 'Copy',
  copyAsTiptapLabel: 'Copy as Tiptap',
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

export type MentionTarget = {
  id: string;
  label: string;
};

export type RichTextProps = {
  /** Tiptap document, or the same document already encoded as JSON. */
  document: TiptapNode | string;
  /** Partial style for the nodes this library renders. Missing keys use defaults. */
  textStyle?: TiptapStyle;
  onLinkPress?: (url: string) => void;
  /** Called with the factoid's `id`. A factoid that contains a link emits `onLinkPress` instead. */
  onFactoidPress?: (factoidId: string) => void;
  /** Called with the mention node's `id` and `label`. */
  onMentionPress?: (mention: MentionTarget) => void;
  /** Called with the mention node's `id` and `label`. */
  onMentionLongPress?: (mention: MentionTarget) => void;
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
  onFactoidPress,
  onMentionPress,
  onMentionLongPress,
  maxFontSizeMultiplier,
  numberOfLines,
  ellipsizeMode,
  style,
}: RichTextProps) {
  const documentJson = typeof document === 'string' ? document : JSON.stringify(document);
  const tiptapStyle = useMemo(() => normalizeTiptapStyle(textStyle ?? {}), [textStyle]);
  const handleLinkPress = useMemo(() => {
    if (!onLinkPress) {
      return undefined;
    }
    return (event: NativeSyntheticEvent<LinkPressEvent>) => {
      onLinkPress(event.nativeEvent.url);
    };
  }, [onLinkPress]);
  const handleFactoidPress = useMemo(() => {
    if (!onFactoidPress) {
      return undefined;
    }
    return (event: NativeSyntheticEvent<FactoidPressEvent>) => {
      onFactoidPress(event.nativeEvent.factoidId);
    };
  }, [onFactoidPress]);
  const handleMentionPress = useMemo(() => {
    if (!onMentionPress) {
      return undefined;
    }
    return (event: NativeSyntheticEvent<MentionPressEvent>) => {
      onMentionPress({
        id: event.nativeEvent.mentionId,
        label: event.nativeEvent.label,
      });
    };
  }, [onMentionPress]);
  const handleMentionLongPress = useMemo(() => {
    if (!onMentionLongPress) {
      return undefined;
    }
    return (event: NativeSyntheticEvent<MentionPressEvent>) => {
      onMentionLongPress({
        id: event.nativeEvent.mentionId,
        label: event.nativeEvent.label,
      });
    };
  }, [onMentionLongPress]);

  return (
    <NativeRichText
      document={documentJson}
      tiptapStyle={tiptapStyle}
      md4cFlags={IGNORED_PARSER_FLAGS}
      selectionMenuConfig={SELECTION_MENU}
      accessibilityLabels={ACCESSIBILITY_LABELS}
      onLinkPress={handleLinkPress}
      selectable={selectable}
      allowFontScaling={allowFontScaling}
      onFactoidPress={handleFactoidPress}
      onMentionPress={handleMentionPress}
      onMentionLongPress={handleMentionLongPress}
      maxFontSizeMultiplier={maxFontSizeMultiplier}
      numberOfLines={numberOfLines}
      ellipsizeMode={ellipsizeMode}
      style={style}
    />
  );
}
