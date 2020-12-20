unit UnitProprietes;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.ExtCtrls,
  System.ImageList, Vcl.ImgList, Vcl.WinXCtrls, Vcl.Imaging.pngimage;

type
  TFormProprietes = class(TForm)
    PageControl1: TPageControl;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Image1: TImage;
    Image2: TImage;
    Image3: TImage;
    TrackBar1: TTrackBar;
    TrackBar2: TTrackBar;
    TrackBar3: TTrackBar;
    CheckBox1: TCheckBox;
    Label4: TLabel;
    Panel5: TPanel;
    Image10: TImage;
    CheckBox2: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox3: TCheckBox;
    Image5: TImage;
    ImageList1: TImageList;
    Timer1: TTimer;
    Image4: TImage;
    GroupBox1: TGroupBox;
    ToggleSwitch1: TToggleSwitch;
    Label1: TLabel;
    Label2: TLabel;
    RadioButton2: TRadioButton;
    RadioButton1: TRadioButton;
    CheckBox7: TCheckBox;
    Panel1: TPanel;
    Image6: TImage;
    Image7: TImage;
    Panel3: TPanel;
    Image8: TImage;
    Panel4: TPanel;
    Image9: TImage;
    Image11: TImage;
    Bevel6: TBevel;
    Bevel5: TBevel;
    Bevel4: TBevel;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure CheckBox7Click(Sender: TObject);
  private
    { Déclarations privées }
    img_courante:integer;
    recommencer:boolean;
  public
    { Déclarations publiques }
  end;

var
  FormProprietes: TFormProprietes;

implementation

uses UnitMain;

{$R *.dfm}

procedure TFormProprietes.Button1Click(Sender: TObject);
begin
  formMain.vitesse_selectglouto:=110-trackbar1.position;
  formMain.vitesse_fantome:=110-trackbar2.position;
  formMain.reincarnation:=trackbar3.position*1000;
  formMain.animations:=checkbox1.Checked;
  formMain.visu_img:=checkbox3.Checked;
  if ToggleSwitch1.State=tssOff then formMain.avancePixels:=1;
  if ToggleSwitch1.State=tssOn then formMain.avancePixels:=2;
  formMain.invincible:=checkbox2.Checked;
  formMain.all_objets:=checkbox5.Checked;
  formMain.afficherTout:=checkbox6.Checked;
  close;
  formMain.pause:=false;
  formMain.pause1.hide;
  if recommencer then
  begin
    if MessageDlg('Vous allez débuter une nouvelle partie',mtConfirmation, [mbYes, mbNo], 0) = mrYes then
    begin
      formMain.multijoueurs:=checkbox7.Checked;
      formMain.cooperatif:=radioButton1.Checked;
      formMain.adversaire:=radioButton2.Checked;
      formMain.nouvelle_partie;
    end;
  end;
end;

procedure TFormProprietes.Button2Click(Sender: TObject);
begin
  close;
  formMain.pause:=false;
  formMain.pause1.hide;
end;

procedure TFormProprietes.Button3Click(Sender: TObject);
begin
  trackbar1.position:=110-30;
  trackbar2.position:=110-55;
  trackbar3.position:=30;
  checkbox1.Checked:=true;
  checkbox3.Checked:=false;
  checkbox2.Checked:=false;
  checkbox5.Checked:=false;
  checkbox6.Checked:=false;
end;

procedure TFormProprietes.CheckBox7Click(Sender: TObject);
begin
  recommencer:=true;
end;

Procedure TFormProprietes.FormShow(Sender: TObject);
begin
  recommencer:=false;
  timer1.interval:=formMain.vitesse_animations;
  tabsheet3.tabvisible:=formMain.triche;
  tabsheet2.tabvisible:=false;
  trackbar1.position:=110-formMain.vitesse_selectglouto;
  trackbar2.position:=110-formMain.vitesse_fantome;
  trackbar3.position:=formMain.reincarnation div 1000;
  checkbox1.Checked:=formMain.animations;
  checkbox3.Checked:=formMain.visu_img;
  if formMain.avancePixels=1 then ToggleSwitch1.State:=tssOff;
  if formMain.avancePixels=2 then ToggleSwitch1.State:=tssOn;
  checkbox2.Checked:=formMain.invincible;
  checkbox5.Checked:=formMain.all_objets;
  checkbox6.Checked:=formMain.afficherTout;
  checkbox7.Checked:=formMain.multijoueurs;
  radioButton1.Checked:=formMain.cooperatif;
  radioButton2.Checked:=formMain.adversaire;
end;

procedure TFormProprietes.Timer1Timer(Sender: TObject);
begin
  with image4.canvas do
     begin
          brush.color:=clblack;
          pen.color:=clblack;
          rectangle(0,0,24,24);
          ImageList1.Draw(image4.Canvas,0,0,img_courante);
     end;
     if checkbox1.checked then inc(img_courante);
     if img_courante=6 then img_courante:=0;
end;

end.
