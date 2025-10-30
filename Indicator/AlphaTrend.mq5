//+------------------------------------------------------------------+
//|                                                 AlphaTrend.mq5   |
//|                        Created by ChatGPT                        |
//+------------------------------------------------------------------+
#property copyright "ChatGPT"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1  DodgerBlue
#property indicator_color2  OrangeRed
#property indicator_width1  2
#property indicator_width2  2

//--- input parameters
input int    ATR_Period = 14;
input double Multiplier = 2.0;
input int    RSI_Period = 14;
input double RSI_Buy_Level = 50;
input double RSI_Sell_Level = 50;

//--- buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double ATRBuffer[];
double RSIBuffer[];

//--- indicator handles
int atr_handle;
int rsi_handle;

//--- variables
bool uptrend;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
int OnInit()
{
   SetIndexBuffer(0, UpTrendBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, DownTrendBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetString(0, PLOT_LABEL, "AlphaTrend Up");
   PlotIndexSetString(1, PLOT_LABEL, "AlphaTrend Down");

   atr_handle = iATR(_Symbol, _Period, ATR_Period);
   if (atr_handle == INVALID_HANDLE)
   {
      Print("Failed to create ATR handle");
      return(INIT_FAILED);
   }

   rsi_handle = iRSI(_Symbol, _Period, RSI_Period, PRICE_CLOSE);
   if (rsi_handle == INVALID_HANDLE)
   {
      Print("Failed to create RSI handle");
      return(INIT_FAILED);
   }

   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Calculate AlphaTrend                                             |
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
   if (rates_total < MathMax(ATR_Period, RSI_Period))
      return 0;

   CopyBuffer(atr_handle, 0, 0, rates_total, ATRBuffer);
   CopyBuffer(rsi_handle, 0, 0, rates_total, RSIBuffer);

   int start = MathMax(1, prev_calculated - 1);

   for (int i = start; i < rates_total; i++)
   {
      double middle = (high[i] + low[i]) / 2;
      double atr = ATRBuffer[i];

      double alphaTrendUp   = middle - Multiplier * atr;
      double alphaTrendDown = middle + Multiplier * atr;

      // Xác định hướng dựa trên RSI
      if (RSIBuffer[i] > RSI_Buy_Level)
         uptrend = true;
      else if (RSIBuffer[i] < RSI_Sell_Level)
         uptrend = false;

      if (uptrend)
      {
         UpTrendBuffer[i] = alphaTrendUp;
         DownTrendBuffer[i] = EMPTY_VALUE;
      }
      else
      {
         DownTrendBuffer[i] = alphaTrendDown;
         UpTrendBuffer[i] = EMPTY_VALUE;
      }
   }

   return (rates_total);
}
