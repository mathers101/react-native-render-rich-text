#pragma once

#include <folly/dynamic.h>
#include <react/renderer/components/RichTextSpec/Props.h>
#include <react/renderer/core/propsConversions.h>

namespace facebook::react {

#ifdef RN_SERIALIZABLE_STATE
inline folly::dynamic toDynamic(const EnrichedTiptapTextProps &props) {
  folly::dynamic serializedProps = folly::dynamic::object();
  serializedProps["document"] = props.document;
  serializedProps["tiptapStyle"] = toDynamic(props.tiptapStyle);
  serializedProps["md4cFlags"] = toDynamic(props.md4cFlags);
  serializedProps["allowFontScaling"] = props.allowFontScaling;
  serializedProps["maxFontSizeMultiplier"] = props.maxFontSizeMultiplier;
  serializedProps["allowTrailingMargin"] = props.allowTrailingMargin;
  serializedProps["streamingAnimation"] = props.streamingAnimation;
  serializedProps["numberOfLines"] = props.numberOfLines;
  serializedProps["ellipsizeMode"] = props.ellipsizeMode;

  folly::dynamic imageRequestHeaders = folly::dynamic::array();
  for (const auto &header : props.imageRequestHeaders) {
    imageRequestHeaders.push_back(toDynamic(header));
  }
  serializedProps["imageRequestHeaders"] = std::move(imageRequestHeaders);

  folly::dynamic linkPillContent = folly::dynamic::array();
  for (const auto &content : props.linkPillContent) {
    linkPillContent.push_back(toDynamic(content));
  }
  serializedProps["linkPillContent"] = std::move(linkPillContent);

  serializedProps["linkRecognition"] = toDynamic(props.linkRecognition);

  return serializedProps;
}
#endif

} // namespace facebook::react
