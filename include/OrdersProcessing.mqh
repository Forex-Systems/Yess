void OrdersSet(){
   bool repeat;   int ticket;   double TradeRisk, LEVEL; 
   RefreshRates(); 
   ASK      =MarketInfo(SYMBOL,MODE_ASK); 
   BID      =MarketInfo(SYMBOL,MODE_BID);    // в функции GlobalOrdersSet() ордера ставятся с одного графика на разные пары, поэтому надо знать данные пары выставляемого ордера     
   DIGITS   =MarketInfo(SYMBOL,MODE_DIGITS); // поэтому надо знать данные пары выставляемого ордера
   StopLevel=MarketInfo(SYMBOL,MODE_STOPLEVEL)*MarketInfo(SYMBOL,MODE_POINT);  
   Spred    =MarketInfo(SYMBOL,MODE_SPREAD)   *MarketInfo(SYMBOL,MODE_POINT);
   LEVEL=StopLevel+Spred;// Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
   if (SetBUY>0){ 
      repeat=true; 
      if (Real){
         LEVEL=StopLevel+Spred; Print("SetBUY: Price=",SetBUY," Stop=",SetSTOP_BUY," Profit=",SetPROFIT_BUY," Lot=",Lot," Magic=",Magic);
         TradeRisk=RiskChecker(Lot,SetBUY-SetSTOP_BUY,SYMBOL); 
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+DoubleToStr(TradeRisk,1)+"% too BIG!!! Lot="+DoubleToStr(Lot,LotDigits)+" Balance="+DoubleToStr(AccountBalance(),0)+" Stop="+DoubleToStr(SetBUY-SetSTOP_BUY,DIGITS)+" SYMBOL="+SYMBOL); return;}
         }
      while (repeat && BUY==0 && BUYSTOP==0 && BUYLIMIT==0){ // чтобы исключить повторное выставление при ошибке 128
         TerminalHold(60); // ждем 60сек освобождения терминала
         if (SetBUY-ASK>StopLevel)  {str="Set BuyStp ";   ticket=OrderSend(SYMBOL,OP_BUYSTOP, Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,Expiration,CornflowerBlue);}   else
         if (ASK-SetBUY>StopLevel)  {str="Set BuyLim ";   ticket=OrderSend(SYMBOL,OP_BUYLIMIT,Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,Expiration,CornflowerBlue);}   else
                      {SetBUY=ASK;   str="Set Buy ";      ticket=OrderSend(SYMBOL,OP_BUY,     Lot, SetBUY, 3, SetSTOP_BUY, SetPROFIT_BUY, ExpID, Magic,    0        ,CornflowerBlue);}
         if (Real){
            Report(str+DoubleToStr(SetBUY,DIGITS)+"/"+DoubleToStr(SetSTOP_BUY,DIGITS)+"/"+DoubleToStr(SetPROFIT_BUY,DIGITS)+"/"+DoubleToStr(Lot,LotDigits)+"x"+DoubleToStr(TradeRisk,1)+"%");
            OrderCheck();
            }
         if (ticket<0) repeat=ErrorCheck(); else repeat=false; 
      }  }
   if (SetSELL>0){ 
      repeat=true; 
      if (Real){
         LEVEL=StopLevel+Spred; Print("SetSELL: Price=",SetSELL," Stop=",SetSTOP_BUY," Profit=",SetPROFIT_BUY," Lot=",Lot," Magic=",Magic);
         TradeRisk=RiskChecker(Lot,SetSTOP_SELL-SetSELL,SYMBOL);
         if (TradeRisk>MaxRisk) {Report("RiskChecker="+DoubleToStr(TradeRisk,1)+"% too BIG!!! Lot="+DoubleToStr(Lot,LotDigits)+" Balance="+DoubleToStr(AccountBalance(),0)+" Stop="+DoubleToStr(SetSTOP_SELL-SetSELL,DIGITS)+" SYMBOL="+SYMBOL); return;}
         }
      while (repeat &&  SELL==0 && SELLSTOP==0 && SELLLIMIT==0){
         TerminalHold(60); // ждем 60сек освобождения терминала
         if (BID-SetSELL>StopLevel) {str="Set SellStp ";   ticket=OrderSend(SYMBOL,OP_SELLSTOP, Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,Expiration,Tomato);}   else
         if (SetSELL-BID>StopLevel) {str="Set SellLim ";   ticket=OrderSend(SYMBOL,OP_SELLLIMIT,Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,Expiration,Tomato);}   else
                      {SetSELL=BID;  str="Set Sell ";      ticket=OrderSend(SYMBOL,OP_SELL,     Lot, SetSELL, 3, SetSTOP_SELL, SetPROFIT_SELL, ExpID, Magic,      0       ,Tomato);}
         if (Real){
            Report(str+DoubleToStr(SetSELL,DIGITS)+"/"+DoubleToStr(SetSTOP_SELL,DIGITS)+"/"+DoubleToStr(SetPROFIT_SELL,DIGITS)+"/"+DoubleToStr(Lot,LotDigits)+"x"+DoubleToStr(TradeRisk,1)+"%");
            OrderCheck();
            }
         if (ticket<0) repeat=ErrorCheck(); else repeat=false; 
      }  }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   TerminalFree();
   }  

