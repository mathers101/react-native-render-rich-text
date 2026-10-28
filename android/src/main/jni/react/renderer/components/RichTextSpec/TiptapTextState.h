#pragma once

#include <folly/dynamic.h>

namespace facebook::react {

class TiptapTextState {
public:
  TiptapTextState() : forceHeightRecalculationCounter_(0) {}

  TiptapTextState(TiptapTextState const &previousState, folly::dynamic data)
      : forceHeightRecalculationCounter_((int)data["forceHeightRecalculationCounter"].getInt()) {}

  folly::dynamic getDynamic() const {
    return {};
  }

  int getForceHeightRecalculationCounter() const;

private:
  const int forceHeightRecalculationCounter_{};
};

} // namespace facebook::react
