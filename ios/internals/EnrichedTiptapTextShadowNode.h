#pragma once
#include "MeasurementCache.h"
#include <ReactNativeRenderRichText/EnrichedTiptapTextState.h>
#include <ReactNativeRenderRichText/EventEmitters.h>
#include <ReactNativeRenderRichText/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>
#include <react/renderer/core/LayoutConstraints.h>

namespace facebook::react {

JSI_EXPORT extern const char EnrichedTiptapTextComponentName[];

/// ShadowNode implementing measureContent for automatic height calculation.
class EnrichedTiptapTextShadowNode
    : public ConcreteViewShadowNode<EnrichedTiptapTextComponentName, EnrichedTiptapTextProps,
                                    EnrichedTiptapTextEventEmitter, EnrichedTiptapTextState> {
public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  EnrichedTiptapTextShadowNode(const ShadowNodeFragment &fragment, const ShadowNodeFamily::Shared &family,
                                 ShadowNodeTraits traits);

  EnrichedTiptapTextShadowNode(const ShadowNode &sourceShadowNode, const ShadowNodeFragment &fragment);

  void dirtyLayoutIfNeeded();

  Size measureContent(const LayoutContext &layoutContext, const LayoutConstraints &layoutConstraints) const override;

  static ShadowNodeTraits BaseTraits()
  {
    auto traits = ConcreteViewShadowNode::BaseTraits();
    traits.set(ShadowNodeTraits::Trait::LeafYogaNode);
    traits.set(ShadowNodeTraits::Trait::MeasurableYogaNode);
    return traits;
  }

private:
  int localHeightRecalculationCounter_{0};
  mutable int lastExactMeasurementCounter_{0};
  mutable CGSize lastExactMeasurementSize_{0, 0};
};

} // namespace facebook::react
