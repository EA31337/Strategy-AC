/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct ACParams_M30 : ACParams {
  ACParams_M30() : ACParams(indi_ac_defaults, PERIOD_M30) {
    shift = 0;
  }
} indi_ac_m30;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_Params_M30 : StgParams {
  // Struct constructor.
  Stg_AC_Params_M30() : StgParams(stg_ac_defaults) {
    lot_size = 0;
    signal_open_method = -2;
    signal_open_filter = 1;
    signal_open_level = (float)3;
    signal_open_boost = 0;
    signal_close_method = 3;
    signal_close_level = (float)10;
    price_stop_method = 4;
    price_stop_level = (float)10;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ac_m30;