void Modify(){   // Похерим необходимые стоп/лимит ордера: удаление если Buy/Sell=0 ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ      
   if (aOrdRem[0][1]==BUY && aOrdRem[0][2]==BUYSTOP  && aOrdRem[0][3]==BUYLIMIT  && aOrdRem[0][4]==STOP_BUY  && aOrdRem[0][5]==PROFIT_BUY  && // если  эксперт не менял текущие ордера
      aOrdRem[1][1]==SELL && aOrdRem[1][2]==SELLSTOP && aOrdRem[1][3]==SELLLIMIT && aOrdRem[1][4]==STOP_SELL && aOrdRem[1][5]==PROFIT_SELL) return; // не пытаемся что-либо модифицировать
   double LEVEL; int Orders, Ord; bool ReSelect=true, repeat, make;      // если похерили какой-то ордер, надо повторить перебор сначала, т.к. OrdersTotal изменилось, т.е. они все перенумеровались 
   while (ReSelect){        // и переменная ReSelect вызовет их повторный перебор        
      TerminalHold(60); // ждем 60сек освобождения терминала
      ReSelect=false; Orders=OrdersTotal();
      for(Ord=0; Ord<Orders; Ord++){ 
         if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
            Order=OrderType();
            repeat=true; 
            RefreshRates();  str="";
            ASK      =MarketInfo(SYMBOL,MODE_ASK); 
            BID      =MarketInfo(SYMBOL,MODE_BID);    // в функции GlobalOrdersSet() ордера ставятся с одного графика на разные пары, поэтому надо знать данные пары выставляемого ордера     
            DIGITS   =MarketInfo(SYMBOL,MODE_DIGITS); // поэтому надо знать данные пары выставляемого ордера
            StopLevel=MarketInfo(SYMBOL,MODE_STOPLEVEL)*MarketInfo(SYMBOL,MODE_POINT);  
            Spred    =MarketInfo(SYMBOL,MODE_SPREAD)   *MarketInfo(SYMBOL,MODE_POINT);
            while (repeat){// повторяем операции над ордером, пока не достигнем результата
               TerminalHold(60); // поддерживаем захваченный терминал
               switch(Order){
                  case OP_SELL:        //  C L O S E   A N D   M O D I F Y    S E L L  //
                     if (SELL==0) {make=OrderClose(OrderTicket(),OrderLots(),ASK,3,Tomato); if (Real) str="Close SELL "+DoubleToStr(OrderOpenPrice(),DIGITS-1); break;}     
                     if (STOP_SELL==OrderStopLoss() && PROFIT_SELL==OrderTakeProfit()) break; // если не требуестся модификация, идем дальше
                     str="Modify Sell";     LEVEL=StopLevel+Spred; // Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
                     if (STOP_SELL!=OrderStopLoss())      {if (Real) str=str+"Stop "+DoubleToStr(OrderStopLoss(),DIGITS);      if (STOP_SELL-ASK<LEVEL)    {STOP_SELL=ASK+LEVEL;   if (STOP_SELL>OrderStopLoss())      STOP_SELL=OrderStopLoss();}}
                     if (PROFIT_SELL!=OrderTakeProfit())  {if (Real) str=str+"Profit "+DoubleToStr(OrderTakeProfit(),DIGITS);  if (ASK-PROFIT_SELL<LEVEL)  {PROFIT_SELL=ASK-LEVEL; if (PROFIT_SELL<OrderTakeProfit())  PROFIT_SELL=OrderTakeProfit();}}//Print(" ord=",ord," STOP_SELL=",STOP_SELL," OrderStopLoss=",OrderStopLoss()," PROFIT_SELL=",PROFIT_SELL," OrderTakeProfit=",OrderTakeProfit());
                     if (MathAbs(STOP_SELL-OrderStopLoss()) + MathAbs(PROFIT_SELL-OrderTakeProfit())<1*MarketInfo(SYMBOL,MODE_POINT)) str=""; // модификация всетаки не потребовалась 
                     else  make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_SELL, PROFIT_SELL,OrderExpiration(),Tomato);   //Print(" ord=",ord," STOP_SELL=",STOP_SELL," OrderStopLoss=",OrderStopLoss()," PROFIT_SELL=",PROFIT_SELL," OrderTakeProfit=",OrderTakeProfit());
                     break; 
                  case OP_SELLSTOP:    //  D E L   S E L L S T O P  //
                     if (SELLSTOP==0){ 
                        if (BID-OrderOpenPrice()>StopLevel){if (Real) str="Del SellStop "+DoubleToStr(OrderOpenPrice(),DIGITS); make=OrderDelete(OrderTicket(),Tomato);}
                        else Report("CanNot Del SELLSTOP near market! BID="+DoubleToStr(BID,DIGITS)+" OpenPrice="+DoubleToStr(OrderOpenPrice(),DIGITS)+" StopLevel="+DoubleToStr(StopLevel,DIGITS));}
                     break;
                  case OP_SELLLIMIT:   //  D E L   S E L L L I M I T  //
                     if (SELLLIMIT==0){
                        if (OrderOpenPrice()-BID>StopLevel) {if (Real) str="Del SellLimit "+DoubleToStr(OrderOpenPrice(),DIGITS);  make=OrderDelete(OrderTicket(),Tomato);}
                        else Report("CanNot Del SELLLIMIT! near market, BID="+DoubleToStr(BID,DIGITS)+" OpenPrice="+DoubleToStr(OrderOpenPrice(),DIGITS)+" StopLevel="+DoubleToStr(StopLevel,DIGITS)); }   
                     break;
                  case OP_BUY: //  C L O S E   A N D   M O D I F Y      B U Y  //////////////////////////////////////////////////////////////
                     if (BUY==0){make=OrderClose(OrderTicket(),OrderLots(),BID,3,CornflowerBlue); if (Real) str="Close BUY "+DoubleToStr(OrderOpenPrice(),DIGITS);  break;}    
                     if (STOP_BUY==OrderStopLoss() && PROFIT_BUY==OrderTakeProfit()) break;
                     str="Modify Buy";    LEVEL=StopLevel+Spred; // Спред необходимо учитывать, т.к. вход и выход из позы происходят по разным ценам (ask/bid)
                     if (STOP_BUY!=OrderStopLoss())      {if (Real) str=str+"Stop "+DoubleToStr(OrderStopLoss(),DIGITS);     if (BID-STOP_BUY<LEVEL)   {STOP_BUY=BID-LEVEL;   if (STOP_BUY<OrderStopLoss())       STOP_BUY=OrderStopLoss();}} 
                     if (PROFIT_BUY!=OrderTakeProfit())  {if (Real) str=str+"Profit "+DoubleToStr(OrderTakeProfit(),DIGITS); if (PROFIT_BUY-BID<LEVEL) {PROFIT_BUY=BID+LEVEL; if (PROFIT_BUY>OrderTakeProfit())   PROFIT_BUY=OrderTakeProfit();}}//Print(" ord=",ord," STOP_BUY=",STOP_BUY," OrderStopLoss=",OrderStopLoss()," PROFIT_BUY=",PROFIT_BUY," OrderTakeProfit=",OrderTakeProfit());
                     if (MathAbs(STOP_BUY-OrderStopLoss()) + MathAbs(PROFIT_BUY-OrderTakeProfit())<1*MarketInfo(SYMBOL,MODE_POINT)) str="";// модификация всетаки не потребовалась
                     else  make=OrderModify(OrderTicket(), OrderOpenPrice(), STOP_BUY, PROFIT_BUY,OrderExpiration(),CornflowerBlue);   //Print(" ord=",ord," STOP_BUY=",STOP_BUY," OrderStopLoss=",OrderStopLoss()," PROFIT_BUY=",PROFIT_BUY," OrderTakeProfit=",OrderTakeProfit());
                     break; 
                  case OP_BUYSTOP:  //  D E L  B U Y S T O P  //
                     if (BUYSTOP==0){
                        if (OrderOpenPrice()-ASK>StopLevel){if (Real) str="Del BuyStop "+DoubleToStr(OrderOpenPrice(),DIGITS); make=OrderDelete(OrderTicket(),CornflowerBlue);}
                        else Report("CanNot Del BUYSTOP near market! ASK="+DoubleToStr(ASK,DIGITS)+" OpenPrice="+DoubleToStr(OrderOpenPrice(),DIGITS)+" StopLevel="+DoubleToStr(StopLevel,DIGITS));}
                     break; 
                  case OP_BUYLIMIT: //  D E L  B U Y L I M I T  //
                     if (BUYLIMIT==0){
                        if (ASK-OrderOpenPrice()>StopLevel){if (Real) str="Del BuyLimit "+DoubleToStr(OrderOpenPrice(),DIGITS); make=OrderDelete(OrderTicket(),CornflowerBlue);}
                     else Report("CanNot Del BUYLIMIT near market! ASK="+DoubleToStr(ASK,DIGITS)+" OpenPrice="+DoubleToStr(OrderOpenPrice(),DIGITS)+" StopLevel="+DoubleToStr(StopLevel,DIGITS));}
                     break;
                  }
               if (Real && str!="") Report(str);
               if (!make) repeat=ErrorCheck(); else repeat=false; // если какие-то операции не выполнились, узнаем причину                 
            }  }//while(repeat)
         if (Orders!=OrdersTotal()) {ReSelect=true; break;} // при ошибках или изменении кол-ва ордеров надо заново перебирать ордера (выходим из цикла "for"), т.к. номера ордеров поменялись
         }//if (OrderSelect      
      }//while(ReSelect)     
   TerminalFree();
   }  //ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
     
