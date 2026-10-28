#include "TiptapTextShadowNode.h"

#include <react/renderer/core/LayoutContext.h>

namespace facebook::react {

extern const char TiptapTextComponentName[] = "EnrichedTiptapText";

void TiptapTextShadowNode::setMeasurementsManager(
    const std::shared_ptr<TiptapTextMeasurementManager> &measurementsManager) {
  ensureUnsealed();
  measurementsManager_ = measurementsManager;
}

void TiptapTextShadowNode::dirtyLayoutIfNeeded() {
  const auto state = this->getStateData();
  const auto counter = state.getForceHeightRecalculationCounter();

  if (forceHeightRecalculationCounter_ != counter) {
    forceHeightRecalculationCounter_ = counter;
    dirtyLayout();
  }
}

// Only new props change the rendered tiptap. When a parent is cloned, React Native's adoptYogaChild
// re-clones its children without new props, and dirtying those clones re-measures every settled message
// whenever the list above grows.
bool TiptapTextShadowNode::shouldNewRevisionDirtyMeasurement(const ShadowNode & /*sourceShadowNode*/,
                                                               const ShadowNodeFragment &fragment) const {
  return fragment.props != nullptr;
}

Size TiptapTextShadowNode::measureContent(const LayoutContext &layoutContext,
                                            const LayoutConstraints &layoutConstraints) const {
  return measurementsManager_->measure(getSurfaceId(), getTag(), getConcreteProps(), layoutConstraints);
}

} // namespace facebook::react
