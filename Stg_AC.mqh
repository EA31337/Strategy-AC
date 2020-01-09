//+------------------------------------------------------------------+
//|                  EA31337 - multi-strategy advanced trading robot |
//|                       Copyright 2016-2020, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/**
 * @file
 * Implements AC strategy based on the Bill Williams' Accelerator/Decelerator oscillator.
 */

// Includes.
#include <EA31337-classes/Indicators/Indi_AC.mqh>
#include <EA31337-classes/Strategy.mqh>

// User input params.
INPUT string __AC_Parameters__ = "-- AC strategy params --";  // >>> AC <<<
INPUT int AC_Active_Tf = 0;  // Activate timeframes (1-255, e.g. M1=1,M5=2,M15=4,M30=8,H1=16,H2=32,H4=64...)
INPUT ENUM_TRAIL_TYPE AC_TrailingStopMethod = 3;     // Trail stop method
INPUT ENUM_TRAIL_TYPE AC_TrailingProfitMethod = 22;  // Trail profit method
INPUT int AC_Shift = 0;                              // Shift (relative to the current bar, 0 - default)
INPUT double AC_SignalOpenLevel = 0.0004;            // Signal open level (>0.0001)
INPUT int AC_SignalBaseMethod = 1;                   // Signal base method (0-1)
INPUT long AC_SignalOpenMethod1 = 0;                 // Signal open method 1 (0-1023)
INPUT long AC_SignalOpenMethod2 = 0;                 // Signal open method 2 (0-1023)
INPUT double AC_SignalCloseLevel = 0.0004;           // Signal close level (>0.0001)
INPUT ENUM_MARKET_EVENT AC_SignalCloseMethod1 = 0;   // Signal close method 1
INPUT ENUM_MARKET_EVENT AC_SignalCloseMethod2 = 0;   // Signal close method 2
INPUT double AC_MaxSpread = 6.0;                     // Max spread to trade (pips)

// Struct to define strategy parameters to override.
struct Stg_AC_Params : Stg_Params {
  unsigned int AC_Period;
  ENUM_APPLIED_PRICE AC_Applied_Price;
  int AC_Shift;
  ENUM_TRAIL_TYPE AC_TrailingStopMethod;
  ENUM_TRAIL_TYPE AC_TrailingProfitMethod;
  double AC_SignalOpenLevel;
  long AC_SignalBaseMethod;
  long AC_SignalOpenMethod1;
  long AC_SignalOpenMethod2;
  double AC_SignalCloseLevel;
  ENUM_MARKET_EVENT AC_SignalCloseMethod1;
  ENUM_MARKET_EVENT AC_SignalCloseMethod2;
  double AC_MaxSpread;

  // Constructor: Set default param values.
  Stg_AC_Params()
      : AC_Shift(::AC_Shift),
        AC_TrailingStopMethod(::AC_TrailingStopMethod),
        AC_TrailingProfitMethod(::AC_TrailingProfitMethod),
        AC_SignalOpenLevel(::AC_SignalOpenLevel),
        AC_SignalBaseMethod(::AC_SignalBaseMethod),
        AC_SignalOpenMethod1(::AC_SignalOpenMethod1),
        AC_SignalOpenMethod2(::AC_SignalOpenMethod2),
        AC_SignalCloseLevel(::AC_SignalCloseLevel),
        AC_SignalCloseMethod1(::AC_SignalCloseMethod1),
        AC_SignalCloseMethod2(::AC_SignalCloseMethod2),
        AC_MaxSpread(::AC_MaxSpread) {}
};

// Loads pair specific param values.
#include "sets/EURUSD_H1.h"
#include "sets/EURUSD_H4.h"
#include "sets/EURUSD_M1.h"
#include "sets/EURUSD_M15.h"
#include "sets/EURUSD_M30.h"
#include "sets/EURUSD_M5.h"

class Stg_AC : public Strategy {
 public:
  Stg_AC(StgParams &_params, string _name) : Strategy(_params, _name) {}