void OrderCheck(){   // Узнаем подробности открытых поз//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0;  STOP_BUY=0; PROFIT_BUY=0; STOP_SELL=0; PROFIT_SELL=0;
   int BuyExpir, SellExpir, Ord;
   for (Ord=0; Ord<OrdersTotal(); Ord++){ 
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true && OrderMagicNumber()==Magic){
         if (OrderType()==6) continue; // ролловеры не записываем
         switch(OrderType()){
            case OP_BUYSTOP:  BUYSTOP=OrderOpenPrice();  STOP_BUY=OrderStopLoss();  PROFIT_BUY=OrderTakeProfit();   BuyStopTime=OrderOpenTime();   BuyExpir=OrderExpiration();  BuyLot=OrderLots();  break;
            case OP_BUYLIMIT: BUYLIMIT=OrderOpenPrice(); STOP_BUY=OrderStopLoss();  PROFIT_BUY=OrderTakeProfit();   BuyLimitTime=OrderOpenTime();  BuyExpir=OrderExpiration();  BuyLot=OrderLots();  break;
            case OP_BUY:      BUY=OrderOpenPrice();      STOP_BUY=OrderStopLoss();  PROFIT_BUY=OrderTakeProfit();   BuyTime=OrderOpenTime();       BuyExpir=OrderExpiration();  BuyLot=OrderLots();  break;
            case OP_SELLSTOP: SELLSTOP=OrderOpenPrice(); STOP_SELL=OrderStopLoss(); PROFIT_SELL=OrderTakeProfit();  SellStopTime=OrderOpenTime();  SellExpir=OrderExpiration(); SellLot=OrderLots(); break;
            case OP_SELLLIMIT:SELLLIMIT=OrderOpenPrice();STOP_SELL=OrderStopLoss(); PROFIT_SELL=OrderTakeProfit();  SellLimitTime=OrderOpenTime(); SellExpir=OrderExpiration(); SellLot=OrderLots(); break;
            case OP_SELL:     SELL=OrderOpenPrice();     STOP_SELL=OrderStopLoss(); PROFIT_SELL=OrderTakeProfit();  SellTime=OrderOpenTime();      SellExpir=OrderExpiration(); SellLot=OrderLots(); break;
      }  }  }
   aOrdRem[0][1]=BUY;  aOrdRem[0][2]=BUYSTOP;  aOrdRem[0][3]=BUYLIMIT;  aOrdRem[0][4]=STOP_BUY;  aOrdRem[0][5]=PROFIT_BUY;   // запоминаем значения ордеров
   aOrdRem[1][1]=SELL; aOrdRem[1][2]=SELLSTOP; aOrdRem[1][3]=SELLLIMIT; aOrdRem[1][4]=STOP_SELL; aOrdRem[1][5]=PROFIT_SELL;  // чтобы выяснить необходимость модификации
   }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

