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
      StopWatch      : TStopWatch;                                              // ����������
      ElapsedSeconds : double;
  begin
    try
      StopWatch := TStopWatch.StartNew;
      if ckException.Checked then raise ETaskException.Create('�������� ����������');
      Total := PrimesBelow(200000);
      ElapsedSeconds := StopWatch.Elapsed.TotalSeconds;
      TThread.Synchronize(TThread.Current,
                          procedure
                          begin
                            info.Clear;
                            info.Lines.Add(Format('������� %d ������� ����� �� 200 000', [Total]));
                            info.Lines.Add(Format('�� ���������� ������������� %:2f', [ElapsedSeconds]));
                          end);
    except
      on E: ETaskException do TThread.Synchronize(TThread.Current,              // �� Queue �� ��������� ����� ���������
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
                                                   info.Lines.Add('��������� ������ ������');
                                                 end);
                           end);
  tasks[1] := TTask.Create(procedure
                           begin
                             PrimesBelow(250000);
                             TThread.Synchronize(TThread.Current,
                                                 procedure
                                                 begin
                                                   if not Application.Terminated then
                                                   info.Lines.Add('��������� ������ ������');
                                                 end);
                           end);
  tasks[2] := TTask.Create(procedure
                           begin
                             PrimesBelow(300000);
                             TThread.Synchronize(TThread.Current,
                                                 procedure
                                                 begin
                                                   if not Application.Terminated then
                                                   info.Lines.Add('��������� ������ ������');
                                                 end);
                           end);
  TaskAll := TTask.Create(procedure
                          begin
                            TTask.WaitForAll(tasks);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('��������� ���');
                                                end);
                          end);
  TaskAny := TTask.Create(procedure
                          begin
                            TTask.WaitForAny(tasks);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('��������� �����-�� ���� ������');
                                                end);
                          end);
  TaskTwo := TTask.Create(procedure
                          begin
                            TTask.WaitForAll([tasks[0],tasks[1]]);
                            TThread.Synchronize(TThread.Current,
                                                procedure
                                                begin
                                                  if not Application.Terminated then
                                                  info.Lines.Add('��������� 2/3 �����');
                                                end);
                          end);
  info.Lines.Clear;
  ShowMessage('������ �������');
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
  info.Lines.Add('������ �����');
  TaskCancel.Start;
end;

procedure TfmPPLMonitor.bbCancelTaskClick(Sender: TObject);
begin
   if Assigned(TaskCancel) then TaskCancel.Cancel;
end;
{$ENDREGION}

{$REGION '��������� ������ � ��������� �����'}
function TfmPPLMonitor.GetProc: TProc<integer>;
begin
  result := procedure(value: integer)
            begin
              TThread.Queue(TThread.Current,                                    // ���������� TThread.Synchronize, ������ �������� ����������
                            procedure
                            begin
                              if not Application.Terminated then
                              info.Lines.Add(string.Join(': ', ['����������� � �������', value.ToString]));
                            end);
            end;
end;
  
procedure TfmPPLMonitor.CallProc(const ArrProc: array of TFunc<TProc<Integer>>);
begin
  ArrProc[0]()(TThread.ProcessorCount);                                         // ���������� ����������� ���� ����������
  ArrProc[1]()(random(1000));  
end;
  
procedure TfmPPLMonitor.bbAnonymThreadClick(Sender: TObject);
begin
  TThread.CreateAnonymousThread(procedure                                       // ������� ������� ������, ���������� � ��������� ����� ��� ������� � ������
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
  info.Lines.Add('������ �1 ����������');
  
  f2 := TTask.Future<integer>(function: integer
                              begin
                                result := PrimesBelow(250000);
                              end);
  futures[1] := f2;
  info.Lines.Add('������ �2 ����������');
  
  f3 := TTask.Future<integer>(function: integer
                              begin
                                result := PrimesBelow(300000);
                              end);
  futures[2] := f3;
  info.Lines.Add('������ �3 ����������');
end;
  
procedure TfmPPLMonitor.bbStartFutureClick(Sender: TObject);
begin
  {������������� ���� �� ���������}
  {�������� ���� �����}
  TFuture<integer>.WaitForAll(futures);
  info.Lines.Add('�������� ���������. �������� ��� ����������');
  info.Lines.Add('������ ��������� ' + f1.GetValue.ToString);
  info.Lines.Add('������ ��������� ' + f2.GetValue.ToString);
  info.Lines.Add('������ ��������� ' + f3.GetValue.ToString);
  {�������� ����� ������ �� �����}
//  TFuture<integer>.WaitForAny([f3]);
//  info.Lines.Add('������ ��������� ' + f1.GetValue.ToString);
//  info.Lines.Add('�������� ���������. ������� ������ ���������');
//  info.Lines.Add('������ ��������� ' + f2.GetValue.ToString);
//  info.Lines.Add('������ ��������� ' + f3.GetValue.ToString);
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
                                                 {----- �������� ���������� -----}
                                                 if (TaskLoop.Status = TTaskStatus.Canceled) and (not LoopState.Stopped) then LoopState.Stop;
                                                 if LoopState.Stopped then
                                                 begin
                                                   TThread.Queue(TThread.Current,
                                                                 procedure
                                                                 begin
                                                                   info.Lines.Add(string.Join(' - ', [AIndex.ToString, '��������� ��������']));
                                                                 end);
                                                   exit;
                                                 end;
                                                 {----- ���� ����� -----}
                                                 PrimesBelow(100000);
                                                 TThread.Queue(TThread.Current,
                                                               procedure
                                                               begin
                                                                 info.Lines.Add(AIndex.ToString);
                                                               end);
                                               end);
                          if res.Completed
                             then info.Lines.Add('������������ ��������� ���������')
                             else info.Lines.Add('������������ ��������� ��������');
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
