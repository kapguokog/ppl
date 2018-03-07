unit uPPLMonitor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, System.Threading,
  Vcl.ExtCtrls;

type
  TfmPPLMonitor = class(TForm)
    info: TMemo;
    bbRunTask: TButton;
    bbCreateTask: TButton;
    bbStartTask: TButton;
    rgWaitMode: TRadioGroup;
    bbAnonymThread: TButton;
    bbCreateCanceled: TButton;
    bbCancelTask: TButton;
    ckException: TCheckBox;
    bbParallel: TButton;
    bbParallelCancel: TButton;
    btnCreateFutures: TButton;
    bbStartFuture: TButton;
    procedure bbRunTaskClick(Sender: TObject);
    procedure bbCreateTaskClick(Sender: TObject);
    procedure bbStartTaskClick(Sender: TObject);
    procedure bbAnonymThreadClick(Sender: TObject);
    procedure bbCreateCanceledClick(Sender: TObject);
    procedure bbCancelTaskClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure bbParallelClick(Sender: TObject);
    procedure bbParallelCancelClick(Sender: TObject);
    procedure btnCreateFuturesClick(Sender: TObject);
    procedure bbStartFutureClick(Sender: TObject);
  private
    tasks : array[0..2] of ITask;
    TaskAny, TaskAll, TaskTwo : ITask;
    TaskCancel : ITask;
    TaskLoop : ITask;
    futures : array[0..2] of ITask;
    f1: IFuture<integer>;
    f2: IFuture<integer>;
    f3: IFuture<integer>;
  public
    function  GetProc: TProc<integer>;
    procedure CallProc(const ArrProc: array of TFunc<TProc<Integer>>);
  end;

  ETaskException = class(Exception);

var fmPPLMonitor: TfmPPLMonitor;

implementation

uses uSlowCode, System.Diagnostics, System.SyncObjs;

{$R *.dfm}

{$REGION 'ITask'}
procedure TfmPPLMonitor.bbRunTaskClick(Sender: TObject);
begin
  TTask.Run(procedure
  var Total          : integer;
      StopWatch      : TStopWatch;                                              // секундомер
      ElapsedSeconds : double;
  begin
    try
      StopWatch := TStopWatch.StartNew;
      if ckException.Checked then raise ETaskException.Create('Тестовое исключение');
      Total := PrimesBelow(200000);
      ElapsedSeconds := StopWatch.Elapsed.TotalSeconds;
      TThread.Synchronize(TThread.Current,
                          procedure
                          begin
                            info.Clear;
                            info.Lines.Add(Format('Найдено %d простых чисел до 200 000', [Total]));
                            info.Lines.Add(Format('На вычисления потребовалось %:2f', [ElapsedSeconds]));
                          end);
    except
      on E: ETaskException do TThread.Synchronize(TThread.Current,              // на Queue не отработал текст сообщения
                                                  procedure
                                                  begin
                                                    info.Clear;
                                                    info.Lines.Add(E.ClassName + ' :: ' + E.Message);
                                                  end);
    end;
  end);
end;
  
procedure TfmPPLMonitor.bbCreateTaskClick(Sender: TObject);
begin
  tasks[0] := TTask.Create(procedure
                           begin
                             PrimesBelow(200000);
                             TThread.Synchronize(TThread.Current,
                                                 procedure
                                                 begin
                                                   if not Application.Terminated then
                                                   info.Lines.Add('завершена первая задача');
                                                 end);
                           end);
  tasks[1] := TTask.Create(procedure
                           begin
                             PrimesBelow(250000);
                             TThread.Synchronize(TThread.Current,
                                                 procedure
                                                 begin
                                                   if not Application.Terminated then
                                                   info.Lines.Add('завершена вторая задача');
                                                 end);
                           end);
  tasks[2] := TTask.Create(procedure
                           begin
                             PrimesBelow(300000);
                             TThread.Synchronize(TThread.Current,
                                                 procedure
                                                 begin
                                                   if not Application.Terminated then
                                                   info.Lines.Add('завершена третья задача');
                                                 end);
                           end);
  TaskAll := TTask.Create(procedure
                          begin
                            TTask.WaitForAll(tasks);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('завершены все');
                                                end);
                          end);
  TaskAny := TTask.Create(procedure
                          begin
                            TTask.WaitForAny(tasks);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('завершена какая-то одна задача');
                                                end);
                          end);
  TaskTwo := TTask.Create(procedure
                          begin
                            TTask.WaitForAll([tasks[0],tasks[1]]);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('завершены 2/3 задач');
                                                end);
                          end);
  info.Lines.Clear;
  ShowMessage('Задачи созданы');
end;

procedure TfmPPLMonitor.bbStartTaskClick(Sender: TObject);
begin
  if Assigned(tasks[0]) and (tasks[0].Status = TTaskStatus.Created) then tasks[0].Start;
  if Assigned(tasks[1]) and (tasks[1].Status = TTaskStatus.Created) then tasks[1].Start;
  if Assigned(tasks[2]) and (tasks[2].Status = TTaskStatus.Created) then tasks[2].Start;
  case rgWaitMode.ItemIndex of
    0: if Assigned(TaskAll) then TaskAll.Start;
    1: if Assigned(TaskAny) then TaskAny.Start;
    2: if Assigned(TaskTwo) then TaskTwo.Start;
  end;
end;  

