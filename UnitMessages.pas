unit UnitMessages;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList;

type
  TFormMessages = class(TForm)
    ButtonOK: TButton;
    ImageFond: TImage;
    Message: TLabel;
    ImageList1: TImageList;
    ButtonNon: TButton;
    procedure ButtonOKClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ButtonNonClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  FormMessages: TFormMessages;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormMessages.ButtonNonClick(Sender: TObject);
begin
  FormMain.reponseMessage := False;
  close;
end;

procedure TFormMessages.ButtonOKClick(Sender: TObject);
begin
  FormMain.reponseMessage := True;
  close;
end;

procedure TFormMessages.FormShow(Sender: TObject);
var
  x, y : Integer;
begin
  x := 1;
  y := 1;
  imageFond.canvas.brush.color:=FormMain.couleur_fond;
  imageFond.canvas.pen.color:=FormMain.couleur_fond;
  imageFond.canvas.rectangle(0,0,282,178);
  for x := 1 to 35 do imageList1.draw(imageFond.canvas,x*8-8+1,1*8-8+1,trunc(random(6)));
  for x := 1 to 35 do imageList1.draw(imageFond.canvas,x*8-8+1,22*8-8+1,trunc(random(6)));
  for y := 1 to 22 do imageList1.draw(imageFond.canvas,1*8-8+1,y*8-8+1,trunc(random(6)));
  for y := 1 to 22 do imageList1.draw(imageFond.canvas,35*8-8+1,y*8-8+1,trunc(random(6)));
  message.Caption := FormMain.messageAAfficher;
  if not(FormMain.typeMessage) then
  begin
    buttonNon.Visible := False;
    buttonOK.Width := 249;
    buttonOK.Caption := 'CONTINUER';
  end
  else
  begin
    buttonNon.Visible := True;
    buttonOK.Width := 122;
    buttonOK.Caption := 'OUI';
  end;

end;

end.
