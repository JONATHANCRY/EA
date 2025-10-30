//+------------------------------------------------------------------+
//|                                                SuperTrend.mq5    |
//|                        Created by ChatGPT                        |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  Lime
#property indicator_color2  Red
#property indicator_width1  2
#property indicator_width2  2

//--- input parameters
input int ATR_Period = 10;
input double Multiplier = 3.0;

//--- indicator buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double ATRBuffer[];

//--- variables
int atr_handle;
bool uptrend;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, UpTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownTrendBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "SuperTrend Up");
   PlotIndexSetString(1, PLOT_LABEL, "SuperTrend Down");

   atr_handle = iATR(_Symbol, _Period, ATR_Period);
   if (atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (rates_total < ATR_Period)
      return 0;

   CopyBuffer(atr_handle, 0, 0, rates_total, ATRBuffer);

   int start = MathMax(1, prev_calculated - 1);

   for (int i = start; i < rates_total; i++)
   {
      double UpperBand = (high[i] + low[i]) / 2 + Multiplier * ATRBuffer[i];
      double LowerBand = (high[i] + low[i]) / 2 - Multiplier * ATRBuffer[i];

      if (i == 1)
         uptrend = true;
      else
      {
         if (close[i] > DownTrendBuffer[i - 1])
            uptrend = true;
         else if (close[i] < UpTrendBuffer[i - 1])
            uptrend = false;
      }

      if (uptrend)
      {
         UpTrendBuffer[i] = MathMax(LowerBand, UpTrendBuffer[i - 1]);
         DownTrendBuffer[i] = EMPTY_VALUE;
      }
      else
      {
         DownTrendBuffer[i] = MathMin(UpperBand, DownTrendBuffer[i - 1]);
         UpTrendBuffer[i] = EMPTY_VALUE;
      }
   }

   return (rates_total);
}
