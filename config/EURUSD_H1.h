/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct ACParams_H1 : ACParams {
  ACParams_H1() : ACParams(indi_ac_defaults, PERIOD_H1) { shift = 0; }
} indi_ac_h1;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_Params_H1 : StgParams {
  // Struct constructor.
  Stg_AC_Params_H1() : StgParams(stg_ac_defaults) {
    lot_size = 0;
    signal_open_method = 0;
    signal_open_filter = 1;
    signal_open_level = (float)0.1;
    signal_open_boost = 0;
    signal_close_method = 0;
    signal_close_level = (float)0.1;
    price_stop_method = 0;
    price_stop_level = (float)2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ac_h1;
