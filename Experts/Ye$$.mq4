// Вот теперь может и сбудется...    
#property copyright "Hohla"
#property link      "mail@hohla.ru"

extern int  BackTest=0;
extern int  Opt_Trades=10;// Влияет только на оптимизацию, остальные параметры и на опт ина бэктест
extern double RF_=3; // При оптимизациях отбрасываем
extern double PF_=2; // резы с худшими показателями
extern double MO_=0.2;   // множитель спреда, т.е. MO=MO_ * Spred
extern double Risk= 0; // процент депо в сделке (на реале задается в файле #.csv) Если в настройках выставить Risk>0, то риск, считанный из #.csv будет увеличен в данное количество раз
extern int  MM=1;    // 1..4 см. ММ: 
extern bool Real=false;  //
extern bool Check=false; 

extern string z2=" -  П Е Р Е М Е Н Н Ы Е   Э К С П Е Р Т А  - ";  
extern int  HL=1;    // 1..6  (1)  расчет экстремумов HL 
extern int  HLk=1;   // 1..9  (1)  переменная для расчета HL
extern int  TR=1;    // 1..11 (1)  расчет направления тренда 
extern int  TRk=1;   // 1..9  (1)  переменная для расчета тренда
extern int  PerCnt=0; // 0..2  (1) 0-Расчет периода индикаторов классическими периодами, 1-метод "веревочки", 2-метод смены цветов свечей
 
extern int  Itr=1;   // -1..1 (1)  обработка сигналов Тренда 1-без переворота, 0-игнорирование тренда, -1-реверс 
extern int  IN=1;    // 1..11 (1)  виды входных фильтров 
extern int  Ik=1;    // 1..9  (1)  переменная для фильтра входа 
extern int  Irev=1;  // -1..1 (2)  переворот сигналов входа  

extern int  Del=1;   // 0..2  (1)  удаление отложников 0=не трогаем;  1=при появлении нового сигнала удаляем; 2=при появлении нового сигнала удаляем противоположный или если ордер остался один;
extern int  Rev=0;   // 0..3  (1)  стоп переворот: 0=нет;  1-Profit=Stop-0.3*Stop; 2-Profit=Stop; 3-Profit=Stop+0.3*Stop
extern int  D=-2;    // -5..5 (1)  дельта для прибавления к ценам входа
extern int  Iprice=1;// 1..2  (2)  цена входа 1-Рынок+/-Delta, 2-Фиба от H/L
extern int  S  = 6;  // 1..9  (1)  S=ATR*(S*S*0.1+1); на ТФ>30 ставить выше 8 не имеет смысла, т.к. стоп ограничен до 7 часовых ATR
extern int  P=5;     // 1..10 (1)  P=ATR*(P*P*0.1+1), при Р>9 без профиттаргета
extern int  PM=2;    // 1..3  (1)  вид модификации ПрофитТаргета: 1-если обратное движение будет больше ATR*P, то профит зафиксируется, 2-приближение Профита при каждом откате цены против сделки, 3-приближение плавающего ПрофитТаргета  при каждом откате цены против сделки
extern int  Pm=3;    // 1..4  (1)  степень модификации ПрофитТаргета

extern int  T=7;     // 1..10 (1)  Трейлинг T*T+1; при Т>9 без трейлинга; 
extern int  TS=0;    // 0..1  (1)  Начало работы трейлинга 0-прям от стопа; 1-от цены открытия   
extern int  Tk=2;    // 1..3  (1)  Стратегия трейлинга: 1-Обычный, 2-Люстра, 3-ФИБЫ
extern int  TM=2;    // 1..2  (1)  вид модификации Трала: 0-без модификаций,  1-дальше от входа=меньше трал,  2-дальше от входа=больше трал,  3-перемещение с заданным шагом,  4-постепенное перемещение стопа к новому значению
extern int  Tm=4;    // 1..4  (1)  степень модификации Трала
 
extern int  Op= 2;   // -1..5 (1)  сигнал к закрытию принимается если прибыль больше Op*Op*0.1*ATR, при Op<0 безусловное закрытие. Работает для Основного выхода и выхода по времени
extern int  OUT=6;   // 1..6  (1)  виды выходных фильтров 
extern int  Ok=2;    // 1..9  (1)  переменная для фильтра выхода 
extern int  Orev=1;  // -1..1 (2)  переворот сигналов выхода  
extern int  Oprice=1;// 1..2  (1)  цена выхода 1-ask/bid, 2-профит на максимально достигнутой в сделке цене,

