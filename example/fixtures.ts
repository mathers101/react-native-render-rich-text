import type { TipTapNode } from 'react-native-render-rich-text';

export type FixtureId = 'mixed' | 'lists' | 'code' | 'links';

export const FIXTURES: {
  id: FixtureId;
  label: string;
  document: TipTapNode;
}[] = [
  {
    id: 'mixed',
    label: 'Mixed',
    document: {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 1 },
          content: [{ type: 'text', text: 'Ridge notes' }],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'The trail was ' },
            { type: 'text', text: 'quiet', marks: [{ type: 'italic' }] },
            { type: 'text', text: ' until ' },
            {
              type: 'factoid',
              attrs: {
                id: 'saddle-wind',
              },
              content: [
                { type: 'text', text: 'a gust ', marks: [] },
                {
                  type: 'text',
                  text: 'of',
                  marks: [{ type: 'italic' }, { type: 'underline' }],
                },
                { type: 'text', text: ' wind', marks: [{ type: 'bold' }] },
              ],
            },
            { type: 'text', text: ' came over the saddle. ' },
            {
              type: 'text',
              text: 'Marked',
              marks: [{ type: 'highlight' }],
            },
            { type: 'text', text: ' cairns, a ' },
            {
              type: 'text',
              text: 'closed',
              marks: [{ type: 'strike' }],
            },
            { type: 'text', text: ' spur, and one ' },
            {
              type: 'text',
              text: 'underlined',
              marks: [{ type: 'underline' }],
            },
            { type: 'text', text: ' turn.' },
          ],
        },
        {
          type: 'blockquote',
          content: [
            {
              type: 'paragraph',
              content: [
                {
                  type: 'text',
                  text: 'Leave the gate as you found it.',
                },
              ],
            },
          ],
        },
        { type: 'horizontalRule' },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Water at the second switchback. ' },
            {
              type: 'text',
              text: 'Pack weight',
              marks: [{ type: 'bold' }, { type: 'italic' }],
            },
            { type: 'text', text: ' stays under twelve kilos.' },
          ],
        },
      ],
    },
  },
  {
    id: 'lists',
    label: 'Lists',
    document: {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'Before you leave' }],
        },
        {
          type: 'bulletList',
          content: [
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [{ type: 'text', text: 'Filter two liters' }],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    { type: 'text', text: 'Check the ' },
                    {
                      type: 'text',
                      text: 'headlamp',
                      marks: [{ type: 'bold' }],
                    },
                  ],
                },
              ],
            },
          ],
        },
        {
          type: 'heading',
          attrs: { level: 3 },
          content: [{ type: 'text', text: 'Cache order' }],
        },
        {
          type: 'orderedList',
          attrs: { start: 1 },
          content: [
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [{ type: 'text', text: 'North col' }],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [{ type: 'text', text: 'Lake shelf' }],
                },
              ],
            },
          ],
        },
      ],
    },
  },
  {
    id: 'code',
    label: 'Code',
    document: {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'Call the parser' }],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Pass the document to ' },
            { type: 'text', text: 'RichText', marks: [{ type: 'code' }] },
            { type: 'text', text: ' and keep the language on the fence.' },
          ],
        },
        {
          type: 'codeBlock',
          attrs: { language: 'ts' },
          content: [
            {
              type: 'text',
              text: 'const document = { type: "doc", content: [] };\nrender(document);',
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'The fence is stored. Nothing is highlighted.',
            },
          ],
        },
      ],
    },
  },
  {
    id: 'links',
    label: 'Links',
    document: {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [{ type: 'text', text: 'On the map' }],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'The forecast lives at ' },
            {
              type: 'text',
              text: 'the ridge station',
              marks: [
                {
                  type: 'link',
                  attrs: { href: 'https://example.com/ridge' },
                },
              ],
            },
            { type: 'text', text: '. After dark, read ' },
            {
              type: 'text',
              text: 'the hut log',
              marks: [
                {
                  type: 'link',
                  attrs: { href: 'https://example.com/hut' },
                },
                { type: 'bold' },
              ],
            },
            { type: 'text', text: '.' },
          ],
        },
      ],
    },
  },
];
