/**
 * @file
 * Implements AC strategy.
 */

// Includes conditional compilation directives.
#include "config/define.h"

// Includes EA31337 framework.
#include <EA31337-classes/EA.mqh>
#include <EA31337-classes/Indicators/Indi_AC.mqh>
#include <EA31337-classes/Strategy.mqh>

// Inputs.
INPUT_GROUP("AC strategy: main");
input int Active_Tfs = 28;                // Activated timeframes (1-255) [M1=1,M5=2,M15=4,M30=8,H1=16,H4=32,H8=64...]
input ENUM_LOG_LEVEL Log_Level = V_INFO;  // Log level.
input bool Info_On_Chart = true;          // Display info on chart.

// Load external resources.
#ifdef __resource__
#ifdef __MQL5__
#resource "\\Indicators\\Examples\\Accelerator.ex5"
#endif
#endif

// Includes strategy.
#include "Stg_AC.mqh"

// Defines.
#define ea_name "Strategy AC"
#define ea_version "1.005"
#define ea_desc "Strategy based on EA31337 framework."
#define ea_link "https://github.com/EA31337/Strategy-AC"
#define ea_author "EA31337 Ltd"

// Properties.
#property version ea_version
#ifdef __MQL4__
#property description ea_name
#property description ea_desc
#endif
#property link ea_link
#property copyright "Copyright 2016-2021, EA31337 Ltd"
#ifdef __resource__
#ifdef __MQL5__
#property tester_indicator "::Indicators\\Examples\\Accelerator.ex5"
#property tester_library "::Indicators\\Examples\\Accelerator.ex5"
#endif
#endif

// Class variables.
EA *ea;

/* EA event handler functions */

/**
 * Implements "Init" event handler function.
 *
 * Invoked once on EA startup.
 */
int OnInit() {
  bool _result = true;
  EAParams ea_params(__FILE__, Log_Level);
  ea = new EA(ea_params);
  _result &= ea.StrategyAdd<Stg_AC>(Active_Tfs);
  return (_result ? INIT_SUCCEEDED : INIT_FAILED);
}

/**
 * Implements "Tick" event handler function (EA only).
 *
 * Invoked when a new tick for a symbol is received, to the chart of which the Expert Advisor is attached.
 */
void OnTick() {
  ea.ProcessTick();
  if (!ea.GetTerminal().IsOptimization()) {
    ea.UpdateInfoOnChart();
  }
}

/**
 * Implements "Deinit" event handler function.
 *
 * Invoked once on EA exit.
 */
void OnDeinit(const int reason) { Object::Delete(ea); }
