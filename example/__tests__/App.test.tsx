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
    expect(fixture.document.type).toBe('doc');
    expect(fixture.document.content?.length).toBeGreaterThan(0);
  }
});

test('the long document mixes every node the display path draws', () => {
  const fixture = FIXTURES.find(item => item.id === 'long');
  expect(fixture).toBeDefined();
  const types = new Set<string>();
  const marks = new Set<string>();
  const levels = new Set<number>();
  walk(fixture!.document, types, marks, levels);

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
  expect(fixture!.document.content!.length).toBeGreaterThan(15);
});