void OrdersCollect(){// Запишем ордера для выставления в массив. ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (SetBUY>0){ // запланировано открытие лонга
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetBUY",         SetBUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSTOP_BUY",    SetSTOP_BUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetPROFIT_BUY",  SetPROFIT_BUY);
      GlobalVariableSet(DoubleToStr(Magic,0)+"BuyExpiration",  Expiration);
      Print(Magic,"/",Symbol(),Period(),": SetBUY=",SetBUY," STOP=",SetSTOP_BUY," PROFIT=",SetPROFIT_BUY," Expiration=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES)); 
      }
   if (SetSELL>0){
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSELL",        SetSELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetSTOP_SELL",   SetSTOP_SELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SetPROFIT_SELL", SetPROFIT_SELL);
      GlobalVariableSet(DoubleToStr(Magic,0)+"SellExpiration", Expiration);
      Print(Magic,"/",Symbol(),Period(),": SetSell=",SetSELL," STOP=",SetSTOP_SELL," PROFIT=",SetPROFIT_SELL," Expiration=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES));   
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
  
struct ORDER_DATA{// данные эксперта
   int      Magic, Type, Expir, Per, Bar, HistDD, LastTestDD, TestEndTime, BackTest, ExpMemory;
   string   Sym, Coment;
   double   Price, Stop, Profit, Risk, Lot, NewLot, RevBUY, RevSELL;   
   };  
ORDER_DATA ORD[100], TMP;  
   
void GlobalOrdersSet(){ // выставление ордеров с учетом риска остальных экспертов //ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return;  // mode=0 режим выставления своих ордеров,  mode=1 режим проверки рисков
   double   NewRisk=0,  Stop=0, OpenLongRisk=0, OpenShortRisk=0,  OpenOrdMargNeed=0, LongRisk, ShortRisk, MargNeed, LotDecrease=1, LongDecrease=1, ShortDecrease=1;
   int Ord=0, Exp, Orders=100,  ExpTotal=GlobalVariableGet("ExpertsTotal");
   Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   B E G I N   *"); 
   // перепишем из глобальных переменных в массивы ПАРАМЕТРЫ НОВЫХ ОРДЕРОВ
   for (Exp=0; Exp<ExpTotal; Exp++){            // перебор массива с параметрами всех экспертов
      if (CSV[Exp].Name==ExpertName && CSV[Exp].Sym==Symbol() && CSV[Exp].Per==Period()){
         if (GlobalVariableCheck(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY")){// есть ордер для выставления
            Ord++;
            ORD[Ord].Magic  =CSV[Exp].Magic;
            ORD[Ord].Type   =10; // значит SetBUY
            ORD[Ord].Price  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY");         GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetBUY"); // тут же  
            ORD[Ord].Stop   =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_BUY");    GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_BUY"); // удаляем
            ORD[Ord].Profit =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_BUY");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_BUY"); // считанный
            ORD[Ord].Expir  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"BuyExpiration");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"BuyExpiration"); // глобал
            }      
         if (GlobalVariableCheck(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL")){// есть ордер для выставления
            Ord++;
            ORD[Ord].Magic  =CSV[Exp].Magic;
            ORD[Ord].Type   =11; // значит SetSELL
            ORD[Ord].Price  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL");         GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSELL"); // тут же  
            ORD[Ord].Stop   =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_SELL");    GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetSTOP_SELL"); // удаляем
            ORD[Ord].Profit =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_SELL");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SetPROFIT_SELL"); // считанный
            ORD[Ord].Expir  =GlobalVariableGet(DoubleToStr(CSV[Exp].Magic,0)+"SellExpiration");  GlobalVariableDel(DoubleToStr(CSV[Exp].Magic,0)+"SellExpiration"); // глобал
      }  }  }
   // запишем в массивы параметры имеющихся ордеров  (рыночных и отложенных) 
   for (int i=0; i<OrdersTotal(); i++){// перебераем все открытые и отложенные ордера всех экспертов счета и дописываем их в массив ORD. Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue; // ролловеры не записываем
         Ord++; // Print("Отложенные ордера = ",Ord," OrderType()=",OrderType());
         ORD[Ord].Type   =OrderType();             
         ORD[Ord].Sym    =OrderSymbol();
         ORD[Ord].Price  =OrderOpenPrice();
         ORD[Ord].Stop   =OrderStopLoss();
         ORD[Ord].Profit =OrderTakeProfit();
         ORD[Ord].Lot    =OrderLots();
         ORD[Ord].Magic  =OrderMagicNumber();
         ORD[Ord].Coment =OrderComment();
         ORD[Ord].Expir  =OrderExpiration();  // Print("CurrentOrder №-",Ord," OrdType=",ORD[Ord].Type," Magic=",ORD[Ord].Magic," SYMBOL=",ORD[Ord].Sym," Price=",ORD[Ord].Price," Stop=",ORD[Ord].Stop," Profit=",ORD[Ord].Profit," Expir=",TimeToStr(ORD[Ord].Expir,TIME_DATE|TIME_MINUTES)," CurLot=",ORD[Ord].Lot);                   
      }  }  // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров
   if (Ord==0) {Print("Ордеров нет"); return;}  else Orders=Ord; 
   TMP.Magic   =Magic;              TMP.TestEndTime=TestEndTime;
   TMP.Per     =Per;                TMP.LastTestDD =LastTestDD;
   TMP.Bar     =Bar;                TMP.Risk       =Risk;
   TMP.RevBUY  =RevBUY;             TMP.BackTest   =BackTest;
   TMP.HistDD  =HistDD;             TMP.RevSELL    =RevSELL;
   TMP.Sym     =SYMBOL;             TMP.ExpMemory  =ExpMemory;
   TMP.Coment  =ExpID;              
   // Пересчитаем РЕАЛЬНЫЙ РИСК КАЖДОГО ЭКСПЕРТА ЧЕРЕЗ MM(), с учетом нового баланса 
   for (Ord=1; Ord<=Orders; Ord++){
      for (Exp=0; Exp<ExpTotal; Exp++){            // из массива с параметрами всех экспертов
         if (ORD[Ord].Magic==CSV[Exp].Magic){      // пропишем риски и др. необходимую инфу
            ORD[Ord].Risk        =CSV[Exp].Risk;        // во все имеющиеся ордера
            ORD[Ord].HistDD      =CSV[Exp].HistDD;     
            ORD[Ord].LastTestDD  =CSV[Exp].LastTestDD;
            ORD[Ord].TestEndTime =CSV[Exp].TestEndTime;
            ORD[Ord].Sym         =CSV[Exp].Sym;
            ORD[Ord].Per         =CSV[Exp].Per; // период потребуется в TesterFileCreate() при отправке ErrorLog()
         }  } 
      SYMBOL=ORD[Ord].Sym;
      Stop=MathAbs(ORD[Ord].Price-ORD[Ord].Stop);
      if (ORD[Ord].Type<2){// открытый ордер
         OpenOrdMargNeed+=ORD[Ord].Lot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия лотов
         if (ORD[Ord].Type==0 && ORD[Ord].Price-ORD[Ord].Stop>0)  OpenLongRisk +=RiskChecker(ORD[Ord].Lot,Stop,SYMBOL); // если стоп еще не ушел в безубыток, считаем риск. В противном случае риск позы равен нулю
         if (ORD[Ord].Type==1 && ORD[Ord].Stop-ORD[Ord].Price>0)  OpenShortRisk+=RiskChecker(ORD[Ord].Lot,Stop,SYMBOL); // суммарный риск открытых ордеров на продажу
         continue;// считать лот для открытых ордеров не надо
         }
      Risk        =ORD[Ord].Risk*Aggress; // умножаем на агрессивность торговли, определяемую при загрузке эксперта: if (Risk>0)  Aggress=Risk; else  Aggress=1
      HistDD      =ORD[Ord].HistDD;
      LastTestDD  =ORD[Ord].LastTestDD;
      TestEndTime =ORD[Ord].TestEndTime;
      Magic       =ORD[Ord].Magic; 
      ORD[Ord].NewLot =MoneyManagement(Stop); 
      Print(Ord,". ",OrdToStr(ORD[Ord].Type)," ",ORD[Ord].Magic,"/",ORD[Ord].Sym,"  Open/Stp/Prf:",ORD[Ord].Price,"/",ORD[Ord].Stop,"/",ORD[Ord].Profit,"  CurLot=",DoubleToStr(ORD[Ord].Lot,2),"  NewLot=",DoubleToStr(ORD[Ord].NewLot,2),"  CurRisk=",DoubleToStr(RiskChecker(ORD[Ord].Lot,Stop,SYMBOL),2),"%  NewRisk=",DoubleToStr(RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL),2),"  Risk=",DoubleToStr(ORD[Ord].Risk,2)); 
      if (ORD[Ord].Type==2 || ORD[Ord].Type==4 || ORD[Ord].Type==10)// счиаем риск для лонгов
         LongRisk+=RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL); // найдем суммарный риск всех новых и отложенных ордеров
      if (ORD[Ord].Type==3 || ORD[Ord].Type==5 || ORD[Ord].Type==11)// счиаем риск для шортов
         ShortRisk+=RiskChecker(ORD[Ord].NewLot,Stop,SYMBOL); // найдем суммарный риск всех новых и отложенных ордеров
      MargNeed+=ORD[Ord].NewLot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия новых и отложенных ордеров
      }  //Print ("GlobalOrdersSet()/ РИСКИ:  Маржа открытых = ",OpenOrdMargNeed/AccountFreeMargin()*100,",  Маржа отложников и новых = ",MargNeed/AccountFreeMargin()*100,", LongRisk=",LongRisk,"%, OpenLongRisk=",OpenLongRisk,"%, ShortRisk=",ShortRisk,"%, OpenShortRisk=",OpenShortRisk,"%, Orders=",Orders);   
   // П Р О В Е Р К А   Р И С К О В  /
   if (OpenLongRisk+LongRisk>MaxRisk && LongRisk!=0){// проверка Лонгов 
      if (MaxRisk>OpenLongRisk){
         LongDecrease=0.95*(MaxRisk-OpenLongRisk)/LongRisk;   
      }else{
         LongDecrease=0; // т.е. удаляем все отложники, т.к. риск открытых поз не позволяет
         Report("Open LongOrders Risk="+DoubleToStr(OpenLongRisk,1)+"%, delete another pending LongOrders!"); // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      }  }
   if (OpenShortRisk+ShortRisk>MaxRisk && ShortRisk!=0){// проверка Шортов
      if (MaxRisk>OpenShortRisk){
         ShortDecrease=0.95*(MaxRisk-OpenShortRisk)/ShortRisk;
      }else{
         ShortDecrease=0;  // т.е. удаляем все отложники, т.к. риск открытых поз не позволяет
         Report("Open ShortOrders Risk="+DoubleToStr(OpenShortRisk,1)+"% , delete another pending ShortOrders!"); // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      }  }    
   MargNeed=0; // придется пересчитать маржу в связи с уменьшением лотов 
   for (Ord=1; Ord<=Orders; Ord++){// пересчитаем все лоты
      if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
      SYMBOL=ORD[Ord].Sym;
      if (ORD[Ord].Type==2 || ORD[Ord].Type==4 || ORD[Ord].Type==10) // счиаем риск для лонгов  
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*LongDecrease,LotDigits);// на всех лонговых отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в максимальный риск на все лонги  
      if (ORD[Ord].Type==3 || ORD[Ord].Type==5 || ORD[Ord].Type==11)// счиаем риск для шортов
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*ShortDecrease,LotDigits);// на всех шортовых отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в максимальный риск на все шорты
      MargNeed+=ORD[Ord].NewLot*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // заново пересчитываем кол-во маржи, необходимой для открытия ордеров
      }
   // П Р О В Е Р К А   М А Р Ж И  ///
   if (OpenOrdMargNeed+MargNeed>AccountFreeMargin()*MaxMargin && MargNeed!=0){// перегрузили маржу 
      if (AccountFreeMargin()*MaxMargin>OpenOrdMargNeed){
         LotDecrease=0.95*(AccountFreeMargin()*MaxMargin-OpenOrdMargNeed)/MargNeed;} // расчитаем коэффициент уменьшения риска/лота отложенных и новых ордеров (умножаеам на 0.95 для гистерезиса)
      else  LotDecrease=0; // если риск открытых ордеров превышает MaxRisk, то RiskDecrease будет отрицательным. Значит оставшиеся ордера надо удалить, обнуляя лоты.
      for (Ord=1; Ord<=Orders; Ord++){// пересчитаем все лоты
         if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
         ORD[Ord].NewLot=NormalizeDouble(ORD[Ord].NewLot*LotDecrease,LotDigits);// на всех отложниках и новых ордерах уменьшаем риск/лот, чтобы вписаться в маржу
      }  }
   // В Ы С Т А В Л Е Н И Е   О Р Д Е Р О В  
   for (Ord=1; Ord<=Orders; Ord++){
      if (ORD[Ord].Type<2) continue; // открытые (Type=0..1) НЕ ТРОГАЕМ
      if (MathAbs(ORD[Ord].Lot-ORD[Ord].NewLot)<MarketInfo(SYMBOL,MODE_LOTSTEP)) continue; 
      SYMBOL      =ORD[Ord].Sym;
      Per         =ORD[Ord].Per; // период потребуется в TesterFileCreate() при отправке ErrorLog()
      Risk        =ORD[Ord].Risk;
      HistDD      =ORD[Ord].HistDD;
      LastTestDD  =ORD[Ord].LastTestDD;
      TestEndTime =ORD[Ord].TestEndTime;
      Magic       =ORD[Ord].Magic; 
      Expiration  =ORD[Ord].Expir; 
      ExpID       =ORD[Ord].Coment;
      Stop=MathAbs(ORD[Ord].Price-ORD[Ord].Stop);// т.к. ордера ставятся с одного графика на разные пары,
      DIGITS=MarketInfo(SYMBOL,MODE_DIGITS); // поэтому надо знать данные пары выставляемого ордера
      StopLevel = MarketInfo(SYMBOL,MODE_STOPLEVEL)*MarketInfo(SYMBOL,MODE_POINT);  
      Spred     = MarketInfo(SYMBOL,MODE_SPREAD)   *MarketInfo(SYMBOL,MODE_POINT);
      OrderCheck();
      SetBUY=0;  SetSTOP_BUY =ORD[Ord].Stop; SetPROFIT_BUY =ORD[Ord].Profit; 
      SetSELL=0; SetSTOP_SELL=ORD[Ord].Stop; SetPROFIT_SELL=ORD[Ord].Profit;
      switch(ORD[Ord].Type){
         case 2:  SetBUY=ORD[Ord].Price;  BUYLIMIT=0;  break; // выбираем тип
         case 3:  SetSELL=ORD[Ord].Price; SELLLIMIT=0; break; // ордера
         case 4:  SetBUY=ORD[Ord].Price;  BUYSTOP=0;   break; // который
         case 5:  SetSELL=ORD[Ord].Price; SELLSTOP=0;  break; // нужно удалить
         case 10: SetBUY=ORD[Ord].Price;               break;
         case 11: SetSELL=ORD[Ord].Price;              break;
         } 
      Lot  =ORD[Ord].NewLot;    
      if (ORD[Ord].Type<6){// Удаление отложников
         Modify(); 
         OrderCheck();} 
      if (Lot>0){ Print("В Ы С Т А В Л Е Н И Е   О Р Д Е Р А   ",Ord,". ",Magic,"/",SYMBOL," ",OrdToStr(ORD[Ord].Type)," O/S/P",ORD[Ord].Price,"/",ORD[Ord].Stop,"/",ORD[Ord].Profit,"  Risk=",Risk,"  Lot=",Lot,"  Expiration=",TimeToStr(Expiration,TIME_DATE | TIME_MINUTES));
         OrdersSet();  // выставление заново 
      }  }  
   Magic    =TMP.Magic;       TestEndTime =TMP.TestEndTime;
   BackTest =TMP.BackTest;    ExpMemory   =TMP.ExpMemory;
   Bar      =TMP.Bar;         Risk        =TMP.Risk;
   Per      =TMP.Per;         RevBUY      =TMP.RevBUY;
   HistDD   =TMP.HistDD;      RevSELL     =TMP.RevSELL;
   SYMBOL   =TMP.Sym;         LastTestDD  =TMP.LastTestDD;
   ExpID    =TMP.Coment;
   Print(Magic,":                 *   G L O B A L   O R D E R S   S E T   E N D   *");
   }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

void BalanceCheck(){// Проверка  состояния баланса для изменения лота текущих отложников  (При инвестировании или после крупных сделок) ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   if (TimeCurrent()-GlobalVariableGet("LastOrdersCheckTime")<600) return;
   GlobalVariableSet("LastOrdersCheckTime",TimeCurrent());
   int BalanceChange=(GlobalVariableGet("LastBalance")-AccountBalance())*100/AccountBalance();
   //if (MathAbs(BalanceChange)<10  || AccountBalance()<1) return; // баланс изменился свыше 10%
   // тянем жребий, кому выставлять ордера 
   GlobalVariableSetOnCondition("CanTrade",Magic,0); // попытка захватат флага доступа к терминалу    
   Sleep(100);
   if (GlobalVariableGet("CanTrade")!=Magic) return;// первыми захватили флаг доступа к терминалу
   if (MathAbs(BalanceChange)>5){
      if (BalanceChange>0) str="increase"; else str="decrease";
      Report("Balance "+str+" on "+ DoubleToStr(MathAbs(BalanceChange),0) +"%, recount orders");
      }
   GlobalVariableSet("LastBalance",AccountBalance()); Sleep(100);
   GlobalVariableSet("CanTrade",0); // сбрасываем глобал
   GlobalOrdersSet(); // расставляем ордера
   }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

string OrdToStr(int Type){//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
   switch(Type){
      case 0:  return ("BUY"); 
      case 1:  return ("SELL");
      case 2:  return ("BUYLIMIT"); 
      case 3:  return ("SELLLIMIT");
      case 4:  return ("BUYSTOP");
      case 5:  return ("SELLSTOP");
      case 10: return ("SetBUY");
      case 11: return ("SetSELL");
      default: return ("-");
   }  }//ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 
   

