/**
 * @file
 * Defines default strategy parameter values for the given timeframe.
 */

// Defines indicator's parameter values for the given pair symbol and timeframe.
struct Indi_AC_Params_M15 : Indi_AC_Params {
  Indi_AC_Params_M15() : Indi_AC_Params(indi_ac_defaults, PERIOD_M15) {
    shift = 0;
  }
} indi_ac_m15;

// Defines strategy's parameter values for the given pair symbol and timeframe.
struct Stg_AC_Params_M15 : StgParams {
  // Struct constructor.
  Stg_AC_Params_M15() : StgParams(stg_ac_defaults) {
    lot_size = 0;
    signal_open_method = 4;
    signal_open_filter = 10;
    signal_open_level = (float)9;
    signal_open_boost = 1;
    signal_close_method = -1;
    signal_close_level = (float)15;
    price_stop_method = 4;
    price_stop_level = (float)15;
    tick_filter_method = 1;
    max_spread = 0;
  }
} stg_ac_m15;
