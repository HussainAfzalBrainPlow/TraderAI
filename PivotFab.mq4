//+------------------------------------------------------------------+
//|                                                     PivotFab.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


extern double StopLoss = 20; 
extern double TakeProfit = 21;
extern double TrailingStop = 20;
extern double Lots = 0.10;
extern double ProfitShield = 7;
extern int TimeZone=0;
extern color clOpenBuy = Blue;
extern color clCloseBuy = Aqua;
extern color clOpenSell = Red;
extern color clCloseSell = Violet;
extern color clModiBuy = Blue;
extern color clModiSell = Red;
extern string Name_Expert = "FiboPivote";
extern int Slippage = 4;
extern int hr=1;
extern bool UseSound = True;
extern string NameFileSound = "alert.wav";
int prevCountBars;
int hour=0,min=0;
double R1=0, R2=0, R3=0, S1=0, S2=0, S3=0,PP=0;
double prev_high=0, prev_open=0, prev_low=0, prev_close=0, cur_open=0, cur_high=0, cur_low=0, P=0, Q=0, nQ=0, nD=0, D=0, rates_h1[2][6];
double Buy_TP=0, Sell_TP=0, Sup=0, Res=0, ticket, SL,Tradingpoint;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer
   EventSetTimer(1);
   
      min=TimeMinute(TimeCurrent());
      Alert(Time[0],Time[1],TimeCurrent());
      FibPivoteCalculation();
   PivoteLineLabel();
   PivoteLineDraw();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- destroy timer
   EventKillTimer();
      
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  
  }
  
  //+--------------------------------------
  //|Calculate pivotes 
  /*
R3 = PP + ((High - Low) x 1.000)
R2 = PP + ((High - Low) x 0.618)
R1 = PP + ((High - Low) x 0.382)
PP = (H + L + C) / 3
S1 = PP - ((High - Low) x 0.382)
S2 = PP - ((High - Low) x 0.618)
S3 = PP - ((High - Low) x 1.000)
*/
  //+--------------------------------------
  int TimeBars(int bars)
  {
    datetime dt;
  int remains=TimeMinute(TimeCurrent())/Period();
  
  if(Period()==15)
  return remains;
  else
  {
  Comment("Error: The Current Chart is greater than 15 minutes.");
  return 0;
  }
  }
  void FibPivoteCalculation()
  {   
  ArrayCopyRates(rates_h1, Symbol(), PERIOD_H1);
  prev_open=rates_h1[1][1];
  prev_low = rates_h1[1][2]; 
  prev_high = rates_h1[1][3];
  prev_close=rates_h1[1][4];
  cur_high = rates_h1[0][3];
  cur_low = rates_h1[0][2];
  PP=NormalizeDouble((prev_close+prev_high+prev_low)/3,Digits);
  
  R3=NormalizeDouble(PP+((prev_high-prev_low)*1.000),Digits);
  R2=NormalizeDouble(PP+((prev_high-prev_low)*0.618),Digits);
  R1=NormalizeDouble(PP+((prev_high-prev_low)*0.382),Digits); 

  S3=NormalizeDouble(PP-((prev_high-prev_low)*1.000),Digits);
  S2=NormalizeDouble(PP-((prev_high-prev_low)*0.618),Digits);
  S1=NormalizeDouble(PP-((prev_high-prev_low)*0.382),Digits);   
  Comment("Pivot: "+PP+" R1: "+R1+" R2: "+R2+" R3: "+R3+" S1: "+S1+" S2: "+S2+" S3: "+S3);
  }
  
