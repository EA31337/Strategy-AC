/*
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_Params_M5 : StgParams {
  // Struct constructor.
  Stg_AC_Params_M5() : StgParams(stg_ac_defaults) {
    lot_size = 0;
    signal_open_method = -1;
    signal_open_filter = 1;
    signal_open_level = (float)10;
    signal_open_boost = 0;
    signal_close_method = 4;
    signal_close_level = (float)10;
    price_stop_method = 4;
    price_stop_level = 2;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ac_m5;
