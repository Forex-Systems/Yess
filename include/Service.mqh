// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
void OnInit(){// функции сохранения и восстановления параметров на случай отключения терминала в течении часа // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!IsTesting() && !IsOptimization()) {Real=true; Check=true;} // на реале формирование файла проверки обязательно  
   InitDeposit=AccountBalance();DayMinEquity=InitDeposit;
   SYMBOL=Symbol();
   Date=TimeToStr(TimeCurrent(),TIME_DATE); // дата начала оптимизации/тестированиЯ
   if (MarketInfo(Symbol(),MODE_LOTSTEP)<0.1) LotDigits=2; else LotDigits=1;
   int ExpTotal;
   if (Real){
      if (Bars<1000) MessageBox("Before(): История котировок содержит меньше 1000 бар!"); // история слишком короткая, индикаторы могут посчитаться неверно
      BackTest=0; // для реала - флаг начала торгового цикла
      int ms=MathRand(); while (ms>100) ms-=100;  ms*=10; Sleep(ms); 
      if (Risk==0) Aggress=1; // Если в настройках выставить риск>0, то риск, считанный из #.csv будет увеличен в данное количество раз. 
      else {Aggress=Risk; MaxRisk*=Risk; Alert(" WARNING, Risk x ",Aggress,"  MaxRisk=",MaxRisk, " !!!");} 
      ExpTotal=InputFileRead(0); // занесение в массив считанных из csv файла входных параметров всех экспертов
      GlobalVariableSet("ExpertsTotal",ExpTotal); // количество торгующих экспертов
      GlobalVariableSet("RepFile",0); // флаг доступа к файлу с репортами
      GlobalVariableSet("CanTrade",0); // заводим глобал для огранизации доступа к терминалу
      Print("Init() ",Symbol()+Period(), " Время бара последнего запуска ",TimeToStr(Bar,TIME_DATE | TIME_MINUTES),", кол-во экспертов в файле параметров =",ExpTotal,", пауза перед стартом =",ms,"мс");
      if (UninitializeReason()==1) Report("Last Exit=Program Remove");
      FileDelete("Reports.csv"); 
      }
   else{
      if (BackTest>0){// Загрузка параметров эксперта из файла отчета *.csv.
         ExpTotal=InputFileRead(BackTest); // занесение в массив считанных из csv файла входных параметров из строки BackTest
         if (ExpTotal<0) {BackTest=ExpTotal; Print(" НЕ ТОТ таймфрейм, инструмент, эксперт");}
         double RiskTmp=Risk;
         DataRead(0); // считываем параметры этой строки в переменные эксперта
         Risk=RiskTmp; 
         }
      TimeCounter();
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

struct EXPERTS_DATA{// данные эксперта
   int      Per, HistDD, LastTestDD, Magic, TestEndTime, ExpMemory, Bar, Param[50];
   string   Sym, Name;
   double   Risk, RevBUY, RevSELL, Lot;   
   };
EXPERTS_DATA CSV[100], PRM[100];    
  
int InputFileRead (int ReadLine){// занесение в массив считанных из csv файла входных параметров   ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string InputFileName="#.csv"; 
   int InputFile=-1, StartWaiting=TimeLocal(), chr; 
   while (InputFile<0){
      InputFile=FileOpen(InputFileName, FILE_READ | FILE_SHARE_READ); 
      Sleep(500); // для разгрузки процессора 
      if (TimeLocal()-StartWaiting>120) {Report("init(): Can not open file "+InputFileName+"!"); StartWaiting=TimeLocal();}
      } 
   for (chr=0; chr<ReadLine-2; chr++){ // добираемся до нужной строки
      str=FileReadString(InputFile); while (!FileIsLineEnding(InputFile)) str=FileReadString(InputFile); // читаем всю херь, пока не кончилась строка 
      }     
   int Column, StrPosition, Exp=0,  TheSameChart=0; 
   while (!FileIsEnding(InputFile)){ 
      str=FileReadString(InputFile); while (!FileIsLineEnding(InputFile)) str=FileReadString(InputFile); // читаем всю херь, пока не кончилась строка 
      str=FileReadString(InputFile); // считываем первый столбец с именем эксперта, датами оптимизации и спредами 
      if (StringFind(str," ",0)<0 || StringFind(str,"-",0)<0) continue; // если в первом столбце не найдены символы " " и "-" то это левая строка, и параметры из нее не читаем
      StrPosition=StringFind(str," ",0); // ищем в строке пробел
      CSV[Exp].Name=StringSubstr(str,0,StrPosition); 
      //if (CSV[Exp].Name!=ExpertName) continue;   // эксперты из другой серии пропускаем
      StrPosition=StringFind(str,"-",10); // ищем "-" разелитель между началом и концом теста
      CSV[Exp].TestEndTime=StrToTime(StringSubstr(str,StrPosition+1,10)); // дату конца теста сразу переводим в секунды  Print("Seconds=",TestEndTime," TestEndTime=",TimeToStr(TestEndTime,TIME_DATE));
      StrPosition=StringFind(str,"OPT-",30); // ищем "OPT-" надпись перед сохраненным периодом оптимизации
      if (StrPosition>0) OptPeriod=StringSubstr(str,StrPosition+4,0); else OptPeriod="UnKnown"; //Print("OptPeriod=",OptPeriod);// период начальной оптимизации, сохраненный при самой первой оптимизации
      str=FileReadString(InputFile);// считываем второй столбец с названием пары и ТФ     
      for (chr=0; chr<StringLen(str); chr++)  // Print("s=",StringSubstr(str,chr,1)," cod=",StringGetChar(str,chr));      
         if (StringGetChar(str,chr)>47 && StringGetChar(str,chr)<58) break; // попалось число с кодом: ("0"-48, "1"-49, "2"-50,..., "9"-57)
      CSV[Exp].Sym=StringSubstr(str,0,chr); 
      CSV[Exp].Per=StrToDouble(StringSubstr(str,chr,0));       //Print(" Name=",CSV[Exp].Name," Sym=",CSV[Exp].Sym," Per=",CSV[Exp].Per);
      for (Column=3; Column<15; Column++){ // все столбцы, включая magic
         str=FileReadString(InputFile); // читаем просадки HistDD и LastTestDD
         if (Column==7){
            StrPosition=StringFind(str,"_",0);
            CSV[Exp].HistDD=StrToDouble(StringSubstr(str,0,StrPosition));         //Print("aHistDD[",Exp,"]=",CSV[Exp].HistDD);
            CSV[Exp].LastTestDD=StrToDouble(StringSubstr(str,StrPosition+1,0));   //Print("aLastTestDD[",Exp,"]=",CSV[Exp].LastTestDD);
         }  }   
      CSV[Exp].Risk =StrToDouble(FileReadString(InputFile)); // 15-й столбец (Risk)
      CSV[Exp].Magic=StrToDouble(FileReadString(InputFile)); // 16-й столбец (Magic) нельзя прописывать значение в Magic, т.к. в Before() его надо обновлять только при совпадении Expert,Sym,Per. В GlobalOrdersSet() значение Magic формируется из str, нельзя через DataRead(), т.к. разные эксперты формируют его посвоему.     
      if (CSV[Exp].Name==ExpertName && CSV[Exp].Sym==Symbol() && CSV[Exp].Per==Period() && CSV[Exp].Risk>0) TheSameChart++; // признак того, что попалась хоть одна строка для текущего чарта
      for (chr=0; chr<50; chr++) CSV[Exp].Param[chr]=StrToDouble(FileReadString(InputFile));
      if (ReadLine>0) break; // на бэктесте (ReadLine>0) считываем только одну строку 
      RealParamRestore(CSV[Exp].Magic);// Print(CSV[Exp].Magic," ",Symbol(),Period()," RealParamRestore");
      CSV[Exp].Bar=Bar;
      CSV[Exp].RevBUY=RevBUY;//RevBUY; 
      CSV[Exp].RevSELL=RevSELL; 
      CSV[Exp].ExpMemory=ExpMemory; //Print("aMagic[",Exp,"]=",CSV[Exp].Magic,": HistDD=",HistDD," Risk=",Risk," RevBUY=",RevBUY," CSV[Exp].RevBUY=",CSV[Exp].RevBUY," ExpMemory=",ExpMemory);
      if (CSV[Exp].Risk>0) Exp++; // считаем количество участвующих в торговле экспертов
      else{
         Magic=CSV[Exp].Magic; 
         EmptyExperts();
      }  }  
   FileClose(InputFile); 
   if (Real){
      if (TheSameChart==0) MessageBox("Файл #.csv не содержит ни одной строки с параметрами для эксперта "+ExpertName+Symbol()+DoubleToStr(Period(),0));
      }
   else if (CSV[Exp].Name!=ExpertName || CSV[Exp].Sym!=Symbol() || CSV[Exp].Per!=Period()) return(-1); // на тесте проверяем 
   return(Exp); // кол-во экспертов в файле 
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ        

void EmptyExperts(){// удаление всех поз экспертов с риском=0.
   OrderCheck();
   if (BUY==0 && BUYSTOP==0 && BUYLIMIT==0 && SELL==0 && SELLSTOP==0 && SELLLIMIT==0) return;          
   BUY=0; BUYSTOP=0; BUYLIMIT=0; SELL=0; SELLSTOP=0; SELLLIMIT=0; 
   Report("Expert "+DoubleToStr(Magic,0)+" remove own orders, as its Risk=0");
   Modify(); // херим все ордера c этим Мэджиком 
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
  
bool Before(){ // запуск в начале функции Start // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real){
      if (BackTest<0) return(true); // флаг совпадения ТФ, эксперта, периода
      else return (false); // выполняем цикл программы Start
      }
   while (CSV[BackTest].Magic>0){    
      if (CSV[BackTest].Name!=ExpertName || CSV[BackTest].Sym!=Symbol() || CSV[BackTest].Per!=Period() || CSV[BackTest].Risk==0) {BackTest++; continue;} // имя+ТФ+период не совпадают. ищем дальше подходящую  для данного эксперта строку параметров
      else{
         DataRead(BackTest); // считываение данных эксперта из строки BackTest
         TimeCounter(); // Время входа и выхода  /////   
         Print(Magic,"/",SYMBOL, CSV[BackTest].Per,": Before(",BackTest,")"," Risk=",Risk," RevBUY=",RevBUY," RevSELL=",RevSELL," ExpMemory=",TimeToStr(ExpMemory,TIME_DATE | TIME_SECONDS)," HistDD=",HistDD," LastTestDD=",LastTestDD," Bar=",TimeToStr(Bar,TIME_DATE | TIME_MINUTES));
         BackTest++;
         return(false); // выполняем цикл программы Start
      }  }// окончание массива с параметрами, т.е. все параметры перебрали 
   BackTest=0; return(true); // выходим из Start  
   }  //  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void After(){// запуск в конце функции Start ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   CSV[BackTest-1].RevBUY=RevBUY;   // сохраняем индивидуальные 
   CSV[BackTest-1].RevSELL=RevSELL; // переменные эксперта
   CSV[BackTest-1].Bar=Time[0];
   GlobalVariableSet(DoubleToStr(Magic,0), 1);  // Флаг готовности данного эксперта - глобал с его именем Magic. Сигнализируюет об окончании проведения экспертами всех операций на данном графике (кроме выставления новых ордеров).
   GlobalVariableSet("LastWaitingExpert",Magic); // флаг последнего эксперта для ждущего в WaitingOthers(), сигнализирующий о том, что хватит ждать, если че, я крайний теперь.
   Print (Magic,"/",SYMBOL, CSV[BackTest-1].Per,": After(",BackTest-1,")"," Risk=",Risk," RevBUY=",RevBUY," RevSELL=",RevSELL," ExpMemory=",TimeToStr(ExpMemory,TIME_DATE | TIME_SECONDS)," HistDD=",HistDD," LastTestDD=",LastTestDD," Bar=",TimeToStr(Time[0],TIME_DATE | TIME_MINUTES)); 
   }//  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
      
void TheEnd(){// запуск после прохода всех экспертов ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; 
   GlobalOrdersSet();  // и расставляем ордера
   IndividualSaving(); // Сохранение глобальных переменных экспертов данного чарта в файл, доклад о их последних сделках
   ReportsToFile();  
   Sleep(60000); // минуточку
   if (GlobalVariableGet("MailTime")!=Hour()){ // чтобы слать мыло не чаще часа  
      GlobalVariableSet("MailTime",Hour()); // флаг отправки "мыла" 
      MatLabLog(); 
      MailSender();  Print("   "); Print("   "); Print("   "); Print("   "); Print("   "); 
   }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void TerminalHold(int WaitingTime){// ожидание освобождения торгового потока, чтобы в каждый момент времени терминал был занят только одним экспертом из всего портфеля
   if (!Real) return; // торговый поток уже занят
   if (GlobalVariableGet("CanTrade")==Magic) {  // если глобал свой,
      GlobalVariableSet("BusyTime",TimeLocal());// обновляем время установки глобала
      return;
      }
   Print(Magic,": Попытка захвата терминала");   
   while (GlobalVariableGet("CanTrade")!=Magic){ // присваиваем глобальной переменной значение Magic когда она станет равна 0.
      if (GlobalVariableGet("CanTrade")==0) {
         GlobalVariableSet("CanTrade",Magic);
         GlobalVariableSet("BusyTime",TimeLocal()); // фиксируем время установки глобала 
         continue;
         } 
      Sleep(5); // для разгрузки процессора     
      if (TimeLocal()-GlobalVariableGet("BusyTime")>WaitingTime){ // прождали, насильно захватываем торговый поток, т.к. что-то значит не в порядке
         Report("Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" work time exceed "+DoubleToStr((TimeLocal()-GlobalVariableGet("BusyTime")),0)+" seconds!, Set own flag: "+DoubleToStr(Magic,0)); // докладываем о занятом торговом потоке
         GlobalVariableSet("CanTrade",0); // сбрасываем Magic 
      }  }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   Print(Magic,": Терминал захвачен");
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
     
void TerminalFree(){ // освобождение торгового потока // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return; // может поток и не занимали
   if (GlobalVariableGet("CanTrade")==0) return;
   if (GlobalVariableGet("CanTrade")!=Magic) // кто-то уже занял без спроса
      Report("Expert "+DoubleToStr(GlobalVariableGet("CanTrade"),0)+" occupy terminal!"); 
   else GlobalVariableSet("CanTrade",0);  // освобождаем торговый поток
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ


void OnDeinit(const int reason){// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (!Real) return;
   EventKillTimer();
   switch (reason){ // вместо reason можно использовать UninitializeReason()
      //case 0: str="Эксперт самостоятельно завершил свою работу"; break;
      case 1: Report("Program "+ExpertName+" removed from chart"); break;
      case 2: Report("Program "+ExpertName+" recompile"); break;
      case 3: Report("Symbol or Period was CHANGED!"); break;
      case 4: Report("Chart closed!"); break;
      case 5: Report("Input Parameters Changed!"); break;
      case 6: Report("Another Account Activate!"); break; 
      case 9: Report("Terminal closed!"); break;   
      }
   if (IsTesting() || IsOptimization()) IndividualSaving(); // (только при тестировании реала) пропишем в конец файла историю совершенных сделок и кривую баланса 
   TerminalFree(); //освобождаем торговый поток, если прерывание программы произошло в момент ее выполнения
   }
    
double OnTester(){////  Ф О Р М И Р О В А Н И Е   Ф А Й Л А    О Т Ч Е Т А   /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   double   profit, GrossProfit, GrossLoss, iDD, MaxProfit, MaxWin[5], Years=day/260.0, MidWin, MidLoss, CustomMax,
            MinDepo=InitDeposit, LossesCnt, WinCnt, FullProfit, MO, SD, RF=555, iRF=555, PF=555, Sharp=555;         
   filename=ExpertName; 
   int Ord, i; 
   for(Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==Magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            Trades++; 
            profit=(OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE);///MarketInfo(Symbol(),MODE_TICKVALUE); //Print(Symbol(),": Pips profit=",profit," OrderProfit()=",OrderProfit()," OrderSwap()=",OrderSwap()," OrderCommission()=",OrderCommission()," TICKVALUE=",MarketInfo(Symbol(),MODE_TICKVALUE));
            FullProfit+=profit; // Значение депо после очередной сделки
            if (profit>MaxWin[0]){ // ищем пять самых крупных выигрышей, чтобы вычесть их потом из профита, т.к. уверены, что они не повторятся 
               for (i=4; i>0; i--) MaxWin[i]=MaxWin[i-1];
               MaxWin[0]=profit;  // т.е. резы тестера будут отличаться в худшую сторону
               } //Print("profit=",profit," FullProfit=",FullProfit);
            if (profit>0) {GrossProfit+=profit; WinCnt++;}
            if (profit<0) {GrossLoss-=profit;   LossesCnt++;}
            if (FullProfit>=MaxProfit) MaxProfit=FullProfit;// подсчет iRF - прибыль делим на среднюю просадку
            else{// нахождение в очередной просадке  
               //if (MaxProfit-FullProfit>DD) DD=MaxProfit-FullProfit;
               iDD+=MaxProfit-FullProfit; // площадь просадочной части эквити в период просадки (подсчет по сделкам)       
      }  }  }  }
   if (Trades<1 || day<1) return(0);
   if (WinCnt>0)    MidWin=GrossProfit/WinCnt;   else MidWin=0;
   if (LossesCnt>0) MidLoss=GrossLoss/LossesCnt; else MidLoss=0;
   LastTestDD=MaxEquity-Equity; // последняя незакрытая просадка на тесте
   for (i=1; i<5; i++) MaxWin[0]+=MaxWin[i]; // суммируем все члены массива в первый член
   FullProfit-=MaxWin[0]; //Print("MaxWin=",MaxWin[0]," FullProfit=",FullProfit);// вычитаем из полного профита пять максимальных винов 
   GrossProfit-=MaxWin[0];
   MaxProfit-=MaxWin[0];
   MO=FullProfit/Trades/(Spred/Point); // МатОжидание или Наклон Эквити       
   if (FullDD>0) iRF=MaxProfit/iDD*100; //  Своя формула для фактора восстановления 
   iDD=iDD/Trades*10;
   for(Ord=0; Ord<OrdersHistoryTotal(); Ord++){   // поиск MO, PF, iRF, kDD
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_HISTORY)==true && OrderMagicNumber()==Magic){ // выясним текущие бай/селл позы и гарантированную прибыль по ним, закрепленную стопами
         Order=OrderType();
         if (Order==OP_BUY || Order==OP_SELL){
            profit=(OrderProfit()+OrderSwap()+OrderCommission())/MarketInfo(Symbol(),MODE_TICKVALUE);
            SD+=MathAbs(MO-profit); // Суммарное отклонение
      }  }  } 
   SD/=Trades; // Отклонение результата сделки от MO
   if (GrossLoss>0)  PF=GrossProfit/GrossLoss;  
   if (DrawDown>0)   RF=MaxProfit/Years/DrawDown; // Фактор восстановления (% в год!)
   if (SD>0)  Sharp=MO*1000/SD; // Своя формула для к.Шарпа
   CustomMax=iRF; // Критерий оптимизации 
   if (IsOptimization()){ // Оптимизация / РеОптимизация
      if (BackTest==0) str="Opt"; else str="ReOpt";
      str=str+"_"+Symbol()+Period();
      if (PF<PF_ && PF_>0) return (CustomMax); //return(PF/PF_*CustomMax);  // если при оптимизации резы не катят, 
      if (RF<RF_ && RF_>0) return (CustomMax); //return(RF/RF_*CustomMax);  // не пишем их в файл отчета
      if (MO<MO_ && MO_>0) return (CustomMax); //return(MO/cMO*CustomMax);  // и пропорционально уменьшаем критерий оптимизации
      if (Trades/Years<Opt_Trades)  return(0);                                                     
      }
   else  {if (BackTest==0) str="Test"; else str="Back";} // тест / бэктест
//// формируем файл со статистикой текущей оптимизации    
   TesterFileName=str+"_"+ ExpertName+".csv"; 
   Date=Date+"-"+TimeToStr(LastDay,TIME_DATE); // период теста/оптимизации
   str=ExpertName+" "+Date+", Sprd="+DoubleToStr(Spred/Point,0)+", StpLev="+DoubleToStr(StopLevel/Point,0)+", Swaps="+DoubleToStr((MarketInfo(Symbol(),MODE_SWAPLONG)+MarketInfo(Symbol(),MODE_SWAPSHORT)),2);
   if (IsOptimization() && BackTest==0)  OptPeriod=Date; // фиксируем интервал оптимизации, чтобы потом отразить его на графике матлаба жирным
   str=str+", OPT-"+OptPeriod; 
   Str1="Pip/Y";     Prm1=DoubleToStr(FullProfit/Years,0); // Профит пункты / год 
   Str2="Trades/Y";  Prm2=DoubleToStr(Trades/Years,0); 
   Str3="RF=MaxProfit/Years/MaxDD";        Prm3=DoubleToStr(RF,2);    // Фактор восстановления = профит в месяц / просадку 
   Str4="PF";        Prm4=DoubleToStr(PF,2);    // Профит фактор
   Str5="DD/LastDD"; Prm5=" "+DoubleToStr(DrawDown,0)+"_"+DoubleToStr(LastTestDD,0);  // Максимальная историческая просадка / последняя незакрытая просадка
   Str6="iDD";       Prm6=DoubleToStr(iDD,0);   // Средняя площадь всех просадок
   Str7="MO/Spred";  Prm7=DoubleToStr(MO,2);    // Мат Ожидание
   Str8="SD";        Prm8=DoubleToStr(SD,0);    // Стандартное отклонение SD
   Str9="MO/SD";     Prm9=DoubleToStr(Sharp,0); // 
   Str10="iRF=MaxProfit/iDD";      Prm10=DoubleToStr(iRF,0);  // Модиф. фактора восстановления
   if (MidLoss>0){
      Str11="W/L*W%";  Prm11=" "+DoubleToStr(MidWin/MidLoss,2)+"*"+DoubleToStr((WinCnt/Trades)*100,0); // (Средний профит / Средний лосс ) * процент выигрышных сделок = ...Робастность(см. ниже)
      Str12="PF*RF";    Prm12=DoubleToStr(PF*RF,1); //    DoubleToStr(MidWin/MidLoss*(WinCnt/Trades)*100,0);  // Робастность =  (Средний профит / Средний лосс ) * процент выигрышных сделок либо  FullProfit*260*1000/day/MaxDD/Trades
      }
   else {Prm11=" 555"; Prm12=" 555";}   
   Str13="RISK=MidLoss/MaxDD";     Prm13=DoubleToStr(10*MidLoss/DrawDown,1);// выравнивает просадки в портфеле  // старый R I S K = 50*day/MaxDD/Trades
   TesterFileCreate(); // создание файла отчета со всеми характеристиками  //
   // допишем в конец каждой строки еженедельные балансы  
   for (i=1; i<=day; i++){ // // допишем в конец каждой строки еженедельные балансы  
      FileSeek (TesterFile,-2,SEEK_END); // перемещаемся в конец строки
      FileWrite(TesterFile, "",DailyConfirmation[i]/MarketInfo(Symbol(),MODE_TICKVALUE)/1000);    // пишем ежедневные Эквити из созданного массива
      }
   FileClose(TesterFile); //Print("day=",day," FullProfit=",FullProfit," AccountBalance()=",AccountBalance()," InitDeposit=",InitDeposit," Trades=",Trades);
   if (BackTest>0) MatLabLog();
   return (CustomMax); // возвращаем критерий оптимизации
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
    
void Statist(){ // расчет параметров DD, Trades, массив с резами сделок // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (Today!=DayOfYear()){ // начался новый день
      Today=DayOfYear(); //Print("DayMinEquity=",DayMinEquity," DayOfYear()=",DayOfYear());
      day++;
      DailyConfirmation[day]=(DayMinEquity-InitDeposit)*1000; // сперва умножим на 1000, а в OnTester() разделим. Это для более точного отображения на графике.    
      if (LastYear<Year()) {LastYear=Year(); day++; DailyConfirmation[day]=0; day++; DailyConfirmation[day]=DailyConfirmation[day-2];}
      DayMinEquity=AccountEquity();
      if (TimeCurrent()>LastDay) LastDay=TimeCurrent(); //Print(" LastDay=",ServerTime(LastDay)); // приходится искать максимум, т.к. в конце теста значение почему-то сбрасывается к старому
      }
   if (AccountEquity()<DayMinEquity) DayMinEquity=AccountEquity();
   // вычисление DD
   Equity=AccountEquity()/MarketInfo(Symbol(),MODE_TICKVALUE); 
   if (Equity>=MaxEquity) MaxEquity=Equity;  // Новый максимум депо
   else{ 
      FullDD+=MaxEquity-Equity;
      if (MaxEquity-Equity>DrawDown) DrawDown=MaxEquity-Equity;
   }  } // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void RealParamRestore(int fMagic){ // Восстановление на реале глобальных переменных // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   int StartWaiting=TimeLocal(),RestoreFile=-1; 
   while (AccountCurrency()==""){ // ждем связи, т.к. без нее не будет зачения AccountCurrency() и переменные последней сессии не восстановятся, поскольку имя файла будет неверным
      Sleep(100); 
      if (TimeLocal()-StartWaiting>60) {Report("Init(): No connection with Trade Server, wait a minute"); StartWaiting=TimeLocal();} 
      }  
   if (Real) str=AccountCurrency(); else str="Test";
   string RestoreFileName=str+"_"+DoubleToStr(fMagic,0)+".csv";
   while (RestoreFile<0){ // ждем, пока не откроется, т.к. без этих данных торговлю лучше не начинать
      Sleep(100); // для разгрузки процессора
      RestoreFile=FileOpen(RestoreFileName, FILE_READ | FILE_WRITE);  
      if (TimeLocal()-StartWaiting>30){
         Report("RealParamRestore(): ERROR! Can not open file "+RestoreFileName); 
         MessageBox("RealParamRestore(): Не могу открыть файл "+RestoreFileName);
         StartWaiting=TimeLocal();
      }  }
   if (FileReadString(RestoreFile)==""){ // файл пустой, заполним
      int i; for (i=0; i<15; i++) FileWrite(RestoreFile,"               ");// создаем несколько пустых строчек в начале файла для последующей записи в них глобальных переменных
      FileWrite(RestoreFile,"Bar","RevBUY","RevSELL","ExpMemory"); // ниже заголовок для глобальных переменных
      FileWrite(RestoreFile,"_______________________________"); // разделялка
      //FileWrite(RestoreFile,"E x p e r t     H i s t o r y :");
      Alert("Создаем файл ",RestoreFileName," для сохранения индивидуальных данных эксперта"); 
      }
   else{ // читаем из файла переменные
      FileSeek(RestoreFile,0,SEEK_SET);     // перемещаемся в начало   
      Bar=StrToDouble(FileReadString(RestoreFile));    
      RevBUY=StrToDouble(FileReadString(RestoreFile)); 
      RevSELL=StrToDouble(FileReadString(RestoreFile));
      ExpMemory=StrToDouble(FileReadString(RestoreFile));
      }
   FileClose(RestoreFile);
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void Report(string Missage){ // собираем все сообщения экспертов в одну кучу ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   if (Missage=="" || !Real) return;
   history=history+"\r"+DoubleToStr(Magic,0)+"/"+TimeToString(TimeCurrent(),TIME_MINUTES)+"  "+Missage+";"; // без разделителя ";" при записи в RestoreFileName (MailSender()) все сообщения лепятся в одну строку.
   Print(" R E P O R T  of ",Magic,": ",Missage);
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   
void ReportsToFile(){ // пишем собранные сообщения в один общий файл ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
   if (history=="") return; 
   string ReportFileName="Reports.csv"; int StartWaiting=TimeLocal(); 
   // ожидание освобождения общего фала со всеми репортами
   while (GlobalVariableGet("RepFile")!=Magic){ // 
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic);  
      Sleep(5); // для разгрузки процессора   
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         Report("ReportsToFile: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold ReportFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal(); // засекаем заново компьютерное время
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   if (GlobalVariableGet("RepFile")!=Magic) return; // так и не вышло захватить файл   
   // Файл освободился, пишем в него репорты всех экспертов текущего графика
   int ReportFile=FileOpen(ReportFileName, FILE_READ | FILE_WRITE);
   if (ReportFile<0) {MessageBox("ReportToFile: Не могу открыть файл отчета "+ReportFileName+" для записи проведенных на счете операций"); return;}
   FileSeek (ReportFile,0,SEEK_END);     // перемещаемся в конец
   FileWrite(ReportFile, history);
   FileClose(ReportFile);
   GlobalVariableSet("RepFile",0);
   history="";
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   
void MailSender(){ // отправляем мыло из файла с отчетами
   double MaxBal=0, MinBal=0, AccDD=0, AccCDD=0, AccPF=555, Plus=0, Minus=0, AccRF=555, AccPrf=0,  profit, LastHourProfit;
   int  Ord, Orders, LastOrderTime=0, RollPlus, RollMinus, Exp, ExpTotal=GlobalVariableGet("ExpertsTotal");
   if (GlobalVariableGet("LastOrderTime")==0){// если в первый раз LastOrderTime равно нулю
      LastOrderTime=iTime(NULL,60,1); // берем значение времени прошлого бара
      Print(Magic,": GlobalVariable(LastOrderTime)=0, set it to last bar time ", TimeToStr(LastOrderTime,TIME_DATE|TIME_MINUTES));
      GlobalVariableSet("LastOrderTime",LastOrderTime); // и сохраняем в глобал
      }
   for(Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
      if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true){ // история всех экспертов
         profit=OrderProfit()+OrderSwap()+OrderCommission(); // прибыль от выбранного ордера в валюте депозита 
         if (profit!=0){
            if (OrderOpenPrice()==0 && iTime(NULL,60,0)-OrderOpenTime()<3900){// Ордер без цены открытия, т.е. инвестиции. За прошлый час с небольшим запасом в 5мин = 3600с + 300с
               if (profit>0) RollPlus +=profit;   
               else RollMinus+=profit;
               }
            if (OrderOpenPrice()>0){ // ордер открыт экспертом
               Orders++;   // подсчет показателей работы эксперта
               AccPrf+=profit; 
               if (profit>0) Plus+=profit; else Minus-=profit;
               if (AccPrf>MaxBal) {MaxBal=AccPrf; MinBal=MaxBal;}
               if (AccPrf<MinBal) {MinBal=AccPrf; if (MaxBal-MinBal>AccDD) AccDD=MaxBal-MinBal;}   // DD
               if (OrderCloseTime()>GlobalVariableGet("LastOrderTime")){ // время закрытия ордера больше проверенного на прошлом баре (свежий значит)
                  if (OrderCloseTime()>LastOrderTime) LastOrderTime=OrderCloseTime(); // ищем самый поздний ордер, чтобы потом его сохранить
                  LastHourProfit+=profit; // суммируем всю прибыль за последний час
      }  }  }  }  }
   // Суммарный риск открытых позиций и отложенных ордеров
   string SYMtemp=SYMBOL; double OpenOrdMargNeed, LongRisk, ShortRisk, MargNeed, PerCent;
   for(Ord=0; Ord<OrdersTotal(); Ord++){// перебераем все открытые и отложенные ордера всех экспертов счета Ролловеры (OrderType=6) туда не пишем.
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue; // ролловеры не нужны
         SYMBOL=OrderSymbol(); // для ф.RiskChecker нужен символ ордера
         if (OrderType()<2) //маржа открытых поз
            OpenOrdMargNeed+=OrderLots()*MarketInfo(SYMBOL,MODE_MARGINREQUIRED); // кол-во маржи, необходимой для открытия лотов
         else
            MargNeed+=OrderLots()*MarketInfo(SYMBOL,MODE_MARGINREQUIRED);//маржа отложников
            if (OrderType()==0 || OrderType()==2 || OrderType()==4)
               LongRisk+=RiskChecker(OrderLots(),MathAbs(OrderOpenPrice()-OrderStopLoss()),SYMBOL);
            if (OrderType()==1 || OrderType()==3 || OrderType()==5)
               ShortRisk+=RiskChecker(OrderLots(),MathAbs(OrderOpenPrice()-OrderStopLoss()),SYMBOL);   
         }  }  // теперь массив ORD содержит список всех открытых, отложенных и предстоящих установке ордеров   
   SYMBOL=SYMtemp;
   if (LastOrderTime>0) GlobalVariableSet("LastOrderTime",LastOrderTime);// сохраняем время самого позднего ордера для текущего бара   
   AccCDD=MaxBal-AccPrf;
   if (AccDD>0) AccRF=AccPrf/AccDD;
   if (Minus>0) AccPF=Plus/Minus;
   string AccountParams="\r________AccountParams_________"+
   //"\rAccountProfit="+DoubleToStr(AccPrf,0)+" "+AccountCurrency()+
   //"\rRF="+DoubleToStr(AccRF,1)+
   //" PF="+DoubleToStr(AccPF,1)+
   //"\rMaxDD="+DoubleToStr(AccDD,0)+
   //" CurDD="+DoubleToStr(AccCDD,0)+
   "\rRisk: Long+Short = "+DoubleToStr(LongRisk,1)+"%+"+DoubleToStr(ShortRisk,1)+"%"+
   "\rMargin: Open+Depend="+DoubleToStr(OpenOrdMargNeed/AccountFreeMargin()*100,0)+"%+"+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"%"+
   "\rEquity="+DoubleToStr(AccountEquity(),0)+" FreeMargin="+DoubleToStr(AccountFreeMargin(),0);
   string CurPrf;
   if (AccountProfit()>0) CurPrf="+"+DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%"; // текущая незакрытая прибыль в процентах
   if (AccountProfit()<0) CurPrf=    DoubleToStr(AccountProfit()*100/AccountBalance(),1)+"%";
   CurPrf=AccountCurrency()+" "+DoubleToStr(AccountBalance(),0)+CurPrf+" ";
   string MailText=CurrentTime(AlpariTime(0))+"  *"+AccountCompany()+"*   ", MailWarning, RollList;
   if ((RollPlus-RollMinus)!=0){
      CurPrf=CurPrf+" Roll="+DoubleToStr(RollPlus+RollMinus,0);// были роловеры
      if (RollPlus>0)  RollList=DoubleToStr(RollPlus,0);
      if (RollMinus<0) RollList=RollList+DoubleToStr(RollMinus,0);
      MailText=MailText+"\n"+"Roll="+RollList+AccountCurrency(); 
      }
   int shift=iBarShift(NULL,0,Bar,FALSE)-iBarShift(NULL,0,Time[0],FALSE);   
   if (shift>1) // проверка пропущенных баров: разница с прошлым баром (в барах)   
      MailText=MailText+"\n Missed Bars="+DoubleToStr(shift-1,0)+"!,  LastOnLine="+TimeToStr(Bar,TIME_DATE|TIME_MINUTES)+",  CurTime="+TimeToStr(Time[0],TIME_MINUTES);   
   if (LastHourProfit>0){
      PerCent=LastHourProfit/(AccountBalance()-LastHourProfit)*100;
      CurPrf=CurPrf+" Win="+DoubleToStr(PerCent,2)+"%";
      }
   if (LastHourProfit<0){
      PerCent=LastHourProfit/(AccountBalance()+LastHourProfit)*100;
      CurPrf=CurPrf+" Loss="+DoubleToStr(PerCent,2)+"%"; //
      }
   string ReportFileName="Reports.csv", RestoreFileName, CellRead;  
   int ReportFile=-1, StartWaiting=TimeLocal(), Mag, RestoreFile;     
   while (GlobalVariableGet("RepFile")!=Magic){ //  
      if (GlobalVariableGet("RepFile")==0) GlobalVariableSet("RepFile",Magic); 
      Sleep(110); // для разгрузки процессора   
      if (TimeLocal()-StartWaiting>300){ // прождали 5мин, насильно открываем файл, т.к. что-то значит не в порядке
         Report("MailSender: Expert "+DoubleToStr(GlobalVariableGet("RepFile"),0)+"  hold ReportFile more then "+DoubleToStr((TimeLocal()-StartWaiting),0)+" seconds! Try to set own flag"); // докладываем о занятом торговом потоке
         StartWaiting=TimeLocal();  
         GlobalVariableSet("RepFile",0); // сбрасываем Magic, чтобы попытаться захватить
      }  }
   ReportFile=FileOpen(ReportFileName, FILE_READ);  
   if (ReportFile>0){
      while (!FileIsEnding(ReportFile)){ 
         CellRead=FileReadString(ReportFile); // считывание строки с мэджиком выбранного эксперта
         MailText=MailText+CellRead; // пихаем все в мыло 
         Mag=StrToInteger(StringSubstr(CellRead,1,7)); // считываем "Magic" (начиная с позиции 1 длиной 7 символов)
         CellRead=StringSubstr(CellRead,8,0); // выделяем текст (без мэджика)
         for (Exp=0; Exp<ExpTotal; Exp++){    
            if (Mag==CSV[Exp].Magic){ // 
               RestoreFileName=AccountCurrency()+"_"+DoubleToStr(Mag,0)+".csv";
               RestoreFile=FileOpen(RestoreFileName, FILE_READ|FILE_WRITE);  if (RestoreFile<0) {Report("MailSender(): Can't open file "+RestoreFileName+"! for reports saving"); break;}
               FileSeek (RestoreFile,0,SEEK_END); 
               FileWrite (RestoreFile, TimeToString(TimeCurrent(),TIME_DATE)+" "+CellRead); 
               FileClose(RestoreFile); 
         }  }  }
      if (StringFind(MailText,"!",0)>0) MailWarning="! ! !  "; // если были предупреждения, выносим их в заголовок мыла
      FileClose(ReportFile); 
      }
   SendMail(MailWarning+CurPrf, MailText+AccountParams+MarketInf()); 
   FileDelete(ReportFileName);
   GlobalVariableSet("RepFile",0);   
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

string MarketInf(){ // инфа о текущих рыночных характеристиках и профите // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string MarketInf, MarketOrders;
   double POINT, TakeProfit;
   int Ord;
   if (OrdersTotal()>0) MarketOrders="\r___________Orders:____________";
   for(Ord=0; Ord<OrdersTotal(); Ord++){// проверка отложенных ордеров 
      if (OrderSelect(Ord, SELECT_BY_POS, MODE_TRADES)==true){
         if (OrderType()==6) continue;
         SYMBOL=OrderSymbol(); // для ф.RiskChecker нужен символ ордера
         DIGITS=MarketInfo(SYMBOL,MODE_DIGITS); 
         POINT =MarketInfo(SYMBOL,MODE_POINT); 
         ASK   =MarketInfo(SYMBOL,MODE_ASK);
         BID   =MarketInfo(SYMBOL,MODE_BID);
         if (OrderTakeProfit()==0) TakeProfit=OrderOpenPrice(); else TakeProfit=OrderTakeProfit(); 
         if (OrderType()==OP_BUYSTOP)  {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderStopLoss()-OrderOpenPrice(),SYMBOL),1)+"%";}
         if (OrderType()==OP_SELLSTOP) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SS/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderOpenPrice()-OrderStopLoss(),SYMBOL),1)+"%";} 
         if (OrderType()==OP_BUYLIMIT) {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderStopLoss()-OrderOpenPrice(),SYMBOL),1)+"%";}
         if (OrderType()==OP_SELLLIMIT){MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SL/"  +DoubleToStr(OrderOpenPrice(),DIGITS-1)+        "/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderOpenPrice()-OrderStopLoss(),SYMBOL),1)+"%";}  
         if (OrderType()==OP_BUY)      {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": BUY/" +DoubleToStr((BID-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((OrderStopLoss()-OrderOpenPrice())/POINT/10,0)+"/"+DoubleToStr((TakeProfit-OrderOpenPrice())/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderStopLoss()-OrderOpenPrice(),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот    
         if (OrderType()==OP_SELL)     {MarketOrders =MarketOrders+"\n"+DoubleToStr(OrderMagicNumber(),0)+": SELL/"+DoubleToStr((OrderOpenPrice()-ASK)/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-OrderStopLoss())/POINT/10,0)+"/"+DoubleToStr((OrderOpenPrice()-TakeProfit)/POINT/10,0)+"x"+DoubleToStr(OrderLots(),2)+"="+DoubleToStr(RiskChecker(OrderLots(),OrderOpenPrice()-OrderStopLoss(),SYMBOL),1)+"%";}   // профит в пунктах / закрепленный стопом профит в пунктах х лот 
         }
      else if (OrderMagicNumber()==Magic) Report("MarketInf(): ERROR! in OrderSelect()="+DoubleToStr(GetLastError(),0));
      } 
   MarketInf= "\r____MarketInfo "+Symbol()+":____"+
              "\rSpread="+DoubleToStr(MarketInfo(Symbol(),MODE_SPREAD),0)+
              "\rSwL/SwS/SLev = "+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPLONG),1)+
              "/"+DoubleToStr(MarketInfo(Symbol(),MODE_SWAPSHORT),1)+
              "/"+DoubleToStr(MarketInfo(Symbol(),MODE_STOPLEVEL),1);           
   return (MarketOrders+MarketInf);
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  

