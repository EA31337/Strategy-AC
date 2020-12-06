/**
 * @file
 * Implements AC strategy based on the Bill Williams' Accelerator/Decelerator oscillator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_AC.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT float AC_LotSize = 0;                // Lot size
INPUT int AC_SignalOpenMethod = 1;         // Signal open method (0-1)
INPUT int AC_SignalOpenFilterMethod = 1;   // Signal open filter method
INPUT float AC_SignalOpenLevel = 0.0004f;  // Signal open level (>0.0001)
INPUT int AC_SignalOpenBoostMethod = 0;    // Signal open boost method
INPUT int AC_SignalCloseMethod = 0;        // Signal close method
INPUT float AC_SignalCloseLevel = 0;       // Signal close level
INPUT int AC_PriceStopMethod = 0;          // Price stop method
INPUT float AC_PriceStopLevel = 2;         // Price stop level
INPUT int AC_TickFilterMethod = 0;         // Tick filter method
INPUT float AC_MaxSpread = 6.0;            // Max spread to trade (pips)
INPUT int AC_Shift = 0;                    // Shift (relative to the current bar, 0 - default)

// Structs.

// Defines struct with default user strategy values.
struct Stg_AC_Params_Defaults : StgParams {
  Stg_AC_Params_Defaults()
      : StgParams(::AC_SignalOpenMethod, ::AC_SignalOpenFilterMethod, ::AC_SignalOpenLevel, ::AC_SignalOpenBoostMethod,
                  ::AC_SignalCloseMethod, ::AC_SignalCloseLevel, ::AC_PriceStopMethod, ::AC_PriceStopLevel,
                  ::AC_TickFilterMethod, ::AC_MaxSpread, ::AC_Shift) {}
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
  Stg_AC(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_AC *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    StgParams _stg_params(stg_ac_defaults);
    if (!Terminal::IsOptimization()) {
      SetParamsByTf<StgParams>(_stg_params, _tf, stg_ac_m1, stg_ac_m5, stg_ac_m15, stg_ac_m30, stg_ac_h1, stg_ac_h4,
                               stg_ac_h8);
    }
    // Initialize indicator.
    ACParams ac_params(_tf);
    _stg_params.SetIndicator(new Indi_AC(ac_params));
    // Initialize strategy parameters.
    _stg_params.GetLog().SetLevel(_log_level);
    _stg_params.SetMagicNo(_magic_no);
    _stg_params.SetTf(_tf, _Symbol);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_AC(_stg_params, "AC");
    _stg_params.SetStops(_strat, _strat);
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, int _method = 0, float _level = 0.0f, int _shift = 0) {
    Indicator *_indi = Data();
    bool _is_valid = _indi[CURR].IsValid();
    bool _result = _is_valid;
    switch (_cmd) {
      case ORDER_TYPE_BUY:
        // Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and
        // ...
        // ... 1 consecutive column is green.
        _result &= _indi[0][0] > _level && _indi[0][0] > _indi[1][0] && _indi[1][0] > _indi[2][0];
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi[2][0] > _indi[3][0];  // ... 3 consecutive columns are green.
          if (METHOD(_method, 1)) _result &= _indi[3][0] > _indi[4][0];  // ... 4 consecutive columns are green.
        }
        break;
      case ORDER_TYPE_SELL:
        // Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and
        // ...
        // ... 1 consecutive column is red.
        _result &= _indi[0][0] < -_level && _indi[0][0] < _indi[1][0] && _indi[1][0] < _indi[2][0];
        if (_method != 0) {
          if (METHOD(_method, 0)) _result &= _indi[2][0] < _indi[3][0];  // ... 3 consecutive columns are red.
          if (METHOD(_method, 1)) _result &= _indi[3][0] < _indi[4][0];  // ... 4 consecutive columns are red.
        }
        break;
    }
    return _result;
  }

  /**
   * Gets price stop value for profit take or stop loss.
   */
  float PriceStop(ENUM_ORDER_TYPE _cmd, ENUM_ORDER_TYPE_VALUE _mode, int _method = 0, float _level = 0.0f) {
    Indicator *_indi = Data();
    double _trail = _level * Market().GetPipSize();
    int _bar_count = (int)_level * 10;
    int _direction = Order::OrderDirection(_cmd, _mode);
    double _default_value = Market().GetCloseOffer(_cmd) + _trail * _method * _direction;
    double _result = _default_value;
    ENUM_APPLIED_PRICE _ap = _direction > 0 ? PRICE_HIGH : PRICE_LOW;
    switch (_method) {
      case 1:
        _result = _indi.GetPrice(
            _ap, _direction > 0 ? _indi.GetHighest<double>(_bar_count) : _indi.GetLowest<double>(_bar_count));
        break;
    }
    return (float)_result;
  }
};
