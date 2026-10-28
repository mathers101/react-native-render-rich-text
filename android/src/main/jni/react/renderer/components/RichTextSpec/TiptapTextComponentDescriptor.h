#pragma once

#include "TiptapTextMeasurementManager.h"
#include "TiptapTextShadowNode.h"

#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class TiptapTextComponentDescriptor final : public ConcreteComponentDescriptor<TiptapTextShadowNode> {
public:
  TiptapTextComponentDescriptor(const ComponentDescriptorParameters &parameters)
      : ConcreteComponentDescriptor(parameters),
        measurementsManager_(std::make_shared<TiptapTextMeasurementManager>(contextContainer_)) {}

  void adopt(ShadowNode &shadowNode) const override {
    ConcreteComponentDescriptor::adopt(shadowNode);
    auto &tiptapTextShadowNode = static_cast<TiptapTextShadowNode &>(shadowNode);

    // TiptapTextShadowNode uses TiptapTextMeasurementManager
    // to provide measurements to Yoga.
    tiptapTextShadowNode.setMeasurementsManager(measurementsManager_);
  }

private:
  const std::shared_ptr<TiptapTextMeasurementManager> measurementsManager_;
};

} // namespace facebook::react
