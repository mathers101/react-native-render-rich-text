#pragma once

#include "MarkdownTextMeasurementManager.h"
#include "MarkdownTextShadowNode.h"

#include <react/renderer/componentregistry/ComponentDescriptorProviderRegistry.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class EnrichedMarkdownTextComponentDescriptor final : public ConcreteComponentDescriptor<MarkdownTextShadowNode> {
public:
  EnrichedMarkdownTextComponentDescriptor(const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(std::make_shared<MarkdownTextMeasurementManager>(contextContainer_)) {}

  void adopt(ShadowNode &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &markdownTextShadowNode = static_cast<MarkdownTextShadowNode &>(shadowNode);
    markdownTextShadowNode.setMeasurementsManager(measurementsManager_);
  }

private:
  const std::shared_ptr<MarkdownTextMeasurementManager> measurementsManager_;
};

void RichTextSpec_registerComponentDescriptorsFromCodegen(
    std::shared_ptr<const ComponentDescriptorProviderRegistry> registry);

} // namespace facebook::react
