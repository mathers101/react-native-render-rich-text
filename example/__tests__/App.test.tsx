import {FIXTURES} from '../fixtures';

test('ships one document for each supported screen', () => {
  expect(FIXTURES.map(item => item.id)).toEqual([
    'mixed',
    'lists',
    'code',
    'links',
  ]);
  for (const fixture of FIXTURES) {
    expect(fixture.document.type).toBe('doc');
    expect(fixture.document.content?.length).toBeGreaterThan(0);
  }
});
