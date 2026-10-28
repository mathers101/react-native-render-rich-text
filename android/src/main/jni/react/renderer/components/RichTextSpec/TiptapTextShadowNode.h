#pragma once

#include "TiptapTextMeasurementManager.h"
#include "TiptapTextState.h"

#include <react/renderer/components/RichTextSpec/EventEmitters.h>
#include <react/renderer/components/RichTextSpec/Props.h>
#include <react/renderer/components/view/ConcreteViewShadowNode.h>

namespace facebook::react {

JSI_EXPORT extern const char TiptapTextComponentName[];

/*
 * `ShadowNode` for <EnrichedTiptapText> component.
 */
class TiptapTextShadowNode final
    : public ConcreteViewShadowNode<TiptapTextComponentName, EnrichedTiptapTextProps,
                                    EnrichedTiptapTextEventEmitter, TiptapTextState> {
public:
  using ConcreteViewShadowNode::ConcreteViewShadowNode;

  TiptapTextShadowNode(ShadowNode const &sourceShadowNode, ShadowNodeFragment const &fragment)
      : ConcreteViewShadowNode(sourceShadowNode, fragment) {
    forceHeightRecalculationCounter_ =
        static_cast<const TiptapTextShadowNode &>(sourceShadowNode).forceHeightRecalculationCounter_;
    dirtyLayoutIfNeeded();
  }

  static ShadowNodeTraits BaseTraits() {
    auto traits = ConcreteViewShadowNode::BaseTraits();
    traits.set(ShadowNodeTraits::Trait::LeafYogaNode);
    traits.set(ShadowNodeTraits::Trait::MeasurableYogaNode);
    return traits;
  }

  // Associates a shared `TiptapTextMeasurementManager` with the node.
  void setMeasurementsManager(const std::shared_ptr<TiptapTextMeasurementManager> &measurementsManager);

  void dirtyLayoutIfNeeded();

  Size measureContent(const LayoutContext &layoutContext, const LayoutConstraints &layoutConstraints) const override;

protected:
  bool shouldNewRevisionDirtyMeasurement(const ShadowNode &sourceShadowNode,
                                         const ShadowNodeFragment &fragment) const override;

private:
  int forceHeightRecalculationCounter_{0};
  std::shared_ptr<TiptapTextMeasurementManager> measurementsManager_;
};

} // namespace facebook::react
