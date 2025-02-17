% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/metrics.R
\name{Metric}
\alias{Metric}
\title{Metric}
\arguments{
\item{name}{(Optional) string name of the metric instance.}

\item{dtype}{(Optional) data type of the metric result.}
}
\value{
A (subclassed) \code{Metric} instance that can be passed directly to
\code{compile(metrics = )}, or used as a standalone object. See \code{?Metric} for
example usage.
}
\description{
A \code{Metric} object encapsulates metric logic and state that can be used to
track model performance during training. It is what is returned by the family
of metric functions that start with prefix \verb{metric_*}.
}
\section{Usage with \code{compile}}{
\if{html}{\out{<div class="sourceCode r">}}\preformatted{model \%>\% compile(
  optimizer = 'sgd',
  loss = 'mse',
  metrics = list(metric_SOME_METRIC(), metric_SOME_OTHER_METRIC())
)
}\if{html}{\out{</div>}}
}

\section{Standalone usage}{
\if{html}{\out{<div class="sourceCode r">}}\preformatted{m <- metric_SOME_METRIC()
for (e in seq(epochs)) \{
  for (i in seq(train_steps)) \{
    c(y_true, y_pred, sample_weight = NULL) \%<-\% ...
    m$update_state(y_true, y_pred, sample_weight)
  \}
  cat('Final epoch result: ', as.numeric(m$result()), "\\n")
  m$reset_state()
\}
}\if{html}{\out{</div>}}
}

\section{Custom Metric (subclass)}{

To be implemented by subclasses:
\itemize{
\item \code{initialize()}: All state variables should be created in this method by calling \code{self$add_weight()} like:\preformatted{self$var <- self$add_weight(...)
}
\item \code{update_state()}: Has all updates to the state variables like:\preformatted{self$var$assign_add(...)
}
\item \code{result()}: Computes and returns a value for the metric from the state variables.
}

Example custom metric subclass:\if{html}{\out{<div class="sourceCode R">}}\preformatted{metric_binary_true_positives <- new_metric_type(
  classname = "BinaryTruePositives",
  initialize = function(name = 'binary_true_positives', ...) \{
    super$initialize(name = name, ...)
    self$true_positives <-
      self$add_weight(name = 'tp', initializer = 'zeros')
  \},

  update_state = function(y_true, y_pred, sample_weight = NULL) \{
    y_true <- k_cast(y_true, "bool")
    y_pred <- k_cast(y_pred, "bool")

    values <- y_true & y_pred
    values <- k_cast(values, self$dtype)
    if (!is.null(sample_weight)) \{
      sample_weight <- k_cast(sample_weight, self$dtype)
      sample_weight <- tf$broadcast_to(sample_weight, values$shape)
      values <- values * sample_weight
    \}
    self$true_positives$assign_add(tf$reduce_sum(values))
  \},

  result = function()
    self$true_positives
)
model \%>\% compile(..., metrics = list(metric_binary_true_positives()))
}\if{html}{\out{</div>}}

The same \code{metric_binary_true_positives} could be built with \verb{\%py_class\%} like
this:\preformatted{metric_binary_true_positives(keras$metrics$Metric) \%py_class\% \{
  initialize <- <same-as-above>,
  update_state <- <same-as-above>,
  result <- <same-as-above>
\}
}
}

