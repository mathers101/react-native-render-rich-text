import type { TiptapNode } from 'react-native-render-rich-text';

export type FixtureId = 'mixed' | 'lists' | 'code' | 'links' | 'long';

export const FIXTURES: {
  id: FixtureId;
  label: string;
  documents: TiptapNode[];
}[] = [
  {
    id: 'mixed',
    label: 'Mixed',
    documents: [
      {
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
            { type: 'text', text: 'quiet ', marks: [{ type: 'italic' }] },
            { type: 'text', text: 'until, out of nowhere, a ' },
            {
              type: 'factoid',
              attrs: {
                id: 'saddle-wind',
              },
              content: [
                {
                  type: 'text',
                  text: 'sweltering gust ',
                  marks: [],
                },
                {
                  type: 'text',
                  text: 'of',
                  marks: [{ type: 'underline' }],
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
      ],
  },
  {
    id: 'lists',
    label: 'Lists',
    documents: [
      {
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
    ],
  },
  {
    id: 'code',
    label: 'Code',
    documents: [
      {
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
      ],
  },
  {
    id: 'links',
    label: 'Links',
    documents: [
      {
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
      ],
  },
  {
    id: 'long',
    label: 'Long',
    documents: [
      {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 1 },
          content: [{ type: 'text', text: 'The long ridge' }],
        },
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'We left the hut while the valley was still ',
            },
            { type: 'text', text: 'dark', marks: [{ type: 'italic' }] },
            { type: 'text', text: ', with the ' },
            { type: 'text', text: 'pack', marks: [{ type: 'bold' }] },
            { type: 'text', text: ' already settled and one ' },
            {
              type: 'factoid',
              attrs: { id: 'saddle-gust' },
              content: [
                { type: 'text', text: 'gust' },
                { type: 'text', text: ' of wind', marks: [{ type: 'italic' }] },
              ],
            },
            { type: 'text', text: ' waiting on the saddle. The ' },
            {
              type: 'text',
              text: 'old spur',
              marks: [{ type: 'strike' }],
            },
            { type: 'text', text: ' is closed. Follow the ' },
            {
              type: 'text',
              text: 'underlined',
              marks: [{ type: 'underline' }],
            },
            { type: 'text', text: ' cairns, and treat the ' },
            {
              type: 'text',
              text: 'second switchback',
              marks: [{ type: 'highlight' }],
            },
            {
              type: 'text',
              text: ' as the place to stop for water. The forecast lives at ',
            },
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
            { type: 'text', text: '.' },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Pass the notes through ' },
            { type: 'text', text: 'RichText', marks: [{ type: 'code' }] },
            { type: 'text', text: ' and keep ' },
            {
              type: 'text',
              text: 'both hands',
              marks: [{ type: 'strong' }, { type: 'em' }],
            },
            {
              type: 'text',
              text: ' on the poles once the scree starts. The ',
            },
            {
              type: 'text',
              text: 'closed fork',
              marks: [{ type: 'strikethrough' }],
            },
            { type: 'text', text: ' below the lake is not the way.' },
          ],
        },
        {
          type: 'heading',
          attrs: { level: 2 },
          content: [
            { type: 'text', text: 'Leaving the ' },
            { type: 'text', text: 'hut', marks: [{ type: 'italic' }] },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Hut log, 4:40.' },
            { type: 'hardBreak' },
            {
              type: 'text',
              text: 'Wind from the west, steady enough to lean on.',
            },
            { type: 'hardBreak' },
            {
              type: 'text',
              text: 'Leave the stove cold and the latch as you found it.',
            },
          ],
        },
        {
          type: 'bulletList',
          content: [
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    { type: 'text', text: 'Filter two liters before the gate' },
                  ],
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
                    { type: 'text', text: ' and the spare ' },
                    { type: 'text', text: 'cell', marks: [{ type: 'code' }] },
                  ],
                },
                {
                  type: 'bulletList',
                  content: [
                    {
                      type: 'listItem',
                      content: [
                        {
                          type: 'paragraph',
                          content: [
                            {
                              type: 'text',
                              text: 'Batteries in the lid pocket',
                            },
                          ],
                        },
                      ],
                    },
                    {
                      type: 'listItem',
                      content: [
                        {
                          type: 'paragraph',
                          content: [
                            { type: 'text', text: 'Tape listed on ' },
                            {
                              type: 'text',
                              text: 'the cache note',
                              marks: [
                                {
                                  type: 'link',
                                  attrs: { href: 'https://example.com/cache' },
                                },
                                { type: 'bold' },
                              ],
                            },
                          ],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    { type: 'text', text: 'Mark the ' },
                    {
                      type: 'factoid',
                      attrs: { id: 'col-temperature' },
                      content: [
                        { type: 'text', text: 'col temperature' },
                        {
                          type: 'text',
                          text: ' at dawn',
                          marks: [{ type: 'underline' }],
                        },
                      ],
                    },
                    { type: 'text', text: ' on the map before you start down' },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    {
                      type: 'text',
                      text: 'If the latch sticks, write the time and the side it sticks on.',
                    },
                  ],
                },
                {
                  type: 'codeBlock',
                  attrs: { language: 'text' },
                  content: [
                    {
                      type: 'text',
                      text: '04:41 gate\nnorth latch, one extra pull',
                    },
                  ],
                },
              ],
            },
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
                  text: 'Leave the gate as you found it, and read ',
                },
                {
                  type: 'text',
                  text: 'the hut log',
                  marks: [
                    { type: 'italic' },
                    {
                      type: 'link',
                      attrs: { href: 'https://example.com/hut' },
                    },
                  ],
                },
                {
                  type: 'text',
                  text: ' if the wind has changed since yesterday.',
                },
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
                      text: 'Latch it when the sheep are in. The ',
                    },
                    {
                      type: 'text',
                      text: 'upper field',
                      marks: [{ type: 'bold' }, { type: 'highlight' }],
                    },
                    { type: 'text', text: ' is the one that matters.' },
                  ],
                },
              ],
            },
          ],
        },
        { type: 'horizontalRule' },
      ],
    },
    {
      type: 'doc',
      content: [
        {
          type: 'heading',
          attrs: { level: 3 },
          content: [{ type: 'text', text: 'The first hour' }],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'The trail stayed quiet until the ' },
            {
              type: 'factoid',
              attrs: { id: 'station-board' },
              content: [
                {
                  type: 'text',
                  text: 'station board',
                  marks: [
                    {
                      type: 'link',
                      attrs: { href: 'https://example.com/station' },
                    },
                  ],
                },
              ],
            },
            { type: 'text', text: ' came into view. After that, ' },
            { type: 'text', text: 'count', marks: [{ type: 'italic' }] },
            {
              type: 'text',
              text: ' the cairns and ignore the fork the log already ',
            },
            {
              type: 'text',
              text: 'struck out',
              marks: [{ type: 'strike' }, { type: 'italic' }],
            },
            { type: 'text', text: '.' },
          ],
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
                  content: [
                    {
                      type: 'text',
                      text: 'North col, before the sun clears the shoulder',
                    },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    { type: 'text', text: 'Lake shelf, where the ' },
                    {
                      type: 'text',
                      text: 'old ford',
                      marks: [{ type: 'italic' }],
                    },
                    { type: 'text', text: ' is ' },
                    {
                      type: 'text',
                      text: 'closed',
                      marks: [{ type: 'strike' }],
                    },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    {
                      type: 'text',
                      text: 'Ridge cache, counted from the red lid',
                    },
                  ],
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
                          content: [
                            {
                              type: 'text',
                              text: 'First tin, matches and a spare wick',
                            },
                          ],
                        },
                      ],
                    },
                    {
                      type: 'listItem',
                      content: [
                        {
                          type: 'paragraph',
                          content: [
                            {
                              type: 'text',
                              text: 'Second tin, the one with the ',
                            },
                            {
                              type: 'text',
                              text: 'red lid',
                              marks: [{ type: 'highlight' }],
                            },
                          ],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'The marker is written as ' },
            { type: 'text', text: 'cairn', marks: [{ type: 'code' }] },
            {
              type: 'text',
              text: '. Pack weight stays under twelve kilos, and the ',
            },
            {
              type: 'text',
              text: 'turn',
              marks: [{ type: 'bold' }, { type: 'italic' }],
            },
            {
              type: 'text',
              text: ' after the lake is the one to remember. A line in the margin still reads ',
            },
            {
              type: 'text',
              text: 'do not cut the switchback',
              marks: [{ type: 'underline' }, { type: 'highlight' }],
            },
            { type: 'text', text: '.' },
          ],
        },
        {
          type: 'heading',
          attrs: { level: 4 },
          content: [
            { type: 'text', text: 'Call ' },
            { type: 'text', text: 'the parser', marks: [{ type: 'code' }] },
          ],
        },
        {
          type: 'codeBlock',
          attrs: { language: 'ts' },
          content: [
            {
              type: 'text',
              text: 'const document = {\n  type: "doc",\n  content: [],\n};\n\nrender(document);\nkeepTheLanguageOnTheFence();',
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'The fence is stored. Nothing on that block is highlighted, and the next sentence is the one you walk. If the line wraps, the language stays ',
            },
            { type: 'text', text: 'ts', marks: [{ type: 'code' }] },
            { type: 'text', text: ' and the trail does not.' },
          ],
        },
        { type: 'horizontalRule' },
        {
          type: 'heading',
          attrs: { level: 5 },
          content: [
            { type: 'text', text: 'Water at ' },
            {
              type: 'text',
              text: 'the spring',
              marks: [
                {
                  type: 'link',
                  attrs: { href: 'https://example.com/spring' },
                },
              ],
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'At the second switchback the ' },
            {
              type: 'factoid',
              attrs: {
                id: 'spring',
                color: '#7c2d12',
                backgroundColor: '#ffedd5',
                borderColor: '#c2410c',
              },
              content: [
                { type: 'text', text: 'spring', marks: [{ type: 'bold' }] },
                { type: 'text', text: ' is ' },
                { type: 'text', text: 'cold', marks: [{ type: 'italic' }] },
                { type: 'text', text: ' and ' },
                {
                  type: 'text',
                  text: 'marked',
                  marks: [{ type: 'underline' }],
                },
              ],
            },
            {
              type: 'text',
              text: ' in the log. Drink there. The standing pool is the one the last party ',
            },
            { type: 'text', text: 'skipped', marks: [{ type: 'strike' }] },
            { type: 'text', text: '.' },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Fill both bottles, then open ' },
            {
              type: 'text',
              text: 'the hut log',
              marks: [
                {
                  type: 'link',
                  attrs: { href: 'https://example.com/hut' },
                },
              ],
            },
            { type: 'text', text: '. The note inside ' },
            {
              type: 'factoid',
              attrs: { id: 'afternoon-note' },
              content: [
                {
                  type: 'text',
                  text: 'the afternoon entry',
                  marks: [
                    {
                      type: 'link',
                      attrs: { href: 'https://example.com/afternoon' },
                    },
                    { type: 'bold' },
                  ],
                },
              ],
            },
            {
              type: 'text',
              text: ' should follow the link. A factoid with no link, such as ',
            },
            {
              type: 'factoid',
              attrs: { id: 'bottle-count' },
              content: [{ type: 'text', text: 'two liters' }],
            },
            { type: 'text', text: ', is the one the footer should name.' },
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
                  text: 'Notes from the last party, copied before the ink ran:',
                },
              ],
            },
            {
              type: 'bulletList',
              content: [
                {
                  type: 'listItem',
                  content: [
                    {
                      type: 'paragraph',
                      content: [
                        {
                          type: 'text',
                          text: 'Dip below the second switchback',
                        },
                      ],
                    },
                  ],
                },
                {
                  type: 'listItem',
                  content: [
                    {
                      type: 'paragraph',
                      content: [
                        { type: 'text', text: 'Skip ' },
                        {
                          type: 'text',
                          text: 'the trough',
                          marks: [{ type: 'strike' }],
                        },
                        { type: 'text', text: ' even when it looks clear' },
                      ],
                    },
                  ],
                },
                {
                  type: 'listItem',
                  content: [
                    {
                      type: 'paragraph',
                      content: [
                        { type: 'text', text: 'The lock on the box is ' },
                        {
                          type: 'text',
                          text: '4412',
                          marks: [{ type: 'code' }],
                        },
                        { type: 'hardBreak' },
                        {
                          type: 'text',
                          text: 'Turn it back to zero when you leave.',
                        },
                      ],
                    },
                  ],
                },
              ],
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            { type: 'text', text: 'Wind on the exposed mile.' },
            { type: 'hardBreak' },
            { type: 'text', text: 'Then the line the log both ' },
            {
              type: 'text',
              text: 'marked and crossed out',
              marks: [{ type: 'highlight' }, { type: 'strike' }],
            },
            { type: 'text', text: ', which is the shortcut you do not take.' },
          ],
        },
        {
          type: 'heading',
          attrs: { level: 6 },
          content: [
            { type: 'text', text: 'Last ' },
            { type: 'text', text: 'light', marks: [{ type: 'italic' }] },
          ],
        },
        {
          type: 'orderedList',
          attrs: { start: 7 },
          content: [
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    {
                      type: 'text',
                      text: 'Count the cairns you can still see',
                    },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    {
                      type: 'text',
                      text: 'Stop when the headlamp is the brighter of the two',
                    },
                    { type: 'hardBreak' },
                    {
                      type: 'text',
                      text: 'and write the time on the next line of the log.',
                    },
                  ],
                },
                {
                  type: 'bulletList',
                  content: [
                    {
                      type: 'listItem',
                      content: [
                        {
                          type: 'paragraph',
                          content: [
                            { type: 'text', text: 'One stone on the cairn' },
                          ],
                        },
                      ],
                    },
                    {
                      type: 'listItem',
                      content: [
                        {
                          type: 'paragraph',
                          content: [
                            { type: 'text', text: 'One strip of ' },
                            {
                              type: 'text',
                              text: 'tape',
                              marks: [{ type: 'underline' }],
                            },
                          ],
                        },
                      ],
                    },
                  ],
                },
              ],
            },
            {
              type: 'listItem',
              content: [
                {
                  type: 'paragraph',
                  content: [
                    { type: 'text', text: 'Leave a ' },
                    {
                      type: 'factoid',
                      attrs: { id: 'last-cairn' },
                      content: [
                        {
                          type: 'text',
                          text: 'last cairn',
                          marks: [{ type: 'bold' }],
                        },
                      ],
                    },
                    { type: 'text', text: ' for the party behind you' },
                  ],
                },
              ],
            },
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
                  text: 'The ridge is finished when the hut light is below you.',
                },
              ],
            },
          ],
        },
        {
          type: 'paragraph',
          content: [
            {
              type: 'text',
              text: 'That is the whole day: a closed spur, an open gate, a skipped trough, one ',
            },
            { type: 'text', text: 'code', marks: [{ type: 'code' }] },
            {
              type: 'text',
              text: ', an underlined turn, a highlighted cairn, and the two places worth opening again, ',
            },
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
            { type: 'text', text: ' and ' },
            {
              type: 'text',
              text: 'the hut',
              marks: [
                {
                  type: 'link',
                  attrs: { href: 'https://example.com/hut' },
                },
                { type: 'underline' },
              ],
            },
            { type: 'text', text: '.' },
          ],
        },
      ],
    },
    ],
  },
];
