//+------------------------------------------------------------------+
//|                 EA31337 - multi-strategy advanced trading robot. |
//|                       Copyright 2016-2017, 31337 Investments Ltd |
//|                                       https://github.com/EA31337 |
//+------------------------------------------------------------------+

/*
    This file is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// Properties.
#property strict

/**
 * @file
 * Implementation of AC Strategy based on the Bill Williams' Accelerator/Decelerator oscillator.
 *
 * @docs
 * - https://docs.mql4.com/indicators/iAC
 * - https://www.mql5.com/en/docs/indicators/iAC
 */

// Includes.
#include <EA31337-classes\Strategy.mqh>
#include <EA31337-classes\Strategies.mqh>

// User inputs.
#ifdef __input__ input #endif string __AC_Parameters__ = "-- Settings for the Bill Williams' Accelerator/Decelerator oscillator --"; // >>> AC <<<
#ifdef __input__ input #endif double AC_SignalLevel = 0.00000000; // Signal level
#ifdef __input__ input #endif string AC_SignalLevels = ""; // Signal levels per timeframes
#ifdef __input__ input #endif int AC_SignalMethod = 15; // Signal method (0-?)
#ifdef __input__ input #endif string AC_SignalMethods = ""; // Signal methods per timeframes (0-?)

class AC: public Strategy {
protected:

  int       open_method = EMPTY;    // Open method.
  double    open_level  = 0.0;     // Open level.

public:

  /**
   * Update indicator values.
   */
  bool Update(int tf = EMPTY) {
    // Calculates the Bill Williams' Accelerator/Decelerator oscillator.
    for (i = 0; i < FINAL_INDICATOR_INDEX_ENTRY; i++)
      iac[period][i] = iAC(_Symbol, tf, i);
    break;
  }

  /**
   * Check if AC indicator is on buy or sell.
   *
   * @param
   *   cmd (int) - type of trade order command
   *   period (int) - period to check for
   *   signal_method (int) - signal method to use by using bitwise AND operation
   */
  bool Signal(int cmd, int tf = EMPTY, int open_method = 0, open_level = 0.0) {
      bool result = FALSE;
      if (open_method == EMPTY) open_method = this->open_method; // @fixme: This means to get the value from the class.
      if (open_level  == EMPTY) open_level  = AC::open_level; // @fixme? Get value from the current class instance.

      int period = Convert::TimeframeToPeriod(tf); // Convert.mqh

      switch (cmd) {
          /*
             @todo: Implement below logic conditions into below bit-wise cases.
             Break && || into separate bitwise lines, so the conditions can be combined based on the given open_method.

          //1. Acceleration/Deceleration <97> AC
          if ((iAC(NULL,piac,0)>=0&&iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2))||(iAC(NULL,piac,0)<=0
          && iAC(NULL,piac,0)>iAC(NULL,piac,1)&&iAC(NULL,piac,1)>iAC(NULL,piac,2)&&iAC(NULL,piac,2)>iAC(NULL,piac,3)))

          if ((iAC(NULL,piac,0)<=0&&iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2))||(iAC(NULL,piac,0)>=0
          && iAC(NULL,piac,0)<iAC(NULL,piac,1)&&iAC(NULL,piac,1)<iAC(NULL,piac,2)&&iAC(NULL,piac,2)<iAC(NULL,piac,3)))
           */
          case OP_BUY:
              bool result = @todo; // Buy: if the indicator is above zero and 2 consecutive columns are green or if the indicator is below zero and 3 consecutive columns are green
              if ((open_method &   1) != 0) result = result && Open[CURR] > Close[CURR];
              if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp); // Check if position on sell.
              if ((open_method &   4) != 0) result = result && Trade(MathMin(period + 1, M30)); // Check if strategy is signaled on higher period.
              if ((open_method &   8) != 0) result = result && Trade(cmd, M30); // Check if there is signal on M30.
              if ((open_method &  16) != 0) result = result && ...
              if ((open_method &  32) != 0) result = result && ...
              if ((open_method &  64) != 0) result = result && ...
              // ...
              break;
          case OP_SELL:
              bool result = @todo; // Sell: if the indicator is below zero and 2 consecutive columns are red or if the indicator is above zero and 3 consecutive columns are red
              if ((open_method &   1) != 0) result = result && Open[CURR] < Close[CURR];
              if ((open_method &   2) != 0) result = result && Trade(Convert::CmdOpp);
              if ((open_method &   4) != 0) result = result && Trade(cmd, MathMin(period + 1, M30));
              if ((open_method &   8) != 0) result = result && Trade(cmd, M30);
              if ((open_method &  16) != 0) result = result && ...
              if ((open_method &  32) != 0) result = result && ...
              if ((open_method &  64) != 0) result = result && ...
              // ...
              break;
      }
      result &= signal_method <= 0 || Convert::ValueToOp(curr_trend) == cmd;
      return result;
  }
};
