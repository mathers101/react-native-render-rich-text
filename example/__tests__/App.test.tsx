import type {TiptapNode} from 'react-native-render-rich-text';
import {FIXTURES} from '../fixtures';

function walk(
  node: TiptapNode,
  types: Set<string>,
  marks: Set<string>,
  levels: Set<number>,
) {
  types.add(node.type);
  if (node.type === 'heading' && typeof node.attrs?.level === 'number') {
    levels.add(node.attrs.level);
  }
  for (const mark of node.marks ?? []) {
    marks.add(mark.type);
  }
  for (const child of node.content ?? []) {
    walk(child, types, marks, levels);
  }
}

test('ships one document for each supported screen', () => {
  expect(FIXTURES.map(item => item.id)).toEqual([
    'mixed',
    'lists',
    'code',
    'links',
    'long',
  ]);
  for (const fixture of FIXTURES) {
    expect(fixture.documents.length).toBeGreaterThan(0);
    for (const document of fixture.documents) {
      expect(document.type).toBe('doc');
      expect(document.content?.length).toBeGreaterThan(0);
    }
  }
});

test('the long tab is two documents and each contains a factoid', () => {
  const fixture = FIXTURES.find(item => item.id === 'long');
  expect(fixture?.documents).toHaveLength(2);
  for (const document of fixture!.documents) {
    const types = new Set<string>();
    walk(document, types, new Set(), new Set());
    expect(types.has('factoid')).toBe(true);
  }
});

test('the long document mixes every node the display path draws', () => {
  const fixture = FIXTURES.find(item => item.id === 'long');
  expect(fixture).toBeDefined();
  const types = new Set<string>();
  const marks = new Set<string>();
  const levels = new Set<number>();
  for (const document of fixture!.documents) {
    walk(document, types, marks, levels);
  }

  for (const type of [
    'heading',
    'paragraph',
    'text',
    'hardBreak',
    'factoid',
    'blockquote',
    'horizontalRule',
    'bulletList',
    'orderedList',
    'listItem',
    'codeBlock',
  ]) {
    expect(types.has(type)).toBe(true);
  }
  for (const mark of [
    'bold',
    'strong',
    'italic',
    'em',
    'strike',
    'strikethrough',
    'code',
    'underline',
    'highlight',
    'link',
  ]) {
    expect(marks.has(mark)).toBe(true);
  }
  expect([...levels].sort()).toEqual([1, 2, 3, 4, 5, 6]);
  expect(
    fixture!.documents.reduce(
      (count, document) => count + (document.content?.length ?? 0),
      0,
    ),
  ).toBeGreaterThan(15);
});
