program ProjectReceiveData;

uses
  System.StartUpCopy,
  FMX.Forms,
  UnitReceiveData in 'UnitReceiveData.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
