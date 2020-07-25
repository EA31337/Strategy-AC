//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_EURUSD_H4_Params : Stg_AC_Params {
  Stg_AC_EURUSD_H4_Params() {
    AC_LotSize = lot_size = 0;
    AC_Shift = 0;
    AC_SignalOpenMethod = signal_open_method = 0;
    AC_SignalOpenFilterMethod = signal_open_filter = 1;
    AC_SignalOpenLevel = signal_open_level = 0;
    AC_SignalOpenBoostMethod = signal_open_boost = 0;
    AC_SignalCloseMethod = signal_close_method = 0;
    AC_SignalCloseLevel = signal_close_level = 0;
    AC_PriceLimitMethod = price_limit_method = 0;
    AC_PriceLimitLevel = price_limit_level = 2;
    AC_TickFilterMethod = tick_filter_method = 1;
    AC_MaxSpread = max_spread = 0;
  }
} stg_ac_h4;
