#pragma once

#include "TiptapTextMeasurementManager.h"
#include "TiptapTextShadowNode.h"

#include <react/renderer/componentregistry/ComponentDescriptorProviderRegistry.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class EnrichedTiptapTextComponentDescriptor final : public ConcreteComponentDescriptor<TiptapTextShadowNode> {
public:
  EnrichedTiptapTextComponentDescriptor(const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(std::make_shared<TiptapTextMeasurementManager>(contextContainer_)) {}

  void adopt(ShadowNode &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &tiptapTextShadowNode = static_cast<TiptapTextShadowNode &>(shadowNode);
    tiptapTextShadowNode.setMeasurementsManager(measurementsManager_);
  }

private:
  const std::shared_ptr<TiptapTextMeasurementManager> measurementsManager_;
};

void RichTextSpec_registerComponentDescriptorsFromCodegen(
    std::shared_ptr<const ComponentDescriptorProviderRegistry> registry);

} // namespace facebook::react