extern int  A=15;    // 7..28 (7)  кол-во баров  для долгосрочной ATR (49,196,784 баров) 
extern int  a=5;     // 3..6  (1)  кол-во баров для краткосрочной atr

extern int  tk=0;    // 0..3  (1)  (0..6 для 30минуток) 0-без временного фильтра,  >0-разрешена торговля с Tin=(tk-1)*8+T0 до Tin+T1, потом все позы херятся. Каждая единица прибавляет 8 часов к времени Т0  
extern int  T0=7;    // 1..8  (1)  при tk=0 определяет GTC: 1,2,3,5,8,13,21 бесконечно. При tk>0 время входа Tin=((8*(tk-1)+T0-1). Все в БАРАХ
extern int  T1=8;    // 1..8  (1)  при tk=0 определяет скока баров держать открытую позу: 1,3,5,8,16,24,36,бесконечно. При tk>0 количество баров в течении которых разрешена работа  с момента T0. При T1=0 || T1=8 ограничения по времени не работают  
extern int  tp=6;    // -1..5  (1)  см. Signal 6 и расчет ATR -переменная для подстройки всяких новых идей
// на стоках: tk=0..1;  Т0=-6..6 (1)(на Н1 шаг 2), Т1=0..6;  tp=-2..3
//

datetime Bar;
bool     UpTr, DnTr, Up, Dn;
int      Magic, OrdersHistory,  Order, sig, iHL, DailyConfirmation[100000], day, Today, LastYear, CanTrade, ExpMemory,
         ExpirHours, Expiration,  Trades, TestEndTime, LastDay, file, TesterFile, DIGITS, SessionStart, SessionEnd, Per,
         BuyTime, SellTime, BuyStopTime, BuyLimitTime, SellStopTime, SellLimitTime, HourIn, MinuteIn, HourOut, MinuteOut, RandomTime;
double   InitDeposit, Equity, DayMinEquity, MaxEquity, MinEquity, DrawDown,  HistDD, CurDD, LastTestDD, FullDD, Aggress,
         BUY, SELL, BUYSTOP, SELLSTOP, BUYLIMIT, SELLLIMIT, STOP_BUY, PROFIT_BUY, STOP_SELL, PROFIT_SELL, PS[30],  
         SetBUY, SetSELL, SetSTOP_BUY, SetPROFIT_BUY, SetSTOP_SELL, SetPROFIT_SELL, Lot, BuyLot, SellLot, LotDigits,
         MaxFromBuy, MinFromBuy, MaxFromSell, MinFromSell, RevBUY, RevSELL, PerAdapter, MaxRisk=5,  MaxMargin=0.7, // максимальный суммарный риск всех позиций в одну сторону (все лонги или все шорты), максимальная загрузка маржи
         StopLevel, Spred, Present, ASK, BID, ATR, atr, H, L, Mid1, Mid2, temp,  Tout, Tin, Tper; 
double   aOrdRem[2][10];  // [номер эксперта] [параметры ордера]       
string   history, str,  SYMBOL, Date, Hist, filename, ExpertName="Ye$$", TesterFileName, ExpID,
         Prm1,Prm2,Prm3,Prm4,Prm5,Prm6,Prm7,Prm8,Prm9,Prm10,Prm11,Prm12,Prm13, OptPeriod,
         Str1,Str2,Str3,Str4,Str5,Str6,Str7,Str8,Str9,Str10,Str11,Str12,Str13; 

#include <Service.mqh>       // сохранение/восстановление параметров, отчеты и др. заморочки
#include <ErrorCheck.mqh>    // проверка исполнения
#include <MoneyManagement.mqh> 
#include <OrdersProcessing.mqh>
#include <Ye$$_Input.mqh>
#include <Ye$$_Output.mqh>
#include <Ye$$_Trailing.mqh>
#include <Ye$$_Count.mqh>
#include <Ye$$_Signal.mqh>
#include <AlpariTime.mqh>
 

