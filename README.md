# react-native-render-rich-text

A React Native Fabric library that renders a [TipTap](https://tiptap.dev/) document on iOS and Android. The public component is `RichText`. Its `document` prop is a TipTap JSON tree (or that tree encoded as a string).

Supported nodes: paragraph, heading, bullet list, ordered list, list item, blockquote, code, code block, link, hard break, and horizontal rule. Marks: bold, italic, strike, inline code, underline, highlight, and link. A code block keeps its `language` attribute and draws as plain monospace text. Unknown nodes, including tables, images, and task lists, are skipped so the rest of the document still renders.

The display renderers are adapted from Software Mansion's enriched-markdown. That copyright stays on the copied sources. See `LICENSE`.

There is no web renderer and no text-input component.

## Build the library

Install dependencies from the repository root. The example app is a Yarn workspace of this package.

```sh
corepack enable
yarn install
yarn typecheck
```

iOS: from `example/ios`, run `bundle install` and `bundle exec pod install`, then `yarn example ios` (or `yarn workspace render-rich-text-example ios`). The pod is `ReactNativeRenderRichText`.

Android: from `example`, run `yarn android`. The native package is `com.renderrichtext`. Codegen spec name is `RichTextSpec`. New Architecture is required (React Native 0.88).

## Run the example

Metro serves the example on port 41873:

```sh
yarn example
```

The app has one screen per fixture: mixed document, lists, code, and links. Open a link in the links fixture and the footer shows the URL.

## Parser tests

The C++ parser tests check mark nesting, lists, empty documents, and unknown nodes.

```sh
yarn test:parser
```

That compiles `cpp/parser/TipTapParser.cpp` with `cpp/tests/parser_tests.cpp` and runs the binary. A passing run prints `all parser tests passed`.

## What this environment cannot verify

iOS and Android rendering need a simulator or a device. Typecheck and the parser tests run here. Metro can serve the JavaScript bundle here. A device render does not.
