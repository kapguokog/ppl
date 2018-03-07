program PPLMonitor;

uses
  Vcl.Forms,
  uPPLMonitor in 'uPPLMonitor.pas' {fmPPLMonitor},
  uSlowCode in 'uSlowCode.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmPPLMonitor, fmPPLMonitor);
  Application.Run;
end.
