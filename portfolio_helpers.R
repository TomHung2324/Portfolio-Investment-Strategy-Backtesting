# FN6901 portfolio helper functions; base R only.
max_drawdown <- function(equity) {
  equity <- c(1, as.numeric(equity))
  min(equity / cummax(equity) - 1, na.rm = TRUE)
}
performance_metrics <- function(returns, label) {
  returns <- as.numeric(returns)
  stopifnot(all(is.finite(returns)), all(returns > -1))
  annual_return <- prod(1 + returns)^(252 / length(returns)) - 1
  annual_vol <- sd(returns) * sqrt(252)
  data.frame(Strategy = label, Annualized_Return = annual_return,
             Annualized_Volatility = annual_vol,
             Sharpe = if (annual_vol > 0) annual_return / annual_vol else NA_real_,
             Max_Drawdown = max_drawdown(cumprod(1 + returns)),
             Terminal_Wealth = prod(1 + returns))
}
# Rebalance at the CLOSE of a given trading day, effective for the NEXT return.
# 'days' are return-row indices. Initial portfolio is equally invested.
backtest_equal_weight <- function(ret, days = integer(0)) {
  ret <- as.matrix(ret)
  n <- nrow(ret); k <- ncol(ret)
  holdings <- rep(1/k, k)
  equity <- numeric(n)
  for (i in seq_len(n)) {
    holdings <- holdings * (1 + ret[i, ])
    equity[i] <- sum(holdings)
    if (i %in% days) holdings <- rep(equity[i]/k, k)
  }
  list(equity = equity, returns = equity / c(1, head(equity, -1)) - 1)
}
# Monthly FF strategy. At day x, estimate alpha from [x-62,x].
# Change holdings after day x CLOSE, so signals affect return on x+1.
backtest_ff <- function(ret, factor_data, rebalance_days, names_etf) {
  ret <- as.matrix(ret); n <- nrow(ret); k <- ncol(ret)
  holdings <- rep(0, k); cash <- 1
  equity <- numeric(n)
  selection <- list()
  alpha_history <- list()
  for (i in seq_len(n)) {
    holdings <- holdings * (1 + ret[i, ])
    equity[i] <- cash + sum(holdings)
    if (i %in% rebalance_days && i >= 63 && i < n) {
      idx <- (i-62):i
      f <- factor_data[idx, , drop = FALSE]
      x <- cbind(1, as.numeric(f$MKT), as.numeric(f$SMB), as.numeric(f$HML))
      if (any(!is.finite(x)) || any(!is.finite(f$RF))) stop('Missing FF factors in fitting window ending row ', i)
      alphas <- vapply(seq_len(k), function(j) {
        y <- ret[idx, j] - as.numeric(f$RF)
        if (any(!is.finite(y))) stop('Missing ETF return in fitting window')
        unname(qr.coef(qr(x), y)[1])
      }, numeric(1))
      names(alphas) <- names_etf
      if (any(!is.finite(alphas))) stop('Regression failed at day ', i)
      winners <- names(sort(alphas, decreasing = TRUE))[1:5]
      holdings <- rep(0, k)
      holdings[match(winners, names_etf)] <- equity[i]/5
      cash <- 0
      selection[[length(selection)+1]] <- data.frame(Row = i, ETF = winners, Rank = 1:5)
      alpha_history[[length(alpha_history)+1]] <- data.frame(Row = i, ETF = names_etf, Alpha = alphas)
    }
  }
  list(equity = equity, returns = equity / c(1, head(equity, -1)) - 1,
       selection = do.call(rbind, selection), alpha_history = do.call(rbind, alpha_history))
}
