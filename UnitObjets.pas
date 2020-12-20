unit UnitObjets;

interface

uses
  Winapi.Windows, ExtCtrls, Vcl.Controls, JME_Jeux2D;


type TGloutoMan = class(TSprite)
    public
      x, y : Integer;
      positionInitX, positionInitY : Integer;
      objetSelected : Integer;
      vie, score : Integer;

      constructor Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
      procedure Animate; override;
      procedure Pacgom;
      procedure Freeze;

end;

type TFantome = class(TSprite)
    public
      x, y : Integer;
      dureeDirection, directionEnCours : Integer;
      reincarnation : Integer;
      reincarné : Boolean;
      couleur : 1..4;

      Constructor Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
      procedure Afficher(zoneAffichage : TImage; peur : Boolean); reintroduce;
      procedure Animate; override;
      procedure Mangé;

end;

type TBonus = class(TSprite)
    public
      x, y : Integer;
end;

type TBombe =class(TSprite)
    public
      x, y : Integer;
      active : Boolean;

      Constructor Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
      procedure Animate; override;
end;

implementation

//
//  ***********************
//  **     GloutoMan     **
//  ***********************
//
constructor TGloutoMan.Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
begin
  Inherited;
  score := 0;
  vie := 4;
end;

procedure TGloutoMan.Animate;
var
  tickCount : Integer;
begin
  tickCount := GetTickCount;

  // Animation générale des GloutoMan
  if (tickCount-lastTickCount[1]>=vitesseAnimation) and present then
  begin
    lastTickCount[1] := tickCount;
    inc(image_courante);
    if (image_courante>=nbImages) then image_courante:=0;
  end;

  // Animation des GloutoMan qui ont mangé une Pacgom
  if (tickcount-lasttickcount[2]>=7000) and (etat=2) then
  begin
    lasttickcount[2]:=tickcount;
    etat:=1;
  end;
  if (tickcount-lasttickcount[2]>=3000) and (etat=1) then
  begin
    lasttickcount[2]:=tickcount;
    etat:=0;
  end;

  if (tickcount-lasttickcount[3]>=2000) and (pause) then
  begin
    lasttickcount[3]:=tickcount;
    pause:=false;
  end;
end;

procedure TGloutoMan.Pacgom;
begin
  etat:=2;
  lasttickcount[2]:=GetTickCount;
end;

procedure TGloutoMan.Freeze;
begin
  pause:=true;
  lasttickcount[3]:=GetTickCount;
end;


//  ------------------------------------------------------------------------------------------------------------------------------------------------

//
//  ***********************
//  **     Fantômes      **
//  ***********************
//
constructor TFantome.Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
begin
  Inherited;
  reincarnation := 20000;
end;

procedure TFantome.Animate;
var
  tickCount : Integer;
begin
  tickCount := GetTickCount;

  // Animation générale des fantômes
  if (tickCount-lastTickCount[1]>=vitesseAnimation) and present then
  begin
    lastTickCount[1] := tickCount;
    inc(image_courante);
    if (image_courante>=nbImages) then image_courante:=0;
  end;

  // Animation des fantômes mangés (0=normal, 1=yeux, 2=intermédiaire 1 et 3=intermédiaire 2)
  if (tickcount-lasttickcount[2]>=reincarnation div 3) and (etat=1) then
  begin
       lasttickcount[2]:=tickcount;
       etat:=2;
  end;
  if (tickcount-lasttickcount[2]>=reincarnation div 3) and (etat=2) then
  begin
       lasttickcount[2]:=tickcount;
       etat:=3;
  end;
  if (tickcount-lasttickcount[2]>=reincarnation div 3) and (etat=3) then
  begin
       lasttickcount[2]:=tickcount;
       etat:=0;
       reincarné := True;
  end;
end;

procedure TFantome.Afficher(zoneAffichage : TImage; peur : Boolean);
begin
  if present then
  begin
    if not(peur)or(etat>0) then listeImages.draw(zoneAffichage.canvas,pixelX-16,pixelY-14,couleur*8-8+image_courante+etat*2)
    else listeImages.draw(zoneAffichage.canvas,pixelX-16,pixelY-14,image_courante+32);
    Animate;
  end;
end;

procedure TFantome.Mangé;
begin
  etat:=1;
  lastTickCount[2] := GetTickCount;
end;

//  ------------------------------------------------------------------------------------------------------------------------------------------------

//
//  ***********************
//  **      Bombes       **
//  ***********************
//
constructor TBombe.Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
begin
  Inherited;
  active := False;
end;

procedure TBombe.Animate;
var
  tickCount : Integer;
begin
  tickCount := GetTickCount;

  // Animation
  if (tickCount-lastTickCount[1]>=vitesseAnimation) and present then
  begin
    lastTickCount[1] := tickCount;

    if active then inc(image_courante) else image_courante :=0;
    if (image_courante>=nbImages) then image_courante:=1;
  end;

end;


end.
