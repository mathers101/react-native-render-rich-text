import type { TiptapStyle } from './types/TiptapStyle';

const text = '#E6EDF3';
const textStrong = '#F0F6FC';
const textMuted = '#C9D1D9';
const textFaint = '#8B949E';
const border = '#30363D';
const surface = '#161B22';
const canvas = '#0D1117';

/**
 * Optional dark palette for `RichText`'s `textStyle`.
 * Colors only: font sizes, spacing, and other geometry stay on the built-in defaults.
 * Bold and italic are omitted so they keep inheriting the surrounding text color.
 */
export const darkModeTextStyle: TiptapStyle = {
  paragraph: { color: text },
  h1: { color: textStrong },
  h2: { color: textStrong },
  h3: { color: textStrong },
  h4: { color: textStrong },
  h5: { color: text },
  h6: { color: textMuted },
  blockquote: {
    color: textMuted,
    borderColor: border,
    backgroundColor: surface,
    admonitions: {
      note: { color: '#58A6FF', backgroundColor: '#0D1C2E' },
      tip: { color: '#3FB950', backgroundColor: '#0F2419' },
      important: { color: '#AB7DF8', backgroundColor: '#1C1428' },
      warning: { color: '#D29922', backgroundColor: '#2A2108' },
      caution: { color: '#F85149', backgroundColor: '#2D1214' },
    },
  },
  list: {
    color: text,
    bulletColor: textFaint,
    markerColor: textFaint,
  },
  codeBlock: {
    color: text,
    backgroundColor: canvas,
    borderColor: border,
    syntaxColors: {
      keyword: '#FF7B72',
      operator: text,
      punctuation: text,
      string: '#A5D6FF',
      number: '#79C0FF',
      constant: '#79C0FF',
      comment: textFaint,
      function: '#D2A8FF',
      type: '#FFA657',
      variable: text,
      property: '#79C0FF',
      tag: '#7EE787',
      attribute: '#79C0FF',
      embedded: text,
    },
  },
  link: { color: '#58A6FF', backgroundColor: 'transparent' },
  strikethrough: { color: textFaint },
  underline: { color: text },
  code: {
    color: '#FF7B72',
    backgroundColor: '#3D1F24',
    borderColor: '#6E3036',
  },
  factoid: {
    color: '#9BFC6E',
    backgroundColor: '#132E0F',
    borderColor: '#3FB950',
  },
  video: { backgroundColor: '#000000' },
  thematicBreak: { color: border },
  table: {
    color: text,
    headerBackgroundColor: surface,
    headerTextColor: textStrong,
    rowEvenBackgroundColor: canvas,
    rowOddBackgroundColor: surface,
    borderColor: border,
  },
  taskList: {
    checkedColor: '#58A6FF',
    borderColor: '#6E7681',
    checkmarkColor: '#FFFFFF',
    checkedTextColor: textFaint,
  },
  math: { color: text, backgroundColor: surface },
  inlineMath: { color: text },
  spoiler: { color: '#6E7681' },
  highlight: { color: '#1C1917', backgroundColor: '#FACC15' },
};
