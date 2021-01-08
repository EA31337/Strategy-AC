/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct ACParams_M15 : ACParams {
  ACParams_M15() : ACParams(indi_ac_defaults, PERIOD_M15) { shift = 0; }
} indi_ac_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_Params_M15 : StgParams {
  // Struct constructor.
  Stg_AC_Params_M15() : StgParams(stg_ac_defaults) {
    lot_size = 0;
    signal_open_method = -4;
    signal_open_filter = 8;
    signal_open_level = (float)0.1;
    signal_open_boost = 1;
    signal_close_method = 0;
    signal_close_level = (float)0.1;
    price_stop_method = 0;
    price_stop_level = (float)0.1;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ac_m15;
