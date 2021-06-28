/**
 * @file
 * Implements AC strategy based on the Bill Williams' Accelerator/Decelerator oscillator.
 */

// User input params.
INPUT string __AC_Parameters__ = "-- AC strategy params --";  // >>> AC <<<
INPUT float AC_LotSize = 0;                                   // Lot size
INPUT int AC_SignalOpenMethod = 2;                            // Signal open method (-127-127)
INPUT int AC_SignalOpenFilterMethod = 32;                     // Signal open filter method
INPUT float AC_SignalOpenLevel = 0.0f;                        // Signal open level
INPUT int AC_SignalOpenBoostMethod = 0;                       // Signal open boost method
INPUT int AC_SignalCloseMethod = 2;                           // Signal close method
INPUT float AC_SignalCloseLevel = 0.0f;                       // Signal close level
INPUT int AC_PriceStopMethod = 60;                            // Price stop method
INPUT float AC_PriceStopLevel = 1;                            // Price stop level
INPUT int AC_TickFilterMethod = 32;                           // Tick filter method
INPUT float AC_MaxSpread = 4.0;                               // Max spread to trade (pips)
INPUT short AC_Shift = 0;                                     // Shift (relative to the current bar, 0 - default)
INPUT int AC_OrderCloseTime = -20;                            // Order close time in mins (>0) or bars (<0)
INPUT string __AC_Indi_AC_Parameters__ = "-- AC strategy: AC indicator params --";  // >>> AC strategy: AC indicator <<<
INPUT int AC_Indi_AC_Shift = 0;                                                     // Shift

// Structs.

// Defines struct with default user indicator values.
struct Indi_AC_Params_Defaults : ACParams {
  Indi_AC_Params_Defaults() : ACParams(::AC_Indi_AC_Shift) {}
} indi_ac_defaults;

// Defines struct with default user strategy values.
struct Stg_AC_Params_Defaults : StgParams {
  Stg_AC_Params_Defaults()
      : StgParams(::AC_SignalOpenMethod, ::AC_SignalOpenFilterMethod, ::AC_SignalOpenLevel, ::AC_SignalOpenBoostMethod,
                  ::AC_SignalCloseMethod, ::AC_SignalCloseLevel, ::AC_PriceStopMethod, ::AC_PriceStopLevel,
                  ::AC_TickFilterMethod, ::AC_MaxSpread, ::AC_Shift, ::AC_OrderCloseTime) {}
} stg_ac_defaults;

// Struct to define strategy parameters to override.
struct Stg_AC_Params : StgParams {
  StgParams sparams;

  // Struct constructors.
  Stg_AC_Params(StgParams &_sparams) : sparams(stg_ac_defaults) { sparams = _sparams; }
};

// Loads pair specific param values.
#include "config/EURUSD_H1.h"
#include "config/EURUSD_H4.h"
#include "config/EURUSD_H8.h"
#include "config/EURUSD_M1.h"
#include "config/EURUSD_M15.h"
#include "config/EURUSD_M30.h"
#include "config/EURUSD_M5.h"

class Stg_AC : public Strategy {
 public:
  Stg_AC(StgParams &_sparams, TradeParams &_tparams, ChartParams &_cparams, string _name = "")
      : Strategy(_sparams, _tparams, _cparams, _name) {}

  static Stg_AC *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_ac_defaults);
#ifdef __config__
    SetParamsByTf<StgParams>(_stg_params, _tf, stg_ac_m1, stg_ac_m5, stg_ac_m15, stg_ac_m30, stg_ac_h1, stg_ac_h4,
                             stg_ac_h8);
#endif
    // Initialize indicator.
    ACParams ac_params(_tf);
    _stg_params.SetIndicator(new Indi_AC(ac_params));
    // Initialize Strategy instance.
    ChartParams _cparams(_tf, _Symbol);
    TradeParams _tparams(_magic_no, _log_level);
    Strategy *_strat = new Stg_AC(_stg_params, _tparams, _cparams, "AC");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = GetIndicator();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    if (_is_valid) {
      IndicatorSignal _signals = _indi.GetSignals(4, _shift);
      switch (_cmd) {
        case ORDER_TYPE_BUY:
          // Buy: if the indicator values are increasing.
          _result &= _indi.IsIncreasing(3);
          _result &= _indi.IsIncByPct(_level, 0, 0, 3);
          _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
          // And the indicator is below zero.
          _result &= _method > 0 ? _indi[CURR][0] < 0 : true;
          break;
        case ORDER_TYPE_SELL:
          // Sell: if the indicator values are decreasing.
          _result &= _indi.IsDecreasing(3);
          _result &= _indi.IsDecByPct(-_level, 0, 0, 3);
          _result &= _method > 0 ? _signals.CheckSignals(_method) : _signals.CheckSignalsAll(-_method);
          // And the indicator is above zero.
          _result &= _method > 0 ? _indi[CURR][0] > 0 : true;
          break;
      }
    }
    return _result;
  }
};
