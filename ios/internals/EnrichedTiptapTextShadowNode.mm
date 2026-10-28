#import "EnrichedTiptapTextShadowNode.h"
#import "ENRMViewFreeMeasurement.h"
#import "EnrichedTiptapText.h"
#import "ShadowMeasurementUtils.h"
#import <yoga/Yoga.h>

namespace facebook::react {

extern const char EnrichedTiptapTextComponentName[] = "EnrichedTiptapText";

EnrichedTiptapTextShadowNode::EnrichedTiptapTextShadowNode(const ShadowNodeFragment &fragment,
                                                               const ShadowNodeFamily::Shared &family,
                                                               ShadowNodeTraits traits)
    : ConcreteViewShadowNode(fragment, family, traits)
{
}

EnrichedTiptapTextShadowNode::EnrichedTiptapTextShadowNode(const ShadowNode &sourceShadowNode,
                                                               const ShadowNodeFragment &fragment)
    : ConcreteViewShadowNode(sourceShadowNode, fragment),
      localHeightRecalculationCounter_(
          static_cast<const EnrichedTiptapTextShadowNode &>(sourceShadowNode).localHeightRecalculationCounter_),
      lastExactMeasurementCounter_(
          static_cast<const EnrichedTiptapTextShadowNode &>(sourceShadowNode).lastExactMeasurementCounter_),
      lastExactMeasurementSize_(
          static_cast<const EnrichedTiptapTextShadowNode &>(sourceShadowNode).lastExactMeasurementSize_)
{
  const auto &oldProps = *std::static_pointer_cast<const EnrichedTiptapTextProps>(sourceShadowNode.getProps());
  const auto &newProps = *std::static_pointer_cast<const EnrichedTiptapTextProps>(this->getProps());

  if (newProps.streamingAnimation && ENRMPropsNeedExactStreamingMeasurement(oldProps, newProps)) {
    lastExactMeasurementCounter_ = -1;
  }

  dirtyLayoutIfNeeded();
}

void EnrichedTiptapTextShadowNode::dirtyLayoutIfNeeded()
{
  const auto state = this->getStateData();
  const int receivedCounter = state.getHeightRecalculationCounter();

  if (receivedCounter > localHeightRecalculationCounter_) {
    localHeightRecalculationCounter_ = receivedCounter;
    YGNodeMarkDirty(&yogaNode_);
  }
}

Size EnrichedTiptapTextShadowNode::measureContent(const LayoutContext &layoutContext,
                                                    const LayoutConstraints &layoutConstraints) const
{
  const auto propsHandle = std::static_pointer_cast<const EnrichedTiptapTextProps>(this->getProps());
  const auto &typedProps = *propsHandle;
  const int receivedCounter = getStateData().getHeightRecalculationCounter();
  const EnrichedTiptapTextProps *props = propsHandle.get();
  CGFloat pointScaleFactor = layoutContext.pointScaleFactor;
  NSWritingDirection resolvedLayoutDirection = layoutConstraints.layoutDirection == LayoutDirection::RightToLeft
                                                   ? NSWritingDirectionRightToLeft
                                                   : NSWritingDirectionLeftToRight;

  return ENRMMeasureTiptapContent<EnrichedTiptapTextProps, EnrichedTiptapText>(
      typedProps, getStateData().getComponentViewRef(), receivedCounter, lastExactMeasurementCounter_,
      lastExactMeasurementSize_, TiptapFlavor::CommonMark, layoutContext, layoutConstraints,
      ^(EnrichedTiptapText *view, CGFloat maxWidth, CGFloat fontScale) {
        return ENRMMeasureTiptapViewFree(*props, maxWidth, fontScale, pointScaleFactor, resolvedLayoutDirection);
      });
}

} // namespace facebook::react