void OnTick(){
   if (Time[0]==Bar) {BalanceCheck(); return;}  // Сравниваем время открытия текущего(0) бара
   Statist(); // расчет параметров DD, Trades, массив с резами сделок
   for(;;){// осуществление перебора всех строк с входными параметрами за один тик (только для реала) 
      if (Before()) break; // добрались до конца файла с параметрами (для реала)
      OrderCheck();  // Узнаем подробности открытых и отложенных поз  Print("SELLSTOP=",SELLSTOP," BUYSTOP=",BUYSTOP);
      Count();     // Print(DoubleToStr(Magic,0),": S T A R T, BackTest=",BackTest," ExpBUY=",BUY+BUYSTOP+BUYLIMIT," ExpSELL=",SELL+SELLSTOP+SELLLIMIT," RevBUY=",RevBUY," ExpMemory=",ExpMemory); // Расчет основных параметров, должен стоять после OrderCheck!
      if (ATR==0) {Print("ATR==0"); return;} // дожидаемся пока просчитаются все индюки (сравнение по АТР, т.к. он самый длинный)
      if (!FineTime()) StandBy();  // не торгуем и закрываем все позы в период запрета торговли
      else{
         if (Tper>0) PositionTimer(); // может пора закрыть открытые позы?
         StopLimitDel(); // удаление отложника, если остался один (при Del=2)
         StopReverse();  // стоп с переворотом
         if (BUY>0 || SELL>0){
            TrailingStop();
            TrailingProfit();
            Output();   // стратегии выходов  
            }
         Input(); //Print("Input");
         //WeekEnd(); // закрываемся в конце сессии, чтоб не платить своп за овернайт
         Modify();  // Удаляем, модифицируем ордера перед расстановкой новых
         if (SetBUY!=0 || SetSELL!=0){ // если осалась потребность выставления нового ордера 
            if (!Real){// на тестах ставим сразу, расчитая лот
               if (Risk>0) Lot=MoneyManagement(MathMax(SetBUY-SetSTOP_BUY,SetSTOP_SELL-SetSELL)); else Lot=0.1;
               OrdersSet();
               }  
            else OrdersCollect();   // не реале собираем в файл, чтобы потом разом выставить, разделив маржу поровну с учетом ролловера
         }  }
      if (Check) ValueCheck();   // сравнение значений индикаторов Real/Test
      if (!Real) break; // выход из бесконечного цикла организован только на реале при окончании строк с входными параметрами в файле ExpertName.csv, поэтому на тестах выходим так
      After();
      }
   TheEnd(); // Print("After Bar=",Bar);  // отчет о проведенных операциях, сохранение текущих параметров       
   Bar=Time[0];   //Print("New Bar=",Bar); 
   }  
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ    
// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void WeekEnd(){   // закрываемся в конце недели /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
   if (TimeDayOfWeek(Time[1])==5 && TimeHour(AlpariTime(0))>21){  // && TimeMinute(Time[0])>=60-Period()
      BUY=0; SELL=0; SetBUY=0; SetSELL=0; SetBUY=0; SetSELL=0;
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   
void StopLimitDel(){// УДАЛЕНИЕ ОТЛОЖНИКА, ЕСЛИ ОСТАЛСЯ ОДИН  /////////////////////////////////////////////////////////////////////////////////////////////////
   if (Del!=2)  return;
   if (BUY>0){ 
      if (SELLSTOP!=0 && SELLSTOP!=RevSELL)  SELLSTOP=0;   
      if (SELLLIMIT!=0)                      SELLLIMIT=0;  
      }
   if (SELL>0){
      if (BUYSTOP!=0  && BUYSTOP!=RevBUY)    BUYSTOP=0;    
      if (BUYLIMIT!=0)                       BUYLIMIT=0;   
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

void StopReverse(){ // РЕВЕРС ОТКРЫТЫХ ПОЗ  ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   switch(Rev){// расчет времени удержания отложников (актуально при tk=0) 
      case 1: temp=-0.3;  break; 
      case 2: temp=0;     break;     
      case 3: temp=0.3;   break;
      default: return;    break;
      } 
   if (BUY>0 && STOP_BUY<BUY && BUY!=RevBUY && SELL==0 && SELLSTOP!=STOP_BUY){ // если есть открытый лонг, не закрепленный стопом, и это не переворотник от Селла и нет села, и переворотник еще не выставлен
      if (SELLSTOP!=0 || SELLLIMIT!=0) {SELLSTOP=0; SELLLIMIT=0;} // херим оставшиеся короткие позы
      RevSELL=STOP_BUY; // запомним цену отложника, чтоб не открывать по нему больше переворотников  
      SetSELL=STOP_BUY; 
      SetSTOP_SELL=BUY;
      SetPROFIT_SELL=SetSELL-(SetSTOP_SELL-SetSELL)-temp*(BUY-STOP_BUY); //  Print(" Щас поставим переворот на имеющийся BUY setSELL=",SetSELL," STOP_SELL=",STOP_SELL," PROFIT_SELL=",PROFIT_SELL," RevSELL=",RevSELL);
      }
   if (SELL>0 && STOP_SELL>SELL && SELL!=RevSELL && BUY==0 && BUYSTOP!=STOP_SELL){           //Print("BUYSTOP=",BUYSTOP," STOP_SELL=",STOP_SELL," RevBUY=",RevBUY);
      if (BUYSTOP!=0 || BUYLIMIT!=0) {BUYSTOP=0; BUYLIMIT=0;} 
      RevBUY=STOP_SELL; // запомним цену отложника, чтоб не открывать по нему больше переворотников 
      SetBUY=STOP_SELL; 
      SetSTOP_BUY=SELL; //Print("  Щас поставим переворот на имеющийся SELL 
      SetPROFIT_BUY=SetBUY+(SetBUY-SetSTOP_BUY)+temp*(STOP_SELL-SELL);
      }
   if (SELLSTOP==RevSELL && (BUY==0  || STOP_BUY>BUY))   SELLSTOP=0; // если вышли в безубыток или вовсе закрылись, снимаем переворотник
   if (BUYSTOP==RevBUY   && (SELL==0 || STOP_SELL<SELL)) BUYSTOP=0;  // штоб не спутать его с системным ордером, проверяем по цене RevBUY/RevSELL
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ 

void PositionTimer(){   // ВРЕМЯ УДЕРЖАНИ ОТКРЫТЫХ ПОЗ (В Барах) /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////   
   double TimeProfit;
   if (tp<0)  TimeProfit=-20*ATR; // при отрицательных значениях tp поХ c каким кушем выходить
   else       TimeProfit=(tp)*(tp)*0.1*ATR; // пороговая прибыль, без которой не закрываемся 0.1  0.4  0.9  1.6  2.5  3.6
   if (BUY>0 && (AlpariTime(0)-BuyTime)/60/Period()>=Tper){ //Print("dTime=",(Time[0]-BuyTime)/3600.0);
      if (Bid-BUY>TimeProfit)  BUY=0;  // достаточно профита, чтоб сразу закрыться
      else  if (PROFIT_BUY==0 || PROFIT_BUY>BUY+TimeProfit)  PROFIT_BUY=BUY+TimeProfit; // Перетащим профит на уровень жадности
      } 
   if (SELL>0 && (AlpariTime(0)-SellTime)/60/Period()>=Tper){
      if (SELL-Ask>TimeProfit) SELL=0;  
      else  if (PROFIT_SELL==0 || PROFIT_SELL<SELL-TimeProfit)  PROFIT_SELL=SELL-TimeProfit;
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void StandBy(){ // Закрытие всех поз в период запрета торговли //////////////////////////////////////////////////////////////////////////////////////////////////////
   double TimeProfit;
   if (tp<0)  TimeProfit=-20*ATR; // при отрицательных значениях tp поХ c каким кушем выходить
   else       TimeProfit=(tp)*(tp)*0.1*ATR; // пороговая прибыль, без которой не закрываемся 0.1  0.4  0.9  1.6  2.5  3.6
   if (BUY>0){//Print("Buy=",BUY);
      if (Bid-BUY>TimeProfit)  BUY=0;  // достаточно профита, чтоб сразу закрыться
      else  if (PROFIT_BUY==0 || PROFIT_BUY>BUY+TimeProfit)  PROFIT_BUY=BUY+TimeProfit; // Перетащим профит на уровень жадности
      }
   if (SELL>0){//Print("Sell=",SELL);
      if (SELL-Ask>TimeProfit) SELL=0;  
      else  if (PROFIT_SELL==0 || PROFIT_SELL<SELL-TimeProfit)  PROFIT_SELL=SELL-TimeProfit;
      }
   BUYSTOP=0; BUYLIMIT=0; SELLSTOP=0; SELLLIMIT=0; // Если остались отложники, херим все
   Modify();// все закрываем, удаляем, модифицируем
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   
         
   
   