//+------------------------------------------------------------------+
//|  Pivot Lines Drawing                                                   |
//+------------------------------------------------------------------+
  void PivoteLineDraw()
  {
        if(ObjectFind("S1 line") != 0)
       {
        ObjectCreate("S1 line", OBJ_TREND,0,Time[0],S1,Time[TimeBars(1)],S1);
        ObjectSet("S1 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("S1 line",OBJPROP_WIDTH,2);
        ObjectSet("S1 line", OBJPROP_COLOR, Blue);
        ObjectSet("S2 line",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("S1 line", 0, TimeCurrent(), S1);
       }
       
      if(ObjectFind("S2 line") != 0)
       {
        ObjectCreate("S2 line", OBJ_TREND,0,S2,Time[0],TimeCurrent(),S2);
        ObjectSet("S2 line", OBJPROP_STYLE, STYLE_DASHDOT);
        ObjectSet("S2 line", OBJPROP_COLOR, Blue);
        ObjectSet("S2 line",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("S2 line", 0, Time[0], S2);
       }
      
      if(ObjectFind("S3 line") != 0)
       {
        ObjectCreate("S3 line", OBJ_TREND,0,Time[TimeBars(1)],S3,Time[0],S3);
        ObjectSet("S3 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("S3 line", OBJPROP_COLOR, Blue);
        ObjectSet("S3 label",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("S3 line", 0, Time[TimeBars(1)], S3);
       }

      if(ObjectFind("PP line") != 0)
       {
        ObjectCreate("PP line", OBJ_TREND,0,Time[TimeBars(1)],PP,Time[0],PP);
        ObjectSet("PP line",OBJPROP_WIDTH,2);
        ObjectSet("PP line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("PP line", OBJPROP_COLOR, Green);
        ObjectSet("PP line",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("PP line", 0, Time[TimeBars(1)], PP);
       }

      if(ObjectFind("R1 line") != 0)
       {
        ObjectCreate("R1 line", OBJ_TREND,0,Time[TimeBars(1)],R1,Time[0],R1);
        ObjectSet("R1 line", OBJPROP_STYLE, STYLE_SOLID);
        ObjectSet("R1 line",OBJPROP_WIDTH,2);
        ObjectSet("R1 line", OBJPROP_COLOR, Red);
       }
      else
       {
        ObjectMove("R1 line", 0, Time[TimeBars(1)], R1);
       }

      if(ObjectFind("R2 line") != 0)
       {
        ObjectCreate("R2 line", OBJ_TREND,0,Time[4],R2,Time[0],R2);
        ObjectSet("R2 line", OBJPROP_STYLE, STYLE_DASHDOT);
        ObjectSet("R2 line", OBJPROP_COLOR, Red);
       }
      else
       {
        ObjectMove("R2 line", 0, Time[TimeBars(0)], R2);
       }

      if(ObjectFind("R3 line") != 0)
       {
        ObjectCreate("R3 line", OBJ_TREND,0,Time[4],R3,Time[0],R3);
        ObjectSet("R3 line", OBJPROP_STYLE, STYLE_DOT);
        ObjectSet("R3 line", OBJPROP_COLOR, Red);
       }
      else
       {
        ObjectMove("R3 line", 0, TimeBars(0), R3);
       }
       
  }
//+------------------------------------------------------------------+
//|  Pivot Lines Labeling                                                   |
//+------------------------------------------------------------------+
  void PivoteLineLabel()
  {
     if(ObjectFind("R1 label") != 0)
      {
       ObjectCreate("R1 label", OBJ_TEXT, 0, Time[hr], R1);
       ObjectSetText("R1 label", " R1", 8, "Arial", Red);
       ObjectSet("R1 label",OBJPROP_BACK,false);
      }
     else
      {
       ObjectMove("R1 label", 0, Time[TimeBars(1)], R1);
      }

      if(ObjectFind("R2 label") != 0)
       {
        ObjectCreate("R2 label", OBJ_TEXT, 0, Time[TimeBars(1)], R2);
        ObjectSetText("R2 label", " R2", 8, "Arial", Red);
       ObjectSet("R2 label",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("R2 label", 0, Time[TimeBars(1)], R2);
       }

      if(ObjectFind("R3 label") != 0)
       {
        ObjectCreate("R3 label", OBJ_TEXT, 0, Time[20], R3);
        ObjectSetText("R3 label", " R3", 8, "Arial", Red);
        ObjectSet("R3 label",OBJPROP_BACK,false);
       }
        else
       {
        ObjectMove("R3 label", 0, Time[TimeBars(1)], R3);
       }

      if(ObjectFind("PP label") != 0)
       {
        ObjectCreate("PP label", OBJ_TEXT, 0, Time[20], PP);
        ObjectSetText("PP label", "Pivot", 8, "Arial", Green);
       ObjectSet("PP label",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("PP label", 0, Time[TimeBars(1)], PP);
       }

      if(ObjectFind("S1 label") != 0)
       {
        ObjectCreate("S1 label", OBJ_TEXT, 0, Time[20], S1);
        ObjectSetText("S1 label", "S1", 8, "Arial", Blue);
        ObjectSet("S1 label",OBJPROP_BACK,false);
       }
      else
       {
        ObjectMove("S1 label", 0, Time[TimeBars(1)], S1);
       }

      if(ObjectFind("S2 label") != 0)
       {
        ObjectCreate("S2 label", OBJ_TEXT, 0, Time[20], S2);
        ObjectSetText("S2 label", "S2", 8, "Arial", Blue);
       }
      else
       {
        ObjectMove("S2 label", 0, Time[TimeBars(1)], S2);
       }

      if(ObjectFind("S3 label") != 0)
       {
        ObjectCreate("S3 label", OBJ_TEXT, 0, Time[20], S3);
        ObjectSetText("S3 label", "S3", 8, "Arial", Blue);
       }
      else
       {
        ObjectMove("S3 label", 0, Time[TimeBars(1)], S3);
       }

  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
  
   ObjectDelete("R1 Label"); 
   ObjectDelete("R1 Line");
   
   ObjectDelete("R2 Label");
   ObjectDelete("R2 Line");
   
   ObjectDelete("R3 Label");
   ObjectDelete("R3 Line");
   
   ObjectDelete("S1 Label");
   ObjectDelete("S1 Line");
   
   ObjectDelete("S2 Label");
   ObjectDelete("S2 Line");
   
   ObjectDelete("S3 Label");
   ObjectDelete("S3 Line");
   
   ObjectDelete("PP Label");
   ObjectDelete("PP Line");
   
  int i=0, j=0;

  if(Period() > 60)
   {
    Comment("Error - Chart period is greater than 1 Hour. This will not work for this chart.");
    return ;
   }
   
   //if(min+1==TimeMinute(TimeCurrent()))
   //{
   //min++;
   //if(Time[0]/60%60)
   //Alert(" Cur:  "+TimeCurrent()+" Hr:" + TimeMinute(TimeCurrent()));
   FibPivoteCalculation();
   PivoteLineLabel();
   PivoteLineDraw();
   //}
   if(hour+1==TimeHour(TimeCurrent()))
   {
   hour++;
   //if(Time[0]/60%60)
   Alert(" Cur:  "+TimeCurrent()+" Hr:" + TimeHour(TimeCurrent()));
   FibPivoteCalculation();
   PivoteLineLabel();
   PivoteLineDraw();
   }
  }
//+------------------------------------------------------------------+
