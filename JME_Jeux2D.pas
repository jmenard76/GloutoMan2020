unit JME_Jeux2D;

interface

uses
  Winapi.Windows, ExtCtrls, Vcl.Controls;


type TSprite = class(TObject)
    private


    public
      indexImage, nbImages, vitesseAnimation : Integer;
      listeImages : TImageList;

      pixelX, pixelY : Integer;
      etat, vitesse : Integer;
      image_courante : Integer;
      direction : Integer;
      present, pause, arret : Boolean;
      lastTickCount : Array[1..5] of Integer;

      constructor Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
      procedure Afficher(zoneAffichage : TImage); virtual;
      procedure Animate; virtual;
end;


implementation

//
//  ***********************
//  **      Sprite       **
//  ***********************
//
constructor TSprite.Create(listeImagesInit : TImageList; indexImageInit, nbImagesInit, vitesseAnimationInit : Integer; presentInit : Boolean);
begin
  etat := 0;
  vitesse := 0;
  image_courante := 0;
  direction := 0;
  listeImages := listeImagesInit;
  indexImage := indexImageInit;
  nbImages := nbImagesInit;
  vitesseAnimation := vitesseAnimationInit;
  present := presentInit;
end;

procedure TSprite.Animate;
var
  tickCount : Integer;
begin
  tickCount := GetTickCount;

  if (tickCount-lastTickCount[1]>=vitesseAnimation) and present then
  begin
    lastTickCount[1] := tickCount;
    inc(image_courante);
    if (image_courante>=nbImages) then image_courante:=0;
  end;

end;

procedure TSprite.Afficher(zoneAffichage : TImage);
begin
  if present then
  begin
    listeImages.draw(zoneAffichage.canvas,pixelX-16,pixelY-15,(direction*12-12+image_courante+etat*3) + indexImage);
    Animate;
  end;
end;


end.
