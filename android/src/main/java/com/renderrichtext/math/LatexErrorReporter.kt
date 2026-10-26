package com.renderrichtext.math

fun interface LatexErrorReporter {
  fun report(
    source: String,
    message: String,
    displayMode: Boolean,
  )
}