string CurrentTime (int ServerSeconds){// Серверное время в виде  День.Месяц/Час:Минута // ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string ServTime;
   int time;
   time=TimeDay(ServerSeconds);     if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"."; // День.Месяц/Час:Минута
   time=TimeMonth(ServerSeconds);   if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+"/"; // 
   time=TimeHour(ServerSeconds);    if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0)+":"; // 
   time=TimeMinute(ServerSeconds);  if (time<10) ServTime=ServTime+"0"; ServTime=ServTime+DoubleToStr(time,0);     // 
   return (ServTime);
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ

void ValueCheck(){  // сравнение значений индикаторов Real/Test ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   string CheckFilename, ServerTime="-"+TimeToStr(AlpariTime(0),TIME_DATE|TIME_SECONDS); // без дефиса эксель переворачивает дату и все херится
   string sB, sBS, sBP, sS, sSS, sSP;
   // int rTime=AlpariTime(0);
   //OrderCheck(); // проверим состояние поз
   StopLevel=MarketInfo(SYMBOL,MODE_STOPLEVEL)*Point;
   Spred=MarketInfo(SYMBOL,MODE_SPREAD)   *Point;
   if (SetBUY>0){ // момент открытия позы в лонг
      sB ="set"+DoubleToStr(SetBUY,Digits); 
      sBS="set"+DoubleToStr(SetSTOP_BUY,Digits); 
      sBP="set"+DoubleToStr(SetPROFIT_BUY,Digits);} 
   else { // поза в лонг уже открыта
      sB =DoubleToStr(BUY+BUYSTOP+BUYLIMIT,Digits); 
      sBS=DoubleToStr(STOP_BUY,Digits); 
      sBP=DoubleToStr(PROFIT_BUY,Digits);}
   if (SetSELL>0){// момент открытия позы в шорт
      sS ="set"+DoubleToStr(SetSELL,Digits); 
      sSS="set"+DoubleToStr(SetSTOP_SELL,Digits); 
      sSP="set"+DoubleToStr(SetPROFIT_SELL,Digits);} 
   else { // поза в шорт уже открыта
      sS =DoubleToStr(SELL+SELLSTOP+SELLLIMIT,Digits); 
      sSS=DoubleToStr(STOP_SELL,Digits); 
      sSP=DoubleToStr(PROFIT_SELL,Digits);}
   CheckFilename="Real_"+DoubleToStr(Magic,0)+"_"+ExpertName+".csv";
   int CheckFile=FileOpen(CheckFilename, FILE_READ|FILE_WRITE); 
   if (CheckFile<0) {Report("ValueCheck(): Can not open file "+CheckFilename+"! for variables save"); return;}
   if (FileReadString(CheckFile)=="")// пропишем заголовки столбцов   
      FileWrite (CheckFile,"ServerTime", "Ask/Bid" ,                  "O/H/L/C[1]"             ,"StpLev" ,   "Spred/SYM"  , "atr/ATR" , "H/L" ,"Buy","StpBuy","PrfBuy","Sell","StpSel","PrfSel","Tr0","Tr1","Tr2","Tr3","In0","In1","In2","In3","Out0","Out1","Out2","Out3"); // сохраняем переменные в файл
   FileSeek(CheckFile,0,SEEK_END);     // перемещаемся в конец
   FileWrite    (CheckFile, ServerTime ,Ask+"/"+Bid,Open[1]+"/"+High[1]+"/"+Low[1]+"/"+Close[1],StopLevel,Spred+"/"+SYMBOL,atr+"/"+ATR,H+"/"+L, sB  ,  sBS   ,  sBP   ,  sS  ,  sSS   ,  sSP   ,PS[0],PS[1],PS[2],PS[3],PS[4],PS[5],PS[6],PS[7], PS[8], PS[9],PS[10],PS[11]);
   FileClose(CheckFile); 
   ArrayInitialize (PS,0); // обнулим значения массива перед следующим запуском  
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ
   
void IndividualSaving(){// Сохранение глобальных переменных в файл, доклад о последних сделках  ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ  
   double RiskTemp=Risk; string SymbolTemp=SYMBOL;
   int  Ord, Orders, OrdMemory, Exp=0, MagicTemp=Magic, ExpTotal=GlobalVariableGet("ExpertsTotal"); // Print(Magic,": IndividualSaving(), сохраняем RevBUY и RevSELL всех экспертов с графика ",Symbol(),Period());
   for (Exp=0; Exp<ExpTotal; Exp++){    
      if (CSV[Exp].Name==ExpertName && CSV[Exp].Sym==Symbol() && CSV[Exp].Per==Period() && CSV[Exp].Risk>0){ // имя+ТФ+период  совпадают, выбали эксперта с того же чарта
         Magic=CSV[Exp].Magic; HistDD=CSV[Exp].HistDD; LastTestDD=CSV[Exp].LastTestDD; TestEndTime=CSV[Exp].TestEndTime; Risk=CSV[Exp].Risk;
         double SMaxBal, SDD, SCurDD, PF=555, SPF=555, SRF=555, Plus, Minus, SPlus, SMinus, profit, SProfit, ExpPrf, SExpPrf, CheckRisk;
         for (Ord=0; Ord<OrdersHistoryTotal(); Ord++){// перебераем историю сделок эксперта
            if (OrderSelect(Ord,SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()==Magic && OrderCloseTime()>0){
               profit=OrderProfit()+OrderSwap()+OrderCommission(); // прибыль от выбранного ордера в валюте депозита 
               if (profit!=0){ // попался закрытый ордер (не Открытый и не Отложенный) 
                  Orders++;
                  SProfit=profit;
                  if (OrderLots()>0) profit=profit/OrderLots()/MarketInfo(Symbol(),MODE_TICKVALUE)*0.1;
                  SExpPrf+=SProfit;
                  ExpPrf +=profit; 
                  if ( profit>0)  Plus+= profit; else  Minus-= profit;
                  if (SProfit>0) SPlus+=SProfit; else SMinus-=SProfit;
                  if (SExpPrf>SMaxBal) SMaxBal=SExpPrf;
                  else if (SMaxBal-SExpPrf>SDD) SDD=SMaxBal-SExpPrf;
                  OrdMemory=OrderCloseTime();  
            }  }  }
         if (OrdMemory!=CSV[Exp].ExpMemory){// если время последней сделки обновилось,
            CSV[Exp].ExpMemory=OrdMemory;
            SCurDD=SMaxBal-SExpPrf; // текущая просадка в $
            if (SDD>0) SRF=SMaxBal/SDD;  // фактор восстановления
            double Stop=100*Point; // возьмем любой стоп для расчета риска
            SYMBOL=Symbol();
            Lot = MoneyManagement(Stop);   // расчет пробного лота для стопа в 100п
            CheckRisk=RiskChecker(Lot,Stop,SYMBOL); //расчет текущего риска в связи с просадкой
            string CurrentRisk; // запишем, на сколько истинный риск (с учетом просадки) отличается от заданного в настройках 
            if (CheckRisk>Risk) CurrentRisk="+"+DoubleToStr(CheckRisk-Risk,1);
            if (CheckRisk<Risk) CurrentRisk=    DoubleToStr(CheckRisk-Risk,1);
            if ( Minus>0)  PF= Plus/ Minus;
            if (SMinus>0) SPF=SPlus/SMinus;
            string ExpParams=ExpertName+"/"+SYMBOL+DoubleToStr(Period(),0);
            if (SProfit>0) ExpParams=ExpParams+" WIN="; else ExpParams=ExpParams+" LOSS="; // запомним значение баланса на случай, если этот лось для данного эксперта - начало ДД (пригодится потом в ММ)
            ExpParams=ExpParams+DoubleToStr(MathAbs(profit),0)+"("+DoubleToStr(MathAbs(SProfit),0)+AccountCurrency()+")"+
               "\n Prf="+DoubleToStr(ExpPrf,0)+" ("+DoubleToStr(SExpPrf,0)+AccountCurrency()+")"+" Risk="+DoubleToStr(Risk,1)+"x"+DoubleToStr(CheckRisk/Risk,2)+
               "\n RF="+DoubleToStr(SRF,1)+" PF="+DoubleToStr(PF,1)+"("+DoubleToStr(SPF,1)+"$)"+" Trades="+ DoubleToStr(Orders,0)+
               "\n HistDD/CurDD="+DoubleToStr(HistDD,0)+"/"+DoubleToStr(CurrentDD(),0)+"("+DoubleToStr(SCurDD,0)+AccountCurrency()+")"+
               "\n LastTestDD="+DoubleToStr(LastTestDD,0)+" TestEndTime="+TimeToStr(TestEndTime,TIME_DATE)+" TickVal="+DoubleToStr(MarketInfo(SYMBOL,MODE_TICKVALUE),2);    // Статистика проведенных экспером торгов
            Report(ExpParams); // шлем миссагу
            }
         // Сохранение глобальных переменных на случай выключения программы   
         string RestoreFileName=AccountCurrency()+"_"+DoubleToStr(Magic,0)+".csv";
         int RestoreFile=FileOpen(RestoreFileName, FILE_READ|FILE_WRITE);  
         if (RestoreFile<0) {Report("IndividualSaving(): Can't open file "+RestoreFileName+"! for parameters saving"); return;}
         FileWrite (RestoreFile, CSV[Exp].Bar, CSV[Exp].RevBUY, CSV[Exp].RevSELL, CSV[Exp].ExpMemory); // сохраняем глобальные переменные в файл
         FileClose(RestoreFile); 
      }  }
   Magic=MagicTemp;  SYMBOL=SymbolTemp;    
   }// ЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖЖ   

#define  EXPERTS  100    // максимальное кол-во проверяемых экспертов
#define  ORDERS   400   // максимальное кол-во сделок одного эксперта за последние два года
void MatLabLog(){// Сохранение истории сделок в файл 
   uchar Exp;
   ushort order;
   short    Deals[EXPERTS, ORDERS]; 
   datetime OrdTime[EXPERTS, ORDERS];
   int  magic[EXPERTS];
   float TickVal[EXPERTS];
   short profit=0;
   string FileName; 
   ArrayInitialize(OrdTime,0);
   ArrayInitialize(Deals,0);
   ArrayInitialize(magic,0);
   ArrayInitialize(TickVal,0);
   if (Real) {FileName="MatLab"+AccountCurrency()+".csv"; FileDelete(FileName);} // каждый час создаем новый файл
   else      {FileName="MatLabTest.csv";}//  
   int File=FileOpen(FileName, FILE_READ | FILE_WRITE); 
   if (File<0) {Alert("MatLabLog(): Can not open file "+ FileName+"! for history saving"); return;}
   FileWrite(File, "Magic","TickVal","Risk","Deal/Time..."); // прописываем в первую строку названия столбцов
   for(int i=0; i<OrdersHistoryTotal(); i++){// перебераем историю сделок эксперта
      if (OrderSelect(i, SELECT_BY_POS,MODE_HISTORY)==true && OrderMagicNumber()>0 && OrderCloseTime()>0){
         if (Time[0]-OrderCloseTime()>34560000) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.
         if (OrderProfit()!=0){ // попался закрытый ордер (не Открытый и не Отложенный) 
            Exp=0;
            while (magic[Exp]!=OrderMagicNumber()){
               Exp++; if (Exp>=EXPERTS) {Alert("WARNING!!! Experts>",EXPERTS, " Can't create MatLabLog File"); FileClose(File); return;}
               if (magic[Exp]==0){ 
                  TickVal[Exp]=(float)MarketInfo(OrderSymbol(),MODE_TICKVALUE);
                  magic[Exp]=OrderMagicNumber(); // ищем номер ячейки "Exp" с заданным magic
               }  }
            for (order=1; order<ORDERS; order++){ // формируем массив [Exp][DEAL], т.е. ищем конец массива c нулевым значением
               if (Deals[Exp][order]==0){
                  Deals[Exp][order]=short((OrderProfit()+OrderSwap()+OrderCommission())*100/OrderLots()/MarketInfo(OrderSymbol(),MODE_TICKVALUE)*0.1); // прибыль в пунктах 
                  OrdTime[Exp][order]=OrderCloseTime(); //Alert("magic[",Exp,"]=",magic[Exp]," Deals=",Deals[Exp][order]);
                  break;// и записываем туда новый Profit
      }  }  }  }  }// Print("ExpertsTotal=",Exp,", Deals=",Deals);
   
   Exp=1; // запишем массивы начиная с первых элементов до конца (до нулевого значения) 
   while (magic[Exp]>0){
      order=1; // Alert("magic[",Exp,"]=",magic[Exp]);
      FileSeek (File,0,SEEK_END); // перемещаемся в конец файла MatLabTest.csv
      FileWrite(File, DoubleToStr(magic[Exp],0)+";"+DoubleToStr(TickVal[Exp],5)+";"+"0.1"); // прописываем в первую ячейку magic,
      while (Deals[Exp][order]!=0){ //
         FileSeek (File,-2,SEEK_END); // потом дописываем
         FileWrite(File,  ""    , DoubleToStr(Deals[Exp][order],0)+"/"+TimeToStr(OrdTime[Exp][order],TIME_DATE|TIME_MINUTES));    // ежедневные профиты/время сделки из созданного массива
         order++;
         }
      Exp++;     
      }
   FileClose(File); 
   }  
/*
2014:____________________________________________________________________________________________________________________________________________________________________________
	04.28
	TheEnd()
вставлено InputFileRead(0); // каждый бар будет считывание csv файла, если вдруг csv-шник сменился 
   	IndividualSaving()
запись в файл "RestoreFile" логов операций из history как раньше
	Ye$$, $kc
заменил все i,j,k локальными переменными

	05.07
	TimeCounter()
запуск таймера EventSetTimer на стоках в конце сессии, и выключение в начале
	WaitingOthers()
GlobMin=MathFloor(Time[0]/60/Period())*Period();  // кол-во минут с 1970, кратное периоду данного Эксперта 
PerCheck=GlobMin-MathFloor(GlobMin/CSV[Exp].Per)*CSV[Exp].Per;
if (CSV[Exp].Per<=0) continue; // защита от деления на 0
	GlobalOrdersSet()
Закомментировал репорты
//Report("For new orders open "+DoubleToStr(MargNeed/AccountFreeMargin()*100,0)+"% Margin need, decrease Lots in "+DoubleToStr(LotDecrease,2));

	05.19
Изменил при инициализации массивов  aPer[100], aHistDD[100], aLastTestDD[100], aMagic[100], aTestEndTime[100], aExpMemory[100], aExpParams[100][50], aBar[100],...
кол-во члено с 50 до 100, т.к. на  демо счете в связи с большим кол-вом тестируемых экспертов 50 не хватало.

   05.29
service.mqh
Statist(): Добавили умножение/деление на 1000 массива резов DailyConfirmation[day] для более точного отображения на графике. 
 DailyConfirmation[day]=(DayMinEquity-InitDeposit)*1000; // сперва умножим на 1000, а в OnTester() разделим. Это для более точного отображения на графике.    

   06.22
OrdersProcessing():
Вместо Point() в Modify() и ErrorCheck() поставил MarketInfo(SYMBOL,MODE_POINT), т.к. в GlobalOrdersSet() эти функции вызывались с чужими Point().  
TesterFileCreate():
Вмето SymPer используется SYMBOL+Per по той же причине. 

   08.29
OrdersProcessing():
Чтобы не трогал ручные ордера и за одно корректировал отложникам риск добавил в цикл перебора всех ордеров: 
if (OrdMagic[Ord]==0){  // попался ручной ордер
    OrdRisk[Ord]   =1;   // ставим риск
    MaxDD[Ord]     =10000000; // чтобы при ручной торговле риск не корректировался в зависимости от исторической просадки (ее просто нет), возьмем ее заведомо больше текущей.     
    LastDD[Ord]    =0;  // чтобы CurrentDD() вернул 0, опять же для того, чтобы не корректирровать риск
    LastDDTime[Ord]=2100000000; // Время TestEndTime для CurrentDD() возьмем заведомо большое (насколько позволяет компилятор), чтобы сразу выкинуло из цикла и не считалась CurDD
    } 
2015:________________________________________________________________________________________________________________________________________________________________________________________________________________

   04.11
   OnInit(): 
Для повышения агрессивности одного из счетов добавлен параметр "Aggress". Т.е. при загрузке эксперта проверяем  параметр Risk на возможность повышения агрессивности
if (Risk==0) Aggress=1; // Если в настройках выставить риск>0, то риск, считанный из #.csv будет увеличен в данное количество раз. 
else {Aggress=Risk; MaxRisk*=Risk;}    
   GlobalOrdersSet():
Risk=OrdRisk[Ord]*Aggress; // умножаем на агрессивность торговли, определяемую при загрузке эксперта: if (Risk>0)  Aggress=Risk; else  Aggress=1;

   05.11
   OnTester() 
статистическая величина iRF опять притерпела изменения
iRF=MaxProfit/iDD*100; // подкорректирована формула iRF. Вместо FullDD поставлена iDD
   MatLabLog()
добавлено ограничение для записи статистики только последнего года, т.к. массива размером 1000 порой не хватает, чтобы сохранить все сделки. А все и не нужны. 
if (Time[0]-OrderCloseTime()>34560000) continue; // Пропускаем все ордера старше двух лет, чтобы не переполнять масссив. Для гарфического анализа они не пригодятся.
   ErrorCheck()
ошибка 134 "Not enough money" игнорируется, поскольку постоянно естественным образом появляется в тестере
case 134:  repeat=false;   str=str+"Not enough money";  return(false); 







*/