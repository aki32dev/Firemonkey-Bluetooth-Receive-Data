unit UnitReceiveData;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.ScrollBox,
  FMX.Memo, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ListBox, System.Bluetooth;

type
  TForm1 = class(TForm)
    ComboBox1: TComboBox;
    Button1: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Timer1: TTimer;
    procedure FormShow(Sender: TObject);
    function ManagerConnected:Boolean;
    procedure PairedDevices;
    procedure Button1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TReceive = class(TThread)
  private
    Memo1 : TMemo;
  public
    constructor Create;
    procedure Execute; override;
  end;

var
  Form1: TForm1;

var
  FSocket: TBluetoothSocket;
  FBluetoothManager: TBluetoothManager;
  FPairedDevices: TBluetoothDeviceList;
  FAdapter: TBluetoothAdapter;
  LDevice: TBluetoothDevice;
  stringdata : String;

const
  sGUID = '{00001101-0000-1000-8000-00805F9B34FB}';

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  BluetoothAdapter: TBluetoothAdapter;
begin
  try
    FBluetoothManager := TBluetoothManager.Current;
    BluetoothAdapter := FBluetoothManager.CurrentAdapter;
    FPairedDevices := BluetoothAdapter.PairedDevices;
    LDevice := FPairedDevices[Combobox1.ItemIndex] as TBluetoothDevice;

    if LDevice.IsPaired then
    begin
      FSocket := LDevice.CreateClientSocket(stringtoGUID(sguid), false);
      FSocket.Connect;
      Button1.Text := 'Connected';
      TReceive.Create;
    end;
  except
    ShowMessage('Restart your application');
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  try
    FBluetoothManager := TBluetoothManager.Current;
    FAdapter := FBluetoothManager.CurrentAdapter;
    if ManagerConnected then
    begin
      PairedDevices;
      Combobox1.ItemIndex := 0;
    end;
  except
    on E : Exception do
    begin
      FBluetoothManager.EnableBluetooth;
    end;
  end;
end;

function TForm1.ManagerConnected:Boolean;
begin
  if FBluetoothManager.ConnectionState = TBluetoothConnectionState.Connected then
  begin
    Result := True;
  end
  else
  begin
    Result := False;
  end
end;

procedure TForm1.PairedDevices;
var
  I: Integer;
begin
  Combobox1.Clear;
  if ManagerConnected then
  begin
  FPairedDevices := FBluetoothManager.GetPairedDevices;
  if FPairedDevices.Count > 0 then
    for I:= 0 to FPairedDevices.Count - 1 do
    begin
      Combobox1.Items.Add(FPairedDevices[I].DeviceName);
    end;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  if (stringdata <> '') then
  begin
    Memo1.Lines.Add(stringdata);
    stringdata := '';
  end;
end;

constructor TReceive.Create;
begin
  Inherited Create(False);
end;

procedure TReceive.Execute;
var
  LBuffer: TBytes;
  LReset: Boolean;
begin
  inherited;
  Setlength(LBuffer,0);
  while not Terminated do
  begin
    if FSocket <> nil then
    begin
      LReset := False;
      While not terminated and FSocket.Connected and (not LReset) do
      begin
        try
          LBuffer := FSocket.ReadData;
          if (Length(LBuffer) > 0) then
          begin
            stringdata := TEncoding.UTF8.GetString(LBuffer);
            Setlength(LBuffer,0);
          end;
        except
          LReset := True;
        end;
        sleep(1000);
      end;
    end;
  end;
end;

end.
