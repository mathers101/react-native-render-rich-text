# react-native-render-rich-text

A React Native Fabric library that renders a [Tiptap](https://tiptap.dev/) document on iOS and Android. The public component is `RichText`. Its `document` prop is a Tiptap JSON tree, or that tree already encoded as a string.

There is no web renderer and no text-input component. New Architecture is required (React Native 0.88).

The display renderers are adapted from Software Mansion. That copyright stays on the copied sources. See `LICENSE`.

## What it draws

Nodes: `doc`, `paragraph`, `heading`, `bulletList`, `orderedList`, `listItem`, `blockquote`, `codeBlock`, `horizontalRule`, `hardBreak`, and `factoid`. Marks: `bold` (or `strong`), `italic` (or `em`), `strike` (or `strikethrough`), `code`, `underline`, `highlight`, and `link`. A link's URL is `marks[].attrs.href`. A factoid is an inline node; its `id` is what `onFactoidPress` receives, and a factoid that contains a link emits `onLinkPress` instead.

Unknown nodes, including tables, images, and task lists, are skipped with their children so the rest of the document still renders. A code block keeps its `language` attribute. Syntax colors apply only when the optional highlighting module is compiled in; otherwise the block is plain monospace.

## Use it

```tsx
import { RichText } from 'react-native-render-rich-text';

<RichText
  document={document}
  onLinkPress={(url) => {
    // url comes from the link mark's href
  }}
  onFactoidPress={(factoidId) => {
    // factoidId comes from the factoid node's id
  }}
/>
```

`document` is either a `TiptapNode` or a JSON string. `selectable` defaults to true. `allowFontScaling` defaults to true, and `maxFontSizeMultiplier` caps that scale. `numberOfLines` and `ellipsizeMode` (`'head' | 'middle' | 'tail' | 'clip'`) truncate the view. `style` is a normal React Native view style for the container, not the text.

## Styling

Pass a partial `TiptapStyle` as `textStyle`. Omitted keys keep the built-in defaults. JavaScript fills in that complete style before it crosses the bridge; native does not invent colors of its own.

```tsx
<RichText
  document={document}
  textStyle={{
    paragraph: { color: '#1c1917', fontSize: 17, lineHeight: 26 },
    link: { color: '#9a3412' },
    blockquote: { borderColor: '#c2410c', padding: 16 },
  }}
/>
```

The type is exported as `TiptapStyle`. Each node has its own block: `paragraph`, `h1` through `h6`, `blockquote`, `list`, `code`, `codeBlock`, `link`, `linkVariants`, `strong`, `em`, `strikethrough`, `underline`, `factoid`, `highlight`, `thematicBreak`, and the table, image, math, and task-list blocks the style object still carries. Color fields take any string `processColor` accepts.

With no `textStyle`, body text is `#1F2937`, headings are near-black, links are `#2563EB`, and inline code is pink on a light chip. Blockquotes use a gray bar, a light fill, and 10 points of padding. Bold and italic do not set a color, so they inherit the surrounding text. Fenced code blocks are the exception: they default to a dark background (`#1F2937`) and a GitHub-dark syntax palette.

A factoid's `color`, `backgroundColor`, and `borderColor` attributes replace that one channel of `textStyle.factoid`. The other channels stay on the style.

`linkVariants` maps a URL regex to a link override. Longer patterns win. Omitted `color` and `underline` inherit the base link style.

## Dark mode

The library does not follow the system appearance. Pass a dark `textStyle` yourself when the screen is dark. `darkModeTextStyle` is a ready-made palette for that: light text (`#E6EDF3`), brighter headings, blue links (`#58A6FF`), and dark surfaces for quotes, tables, and code. It sets colors only. Font sizes, spacing, and the rest of the geometry stay on the built-in defaults, including the 10-point blockquote padding. Bold and italic are left unset so they still inherit.

```tsx
import { darkModeTextStyle, RichText } from 'react-native-render-rich-text';

<RichText document={document} textStyle={darkModeTextStyle} />
```

Spread it and override a few keys when the preset is close but not exact:

```tsx
textStyle={{
  ...darkModeTextStyle,
  paragraph: { ...darkModeTextStyle.paragraph, fontSize: 17, lineHeight: 26 },
  link: { color: '#93C5FD' },
}}
```

The preset lives in `src/darkModeTextStyle.ts`. The light defaults live in `src/normalizeTiptapStyle.ts`.

## Run the example

The example app is a Yarn workspace of this package. Metro serves it on port 41873:

```sh
yarn example
```

One screen shows five fixtures: mixed document, lists, code, links, and a long document that mixes every node. The header button labeled **Dark** swaps the document to `darkModeTextStyle` and darkens the screen around it. It reads **Light** after the switch. Open a link or a factoid and the footer shows what was pressed.

iOS: from `example/ios`, run `bundle install` and `bundle exec pod install`, then `yarn example ios` (or `yarn workspace render-rich-text-example ios`). The pod is `ReactNativeRenderRichText`.

Android: from `example`, run `yarn android`. The native package is `com.renderrichtext`. The codegen spec name is `RichTextSpec`.

## Build the library

Install dependencies from the repository root.

```sh
corepack enable
yarn install
yarn typecheck
```

## Parser tests

The C++ parser tests check mark nesting, lists, factoids, empty documents, and unknown nodes.

```sh
yarn test:parser
```

That compiles `cpp/parser/TiptapParser.cpp` with `cpp/tests/parser_tests.cpp` and runs the binary. A passing run prints `all parser tests passed`.

## What this environment cannot verify

iOS and Android rendering need a simulator or a device. Typecheck and the parser tests run here. Metro can serve the JavaScript bundle here. A device render does not.
