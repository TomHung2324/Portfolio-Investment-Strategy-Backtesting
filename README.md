# Portfolio Investment Strategy Backtesting

**FN6901 group assignment | R · Quarto · Portfolio backtesting · Fama–French three-factor model**

This project compares nine U.S. sector ETF allocation strategies against the SPY benchmark over a historical sample ending October 2021. It studies buy-and-hold equal weighting, quarterly and annual equal-weight rebalancing, and monthly selection of the five sector ETFs with the highest estimated Fama–French three-factor intercepts (alphas).

## Backtest results

[View the full backtesting report (PDF)](report/FN6901_Portfolio_Investment_Back-testing.pdf)

| Strategy | CAGR | Annualized volatility | Sharpe* | Maximum drawdown | Terminal wealth ($1 initial) |
|---|---:|---:|---:|---:|---:|
| SPY | 7.47% | 19.64% | 0.3805 | -55.20% | 4.8480 |
| Equal-weight buy & hold | 7.79% | 18.68% | 0.4173 | -52.32% | 5.1743 |
| Equal-weight quarterly | 8.41% | 18.70% | 0.4497 | -52.98% | 5.8616 |
| Equal-weight annual | **8.48%** | 18.59% | **0.4563** | -52.86% | **5.9498** |
| Fama–French alpha top five | 8.44% | 19.02% | 0.4437 | **-50.95%** | 5.8956 |

*The assignment defines Sharpe as CAGR divided by annualized daily-return volatility, with a zero risk-free rate. Figures are from the rendered assignment report and are historical, not forward-looking.

## Methods

- **Universe:** XLB, XLE, XLF, XLI, XLK, XLP, XLU, XLV and XLY; **benchmark:** SPY.
- **Prices:** pre-downloaded adjusted close; sample begins November 1999 and ends October 8, 2021.
- **Equal-weight strategies:** initially allocate 1/9 to each sector. Rebalance at the close every 63 or 252 return observations, effective from the following day's return.
- **Factor selection:** estimate the intercept of each ETF's excess daily returns regressed on market excess return, SMB and HML over a rolling 63-day window. Re-select the top five every 21 trading days; new holdings become effective on the following trading day. Hold cash until the first eligible rebalance.
- **Metrics:** CAGR, annualized volatility, assignment-style Sharpe ratio, maximum drawdown, terminal wealth, and ETF-level contribution/risk rankings.

## Project files

The intended repository contents are the main Quarto source (`port_invest.qmd`), its R helper (`portfolio_helpers.R`), and the final PDF report (`report/FN6901_Portfolio_Investment_Back-testing.pdf`). The original ETF and Fama–French data snapshots are not included. The report is viewable without R; reproducing the backtest requires the original datasets.

## Reproduce

Install R, Quarto and the packages loaded at the top of `port_invest.qmd` (`conflicted`, `tidyverse`, `lubridate`, `kableExtra`, `frenchdata`, `patchwork`). From the directory containing the `.qmd`, `.R` helper and datasets, run:

```bash
quarto render port_invest.qmd --to html
```

The source assumes relative paths. To reproduce, place the `SPDR/` folder and `F-F_Research_Data_Factors_Daily_CSV.rds` next to the `.qmd`. These input data files are intentionally omitted from the compact portfolio showcase.

## Interpretation and limitations

Annual equal-weight rebalancing had the strongest historical CAGR and assignment-style Sharpe ratio; the alpha top-five strategy had the least severe maximum drawdown. These comparisons do **not** establish statistical significance or out-of-sample profitability. The experiment excludes transaction costs, slippage, taxes and market impact; short-window alpha estimates may be noisy, and the selection strategy has concentration and turnover risk.

## Attribution

**Portfolio Investment** was the component independently assigned to and completed by **Shuo Yan Hung** within the FN6901 group assignment.Course materials and underlying data remain subject to their respective sharing rules.