  static Stg_AC *Init(ENUM_TIMEFRAMES _tf = NULL, long _magic_no = NULL, ENUM_LOG_LEVEL _log_level = V_INFO) {
    // Initialize strategy initial values.
    Stg_AC_Params _params;
    switch (_tf) {
      case PERIOD_M1: {
        Stg_AC_EURUSD_M1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M5: {
        Stg_AC_EURUSD_M5_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M15: {
        Stg_AC_EURUSD_M15_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_M30: {
        Stg_AC_EURUSD_M30_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H1: {
        Stg_AC_EURUSD_H1_Params _new_params;
        _params = _new_params;
      }
      case PERIOD_H4: {
        Stg_AC_EURUSD_H4_Params _new_params;
        _params = _new_params;
      }
    }
    // Initialize strategy parameters.
    ChartParams cparams(_tf);
    IndicatorParams ac_iparams(10, INDI_AC);
    StgParams sparams(new Trade(_tf, _Symbol), new Indi_AC(ac_iparams, cparams), NULL, NULL);
    sparams.logger.SetLevel(_log_level);
    sparams.SetMagicNo(_magic_no);
    sparams.SetSignals(_params.AC_SignalBaseMethod, _params.AC_SignalOpenMethod1, _params.AC_SignalOpenMethod2,
                       _params.AC_SignalCloseMethod1, _params.AC_SignalCloseMethod2, _params.AC_SignalOpenLevel,
                       _params.AC_SignalCloseLevel);
    sparams.SetStops(_params.AC_TrailingProfitMethod, _params.AC_TrailingStopMethod);
    sparams.SetMaxSpread(_params.AC_MaxSpread);
    // Initialize strategy instance.
    Strategy *_strat = new Stg_AC(sparams, "AC");
    return _strat;
  }

  /**
   * Check strategy's opening signal.
   *
   */
  bool SignalOpen(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    bool _result = false;
    double ac_0 = ((Indi_AC *)this.Data()).GetValue(0);
    double ac_1 = ((Indi_AC *)this.Data()).GetValue(1);
    double ac_2 = ((Indi_AC *)this.Data()).GetValue(2);
    if (_signal_method == EMPTY) _signal_method = GetSignalBaseMethod();
    if (_signal_level == EMPTY) _signal_level = GetSignalOpenLevel();
    bool is_valid = fmin(fmin(ac_0, ac_1), ac_2) != 0;
    switch (_cmd) {
      /*
        //1. Acceleration/Deceleration - AC
        //Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and
        3 consecutive columns are green
        //Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and 3
        consecutive columns are red if
        ((iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2))||(iAC(NULL,piac,0)<=0
        && iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2)&&iAC(NULL,piac,2)>iAC(NULL,piac,3)))
        if
        ((iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2))||(iAC(NULL,piac,0)>=0
        && iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2)&&iAC(NULL,piac,2)<iAC(NULL,piac,3)))
      */
      case ORDER_TYPE_BUY:
        _result = ac_0 > _signal_level && ac_0 > ac_1;
        if (_signal_method != 0) {
          _result &= is_valid;
          if (METHOD(_signal_method, 0)) _result &= ac_1 > ac_2;  // @todo: one more bar.
          // if (METHOD(_signal_method, 0)) _result &= ac_1 > ac_2;
        }
        break;
      case ORDER_TYPE_SELL:
        _result = ac_0 < -_signal_level && ac_0 < ac_1;
        if (_signal_method != 0) {
          _result &= is_valid;
          if (METHOD(_signal_method, 0)) _result &= ac_1 < ac_2;  // @todo: one more bar.
          // if (METHOD(_signal_method, 0)) _result &= ac_1 < ac_2;
        }
        break;
    }
    return _result;
  }

  /**
   * Check strategy's closing signal.
   *
   */
  bool SignalClose(ENUM_ORDER_TYPE _cmd, long _signal_method = EMPTY, double _signal_level = EMPTY) {
    if (_signal_level == EMPTY) _signal_level = GetSignalCloseLevel();
    return SignalOpen(Order::NegateOrderType(_cmd), _signal_method, _signal_level);
  }
};
