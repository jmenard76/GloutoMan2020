unit UnitAPropos;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TFormAPropos = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Button1: TButton;
    Panel2: TPanel;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FormAPropos: TFormAPropos;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormAPropos.Button1Click(Sender: TObject);
begin
  close;
  formMain.pause:=false;
  formMain.pause1.Hide;
end;

end.
