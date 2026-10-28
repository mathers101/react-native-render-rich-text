#pragma once
#include "EnrichedTiptapTextShadowNode.h"
#include <react/debug/react_native_assert.h>
#include <react/renderer/core/ConcreteComponentDescriptor.h>

namespace facebook::react {

class EnrichedTiptapTextComponentDescriptor final
    : public ConcreteComponentDescriptor<EnrichedTiptapTextShadowNode> {
public:
  using ConcreteComponentDescriptor::ConcreteComponentDescriptor;

  void adopt(ShadowNode &shadowNode) const override {
    react_native_assert(dynamic_cast<EnrichedTiptapTextShadowNode *>(&shadowNode));
    ConcreteComponentDescriptor::adopt(shadowNode);
  }
};

} // namespace facebook::react
