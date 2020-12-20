program GloutoMan;

{$R *.dres}

uses
  Vcl.Forms,
  UnitMain in 'UnitMain.pas' {FormMain},
  UnitProprietes in 'UnitProprietes.pas' {FormProprietes},
  UnitAPropos in 'UnitAPropos.pas' {FormAPropos},
  UnitObjets in 'UnitObjets.pas',
  JME_Jeux2D in 'JME_Jeux2D.pas',
  UnitMessages in 'UnitMessages.pas' {FormMessages};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(TFormProprietes, FormProprietes);
  Application.CreateForm(TFormAPropos, FormAPropos);
  Application.CreateForm(TFormMessages, FormMessages);
  Application.Run;
end.
