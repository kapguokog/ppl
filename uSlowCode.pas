unit uSlowCode;

interface

  function SlowIsPrime(AInteger: integer): boolean;
  function PrimesBelow(AInteger: integer): integer;
  function PrimesBelowParallel(AInteger: integer): integer;

implementation

uses System.Threading, System.SyncObjs;

function SlowIsPrime(AInteger: integer): boolean;
var i : integer;
begin
  Assert(AInteger > 0, '���������� �������� �� ����� ���� �������');
  if AInteger = 1 then exit(false) else result := true;
  for i := 2 to AInteger - 1 do if AInteger mod i = 0 then exit(false);
end;

function PrimesBelow(AInteger: integer): integer;
var i : integer;
begin
  result := 0;
  for i := 1 to AInteger do if SlowIsPrime(i) then inc(result);
end;

function PrimesBelowParallel(AInteger: integer): integer;
var temp : integer;
begin
  temp := 0;
  TParallel.For(1, AInteger,
                procedure(AIndex: integer)
                begin
                  if SlowIsPrime(AIndex) then TInterlocked.Increment(temp);     // ��������� ��������� ����������, ����� ������ � ��� ����������������
                end);
  result := temp;
end;


end.