procedure TfmPPLMonitor.bbCreateCanceledClick(Sender: TObject);
var i : integer;
begin
  i := 0;
  TaskCancel := TTask.Create(procedure
                             begin
                               repeat
                                 TThread.Queue(TThread.Current,
                                               procedure
                                               begin
                                                 if not Application.Terminated then
                                                 info.Lines[0] := i.ToString;
                                               end);
                                 sleep(1000);
                                 TInterlocked.Exchange(i,random(100));
                               until TTask.CurrentTask.Status = TTaskStatus.Canceled;
                             end);
  info.Lines.Add('отсчет пошел');
  TaskCancel.Start;
end;

procedure TfmPPLMonitor.bbCancelTaskClick(Sender: TObject);
begin
   if Assigned(TaskCancel) then TaskCancel.Cancel;
end;
{$ENDREGION}

{$REGION 'Анонимные методы и анонимный поток'}
function TfmPPLMonitor.GetProc: TProc<integer>;
begin
  result := procedure(value: integer)
            begin
              TThread.Queue(TThread.Current,                                    // аналогичен TThread.Synchronize, только работает асинхронно
                            procedure
                            begin
                              if not Application.Terminated then
                              info.Lines.Add(string.Join(': ', ['Процессоров в системе', value.ToString]));
                            end);
            end;
end;
  
procedure TfmPPLMonitor.CallProc(const ArrProc: array of TFunc<TProc<Integer>>);
begin
  ArrProc[0]()(TThread.ProcessorCount);                                         // количество виртуальных ядер процессора
  ArrProc[1]()(random(1000));  
end;
  
procedure TfmPPLMonitor.bbAnonymThreadClick(Sender: TObject);
begin
  TThread.CreateAnonymousThread(procedure                                       // создает простую задачу, встроенную в анонимный метод для запуска в потоке
  begin
    while not Application.Terminated do
    begin
      CallProc([GetProc,GetProc]);
      sleep(1000)
    end;    
  end).Start;
end;  
{$ENDREGION}

{$REGION 'IFuture'}
procedure TfmPPLMonitor.btnCreateFuturesClick(Sender: TObject);
begin
  info.Clear;
  f1 := TTask.Future<integer>(function: integer
                              begin
                                result := PrimesBelow(200000);
                              end);
  futures[0] := f1;
  info.Lines.Add('задача №1 стартовала');
  
  f2 := TTask.Future<integer>(function: integer
                              begin
                                result := PrimesBelow(250000);
                              end);
  futures[1] := f2;
  info.Lines.Add('задача №2 стартовала');
  
  f3 := TTask.Future<integer>(function: integer
                              begin
                                result := PrimesBelow(300000);
                              end);
  futures[2] := f3;
  info.Lines.Add('задача №3 стартовала');
end;
  
procedure TfmPPLMonitor.bbStartFutureClick(Sender: TObject);
begin
  {раскомментить один из вариантов}
  {ожидание всех задач}
  TFuture<integer>.WaitForAll(futures);
  info.Lines.Add('Ожидание завершено. Получены все результаты');
  info.Lines.Add('Первый результат ' + f1.GetValue.ToString);
  info.Lines.Add('Второй результат ' + f2.GetValue.ToString);
  info.Lines.Add('Третий результат ' + f3.GetValue.ToString);
  {ожидание самой долгой из задач}
//  TFuture<integer>.WaitForAny([f3]);
//  info.Lines.Add('Первый результат ' + f1.GetValue.ToString);
//  info.Lines.Add('Ожидание завершено. Получен первый результат');
//  info.Lines.Add('Второй результат ' + f2.GetValue.ToString);
//  info.Lines.Add('Третий результат ' + f3.GetValue.ToString);
end;



{$ENDREGION}

procedure TfmPPLMonitor.bbParallelClick(Sender: TObject);
var res: TParallel.TLoopResult;
begin
  info.Clear;
  TaskLoop := TTask.Run(procedure
                        begin
                          res := TParallel.For(1, 30,
                                               procedure(AIndex: integer; LoopState: TParallel.TLoopState)
                                               begin
                                                 {----- Проверки прерывания -----}
                                                 if (TaskLoop.Status = TTaskStatus.Canceled) and (not LoopState.Stopped) then LoopState.Stop;
                                                 if LoopState.Stopped then
                                                 begin
                                                   TThread.Queue(TThread.Current,
                                                                 procedure
                                                                 begin
                                                                   info.Lines.Add(string.Join(' - ', [AIndex.ToString, 'завершена досрочно']));
                                                                 end);
                                                   exit;
                                                 end;
                                                 {----- Тело цикла -----}
                                                 PrimesBelow(100000);
                                                 TThread.Queue(TThread.Current,
                                                               procedure
                                                               begin
                                                                 info.Lines.Add(AIndex.ToString);
                                                               end);
                                               end);
                          if res.Completed
                             then info.Lines.Add('Параллельная обработка завершена')
                             else info.Lines.Add('Параллельная обработка прервана');
                        end);
end;

procedure TfmPPLMonitor.bbParallelCancelClick(Sender: TObject);
begin
  if Assigned(TaskLoop) then TaskLoop.Cancel;
end;

procedure TfmPPLMonitor.FormCreate(Sender: TObject);
begin
   if Assigned(TaskCancel) and (TaskCancel.Status = TTaskStatus.Running) then TaskCancel.Cancel;
end;

end.
