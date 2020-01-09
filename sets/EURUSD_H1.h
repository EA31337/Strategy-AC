//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_EURUSD_H1_Params : Stg_AC_Params {
  Stg_AC_EURUSD_H1_Params() {
    symbol = "EURUSD";
    tf = PERIOD_H1;
    AC_Shift = 0;
    AC_TrailingStopMethod = 0;
    AC_TrailingProfitMethod = 0;
    AC_SignalOpenLevel = 0;
    AC_SignalBaseMethod = 0;
    AC_SignalOpenMethod1 = 0;
    AC_SignalCloseLevel = 0;
    AC_SignalCloseMethod1 = 0;
    AC_SignalCloseMethod2 = 0;
    AC_MaxSpread = 0;
  }
};
