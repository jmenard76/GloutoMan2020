unit UnitMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.Menus, Vcl.StdCtrls, Vcl.ImgList, System.ImageList, MMSystem, inifiles, UnitObjets,
  Vcl.MPlayer;

type
  TFormMain = class(TForm)
    MainMenu1: TMainMenu;
    Jeu1: TMenuItem;
    Nouvellepartie1: TMenuItem;
    Chargeruntableau1: TMenuItem;
    N1: TMenuItem;
    Quitter1: TMenuItem;
    Options1: TMenuItem;
    Propritsdujeu1: TMenuItem;
    Effetssonores1: TMenuItem;
    N2: TMenuItem;
    Aproposde1: TMenuItem;
    zoneScore: TImage;
    zoneObjets: TImage;
    zoneJeux: TImage;
    Pause1: TLabel;
    TimerPrincipal: TTimer;
    OpenDialog1: TOpenDialog;
    ImageListMurs: TImageList;
    ImageListObjets: TImageList;
    ImageListExplosion: TImageList;
    LabelPoints: TLabel;
    ImageListGloutoMan: TImageList;
    ImageListFantomes: TImageList;
    Recommencerletableau1: TMenuItem;
    lectureTableau: TMemo;
    PanelMessages: TPanel;
    ButtonNon: TButton;
    ButtonOK: TButton;
    ImageFond: TImage;
    Message: TLabel;

    procedure InitialisationObjets;
    procedure DestructionObjets;
    procedure nouvelle_partie;
    procedure debut_tableau;
    procedure charger_tableau_resource(level:Integer);
    procedure charger_tableau(nom_fichier:string);
    procedure dessiner;
    procedure afficher_score;
    procedure charger_ini;
    procedure deplacer_fantome(n:integer);
    procedure deplacer_gloutoman(n:integer);
    procedure verif_case(n:integer);
    procedure test_collision;
    procedure perdu;
    procedure niveau_reussi;
    procedure gagner;
    procedure afficherPoints(var n:integer; points:string);
    procedure explosion_bombe(n:integer);

    procedure jouerSon(son:integer);
    procedure FormCreate(Sender: TObject);
    procedure TimerPrincipalTimer(Sender: TObject);
    procedure Aproposde1Click(Sender: TObject);
    procedure Quitter1Click(Sender: TObject);
    procedure Propritsdujeu1Click(Sender: TObject);
    procedure Effetssonores1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure AppDeactivate(Sender: TObject);
    procedure AppActivate(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure Chargeruntableau1Click(Sender: TObject);
    procedure Nouvellepartie1Click(Sender: TObject);
    procedure Recommencerletableau1Click(Sender: TObject);
    procedure affichageMessage(texte : String; typeAffichageMessage : Integer);
    procedure ButtonOKClick(Sender: TObject);
    procedure ButtonNonClick(Sender: TObject);

  private
    { Déclarations privées }
  public
    { Déclarations publiques }

    // Variables générales
    tableau : array[1..80, 1..50] of Integer;
    valeurPrec: array[1..2] of Integer;
    couleur_fond:TColor;
    couleur_mur, couleur_murf : Integer;
    effetsSonores, visu_img, one, typeMessage : Boolean;
    lien_tableau, messageAAfficher : String;
    actionMessage : Integer;

    // Variables pour noms de fichiers
    nomfich, nom_image, ch_tableaux, ch_sons : String;

    // Variables pour modes de jeu
    scenario_cerises, scenario_points, scenario_objet, multijoueurs, cooperatif, adversaire : Boolean;
    nb_level, level, hscore : Integer;
    scoreDebutNiveau : array[1..2] of Integer;
    nb_cerises, nb_bananes, nb_fantomes, nb_bouton, nb_tempo, nb_porte, nb_telep, nb_cle, temps_timer : Integer;
    recup_objet, recup_points : Integer;

    // Variables pour animations
    lastTickCount : array[1..55, 1..2] of integer;    // Tableau de variables pour *** TimerPrincipalTimer ***
        { [1,1]       : rafraichissement général du jeu
          [2,1]       : déplacement des fantômes
          [3,1]       : déplacement du GloutoMan jaune
          [3,2]       : déplacement du GloutoMan vert
          [4,1]       :
          [5,1]       :
          [5,2]       :
          [6,1]       :
          [7,1]       : animations du timer d'arrêt des fantômes
          [8,1]       : animations des portes
          [9,1]       :
          [10,1]      : animations des explosions
          [10,2]      : animations des explosions
          [11,1]      :
          [12,1]      :
          [12,2]      :
          [13,1]      :
          [13,2]      :
          [21..30,1]  :
          [31..35,1]  : gestion des temporisations
          [41..50,1]  : gestion de la refermeture des portes
          [51..53,1]  :
          [54,1]      : animations de l'affichage des points récoltés
          [55,1]      : animations de l'affichage de la pause }
    pause, pauseAuto, animations : Boolean;
    refresh, vitesse_selectglouto, vitesse_fantome, vitesse_animations : Integer;
    avancePixels, reincarnation, vcolle, vpat : Integer;
    coef_vitesse_fantome : Single;
    animX, animY : Integer;
    animOuverture, animFermeture : Boolean;

    // Variables pour triche
    tricheur,triche,invincible,all_objets,afficherTout : Boolean;
    lettre : Integer;
  end;

//
//  Objets
//
  TObjet=record
    quantite : Integer;
  end;
  TPorte=record
    x, y : Integer;
    present, modele, fermee, fermeture, ouverture, tempoActive, tempoNonPermanente : Boolean;
    tempoFermeture : Integer;
    image_courante : Integer;
  end;
  TTemporisation=record
    x, y : Integer;
    present, seule : Boolean;
    lien : array[1..10] of Integer;
    valeur : Integer;
  end;
  TBouton=record
    x, y, lien : Integer;
    present : Boolean;
  end;
  TTeleporteur=record
    x, y, lien : Integer;
    present : Boolean;
    image_courante : Integer;
  end;
  TCle=record  // Pas utilisé
    x, y, lien : Integer;
    present : Boolean;
  end;
  TExplosion=record
    x, y : Integer;
    active : Boolean;
    image_courante : Integer;
  end;
//
//  Constantes
//
const
     // Constantes générales
     VERSION_PERSO=False;
     NB_COLONNES=80;
     NB_LIGNES=50;
     NB_NIVEAUX=20;

     // Bordures des GloutoMan
     BORD_G_GAUCHE=13;
     BORD_G_DROITE=11;
     BORD_G_HAUT=11;
     BORD_G_BAS=13;

     // Bordures des fantômes
     BORD_F_GAUCHE=13;
     BORD_F_DROITE=11;
     BORD_F_HAUT=11;
     BORD_F_BAS=13;

     // N° des images dans les ImageList
     IMG_INVISIBLE=16;
     IMG_CERISE=0;
     IMG_BANANE=1;
     IMG_POINT=2;
     IMG_PIECE=3;
     IMG_POMME=4;
     IMG_FLEUR=5;
     IMG_MULTIPLICATEUR=6;
     IMG_BOUTON=59;
     IMG_TEMPO=9;
     IMG_PACGOM=10;
     IMG_COLLE=11;
     IMG_PATINOIRE=12;
     IMG_GLACE=13;
     IMG_TIMER=14;
     IMG_PASSAGE=17;
     IMG_TELEPORTEUR=21;
     IMG_VIESUPP=27;
     IMG_SECOURS=31;
     IMG_GOUSSE=32;
     IMG_POISON=33;
     IMG_CLEF=34;
     IMG_DYNAMITE=35;
     IMG_BOMBE=38;
     IMG_PORTEH=41;
     IMG_PORTEV=46;
     IMG_PORTECOULH=51;
     IMG_PORTECOULV=55;
     IMG_ERREUR=30;
     IMG_PORTE=43;
     IMG_PORTEMUR=7;
     IMG_AIL=60;
     IMG_EXPLOSION=0;
     COUL_MURF=17;

     // Nombre d'images pour les animations
     NBI_GLOUTOMAN=6;
     NBI_FANTOME=2;
     NBI_PASSAGE=4;
     NBI_VIESUPP=4;
     NBI_TIMER=3;
     NBI_BONUS=3;
     NBI_PORTE=5;
     NBI_PORTE2=4;
     NBI_TELEP=6;
     NBI_DYNAMITE=3;
     NBI_BOMBE=3;
     NBI_EXPLOSION=17;

     // Sons placés en resources
     SND_BONUS=0;
     SND_BONUS2=1;
     SND_CERISE=2;
     SND_CODE=3;
     SND_EXPLOSION=4;
     SND_MANGER=6;
     SND_TUER_TRICHE=7;
     SND_PASSAGE=8;
     SND_POP=9;
     SND_PORTE=10;
     SND_GELER=5;
     SND_REINCARN=11;
     SND_TUER=13;
     SND_TUT=14;
     SND_WIP=15;
     SND_TELEP=12;
     SND_PIECE=16;
     SND_GAGNE=17;
     SND_PERDU=18;

     // Messages
     MESSAGE1='Vous avez réussi le niveau ';
     MESSAGE2='Vous n''avez plus de vie :'#13'La partie est terminée.';
     MESSAGE3='Le GloutoMan jaune a gagné le niveau ';
     MESSAGE4='Le GloutoMan vert a gagné le niveau ';
     MESSAGE5='Un fichier est introuvable.';
     MESSAGE6='Félicitations, vous avez gagné la partie. Démarrer une nouvelle partie?';
     MESSAGE7='Voulez-vous faire une autre partie?';
     MESSAGE8='Le GloutoMan jaune a gagné la partie.';
     MESSAGE9='Le GloutoMan vert a gagné la partie.';

var
  FormMain: TFormMain;

implementation

uses UnitProprietes, UnitAPropos;
//
//  **************************
//  ** Variables générales  **
//  **************************
//
var
   gloutoman : array[1..2] of TGloutoMan;
   fantome : array[1..10] of TFantome;
   objet : array[0..10,1..2] of TObjet;
   dynamite, bombe : array[1..2] of TBombe;
   explosion : array[1..2] of TExplosion;
   passage, viesupp, timer, bonus, telep : TBonus;
   tempo : array[1..5] of TTemporisation;
   bouton : array[1..5] of TBouton;
   porte : array[1..10] of TPorte;
   teleporteur : array[1..5] of TTeleporteur;
   cle : array[1..5] of TCle;   // Pas utilisé

{$R *.dfm}

//
//  *****************
//  **  Fonctions  **
//  *****************
//
function chemin_application:string;
var
   ch : String;
   i : Integer;
begin
     ch:=application.exename;
     i:=length(ch);
     repeat
           dec(i);
     until (ch[i] in ['\',':']);
     chemin_application:=copy(ch,1,i);
end;

procedure TFormMain.jouerSon(son:integer);
var
  choixSon : pChar;
begin
  if effetsSonores then
  begin
    choixSon:='CODE';
    case son of
      SND_BONUS:choixSon:='BONUS';
      SND_BONUS2:choixSon:='BONUS2';
      SND_CERISE:choixSon:='CERISES';
      SND_CODE:choixSon:='CODE';
      SND_EXPLOSION:choixSon:='EXPLOSE';
      SND_MANGER:choixSon:='HURT';
      SND_TUER_TRICHE:choixSon:='TUER_TRICHE';
      SND_PASSAGE:choixSon:='PASSAGE';
      SND_POP:choixSon:='POP';
      SND_PORTE:choixSon:='PORTE';
      SND_GELER:choixSon:='GELER';
      SND_REINCARN:choixSon:='REINCARN';
      SND_TUER:choixSon:='TUER';
      SND_TUT:choixSon:='TUT';
      SND_WIP:choixSon:='WIP';
      SND_TELEP:choixSon:='TELEP';
      SND_PIECE:choixSon:='PIECE';
      SND_GAGNE:choixSon:='GAGNE';
      SND_PERDU:choixSon:='PERDU';
    end;
    playSound(choixSon, GetModuleHandle(nil), SND_RESOURCE or SND_ASYNC);
  end;
end;

procedure TFormMain.InitialisationObjets;
var
  numFantome, numBombe : Integer;
begin
    gloutoman[1] := TGloutoMan.Create(ImageListGloutoMan, 0, NBI_GLOUTOMAN, 120, False);
    gloutoman[2] := TGloutoMan.Create(ImageListGloutoMan, 48, NBI_GLOUTOMAN, 120, False);
    for numFantome := 1 to 10 do fantome[numFantome] := TFantome.Create(ImageListFantomes, 0, NBI_FANTOME, 120, False);
    passage := TBonus.Create(ImageListObjets, IMG_PASSAGE, NBI_PASSAGE, vitesse_animations, True);
    viesupp := TBonus.Create(ImageListObjets, IMG_VIESUPP, NBI_VIESUPP, vitesse_animations, True);
    timer := TBonus.Create(ImageListObjets, IMG_TIMER, NBI_TIMER, vitesse_animations, True);
    bonus := TBonus.Create(ImageListObjets, IMG_MULTIPLICATEUR, NBI_BONUS, vitesse_animations, True);
    telep := TBonus.Create(ImageListObjets, IMG_TELEPORTEUR, NBI_TELEP, vitesse_animations, True);
    for numBombe := 1 to 2 do
    begin
      dynamite[numBombe] := TBombe.Create(ImageListObjets, IMG_DYNAMITE, NBI_DYNAMITE, vitesse_animations, True);
      bombe[numBombe] := TBombe.Create(ImageListObjets, IMG_BOMBE, NBI_BOMBE, vitesse_animations, True);
    end;
end;

procedure TFormMain.DestructionObjets;
var
  numFantome, numBombe : Integer;
begin
    gloutoman[1].Destroy;
    gloutoman[2].Destroy;
    for numFantome := 1 to 10 do fantome[numFantome].Destroy;
    passage.Destroy;
    viesupp.Destroy;
    timer.Destroy;
    bonus.Destroy;
    telep.Destroy;
    for numBombe := 1 to 2 do
    begin
      dynamite[numBombe].Destroy;
      bombe[numBombe].Destroy;
    end;
end;
//
//  ******************************
//  **  Gestion de l'interface  **
//  ******************************
//
procedure TFormMain.AppActivate(Sender: TObject);
begin
  if pauseauto then
  begin
       pause:=false;
       pause1.visible:=false;
       pauseauto:=false;
  end;
end;

procedure TFormMain.AppDeactivate(Sender: TObject);
begin
  if not(pause) then
  begin
       pause:=true;
       pause1.visible:=true;
       pauseAuto:=true;
  end;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
    //application.onactivate:=appactivate;
    //application.ondeactivate:=appdeactivate;
    Chargeruntableau1.Visible:=VERSION_PERSO;
    Charger_ini;
    InitialisationObjets;
    if ch_tableaux='' then ch_tableaux:=chemin_application;
    Opendialog1.initialdir:=ch_tableaux;
    Randomize;
    Nouvelle_partie;
end;

procedure TFormMain.charger_ini;
var
  fichierIni : TInifile;
begin
     fichierIni := TIniFile.Create(chemin_application+'gloutoman.ini');
     hscore := fichierIni.readInteger('Scores', 'High score',0);
     Effetssonores1.checked := fichierIni.readbool('Options','Effets sonores', True);
     effetsSonores := Effetssonores1.checked;
     avancePixels := fichierIni.readinteger('Vitesses','nb_cases',2);
     refresh := fichierIni.readinteger('Affichage','Rafraichissement',30);
     vitesse_selectglouto := fichierIni.readInteger('Vitesses', 'gloutoman',30);
     vitesse_fantome := fichierIni.readInteger('Vitesses', 'fantomes',55);
     reincarnation := fichierIni.readInteger('Vitesses', 'réincarnations',35)*1000;
     vitesse_animations := round(refresh*10);
     vcolle := round(vitesse_selectglouto/1.5);
     vpat := round(vitesse_selectglouto/1.5);
     animations := true;        //theini.readbool('Affichage','Animations',true);
     visu_img := false;         //theini.readbool('Affichage','Images de fond',false);
     multijoueurs := fichierIni.readbool('Multijoueur','Joueurs', False);
     cooperatif := fichierIni.readbool('Multijoueur','Mode coopératif', True);
     adversaire := fichierIni.readbool('Multijoueur','Mode adversaire', False);
     nb_level := NB_NIVEAUX;    //theini.readinteger('Niveaux','Nombre de niveaux',1);
     if VERSION_PERSO then ch_tableaux := fichierIni.readstring('Chemins','tableaux',chemin_application+'niveaux\');
     fichierIni.Free;
end;

procedure TFormMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
   fichierIni : TInifile;
begin
     fichierIni := TIniFile.Create(chemin_application+'gloutoman.ini');
     fichierIni.WriteInteger('Scores', 'High score', hscore);
     fichierIni.writebool('Options','Effets sonores', Effetssonores1.checked);
     fichierIni.WriteInteger('Vitesses', 'gloutoman', vitesse_selectglouto);
     fichierIni.WriteInteger('Vitesses', 'fantomes', vitesse_fantome);
     fichierIni.WriteInteger('Vitesses', 'réincarnations', reincarnation div 1000);
     fichierIni.writeinteger('Affichage','Rafraichissement', refresh);
     fichierIni.writebool('Multijoueur','Joueurs', multijoueurs);
     fichierIni.writebool('Multijoueur','Mode coopératif', cooperatif);
     fichierIni.writebool('Multijoueur','Mode adversaire', adversaire);
     if VERSION_PERSO then fichierIni.writestring('Chemins','tableaux', ch_tableaux);
     fichierIni.Free;
     DestructionObjets;
end;

//
//  ++  Menus  ++
//
procedure TFormMain.Nouvellepartie1Click(Sender: TObject);
begin
  Nouvelle_partie;
end;

procedure TFormMain.Recommencerletableau1Click(Sender: TObject);
begin
  if (gloutoman[1].vie>0) then dec(gloutoman[1].vie);
  if (gloutoman[2].vie>0) then dec(gloutoman[2].vie);
  gloutoman[1].score := scoreDebutNiveau[1];
  gloutoman[2].score := scoreDebutNiveau[2];
  jouerSon(SND_TUER);
  if (gloutoman[1].vie=0) and (gloutoman[2].vie=0) then Perdu else debut_tableau;
end;

procedure TFormMain.Chargeruntableau1Click(Sender: TObject);
begin
  pause:=true;
  if opendialog1.execute then
  begin
    nomfich:=opendialog1.filename;
    one:=true;
    level:=0;
  end;
  pause:=false;
  debut_tableau;
end;

procedure TFormMain.Quitter1Click(Sender: TObject);
begin
  close;
end;

procedure TFormMain.Propritsdujeu1Click(Sender: TObject);
begin
  pause:=true;
  Pause1.show;
  jouerSon(SND_BONUS);
  FormProprietes.Position:=poMainFormCenter;
  FormProprietes.ShowModal();
end;

procedure TFormMain.Effetssonores1Click(Sender: TObject);
begin
  Effetssonores1.Checked:=not(Effetssonores1.Checked);
  effetsSonores:=Effetssonores1.Checked;
end;

procedure TFormMain.Aproposde1Click(Sender: TObject);
begin
  pause:=true;
  pause1.Show;
  jouerSon(SND_BONUS2);
  formAPropos.ShowModal();
end;


//
//  ++  Gestion du clavier  ++
//
procedure TFormMain.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
    if key=VK_UP then begin gloutoman[1].direction:=2; gloutoman[1].arret:=false; end
    else if key=VK_RIGHT then begin gloutoman[1].direction:=1; gloutoman[1].arret:=false; end
    else if key=VK_DOWN then begin gloutoman[1].direction:=4; gloutoman[1].arret:=false; end
    else if key=VK_LEFT then begin gloutoman[1].direction:=3; gloutoman[1].arret:=false; end
    else if (key=VK_SPACE)and not(multijoueurs) and gloutoman[1].present then
    begin
          if (gloutoman[1].objetSelected=0)and(objet[0,1].quantite>0) then
          begin
               case tableau[gloutoman[1].x,gloutoman[1].y] of
                  0:begin
                    jouerSon(SND_POP);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=19;
                    dec(objet[0,1].quantite);
                    gloutoman[1].arret:=true;
                  end;
               end;
          end;
          if (gloutoman[1].objetSelected=1)and(objet[1,1].quantite>0)and(gloutoman[1].vie<4)then
          begin
               jouerSon(SND_POP);
               dec(objet[1,1].quantite);
               inc(gloutoman[1].vie);
          end;
          if (gloutoman[1].objetSelected=2) then
          begin
               if not(dynamite[1].active)and not(bombe[1].active)and(objet[2,1].quantite>0)then
               begin
                    case tableau[gloutoman[1].x,gloutoman[1].y] of
                    0:begin
                    dec(objet[2,1].quantite);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=42;
                    dynamite[1].x:=gloutoman[1].x;
                    dynamite[1].y:=gloutoman[1].y;
                    dynamite[1].active:=true;
                    end;
                    end;
               end
               else if dynamite[1].active then
               begin
                    explosion[1].x:=dynamite[1].x;
                    explosion[1].y:=dynamite[1].y;
                    explosion[1].active:=true;
                    tableau[dynamite[1].x,dynamite[1].y]:=0;
                    explosion_bombe(1);
               end;
          end;
          if (gloutoman[1].objetSelected=3) then
          begin
               if not(dynamite[1].active)and not(bombe[1].active)and(objet[3,1].quantite>0) then
               begin
                    case tableau[gloutoman[1].x,gloutoman[1].y] of
                    0:begin
                    dec(objet[3,1].quantite);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=43;
                    bombe[1].x:=gloutoman[1].x;
                    bombe[1].y:=gloutoman[1].y;
                    bombe[1].active:=true;
                    end;
               end;
               end
               else if bombe[1].active then
               begin
                    explosion[1].x:=bombe[1].x;
                    explosion[1].y:=bombe[1].y;
                    explosion[1].active:=true;
                    tableau[bombe[1].x,bombe[1].y]:=0;
                    explosion_bombe(1);
               end;
          end;
     end;
     if (key=VK_CONTROL)and multijoueurs and gloutoman[2].present then
     begin
          if(gloutoman[2].objetSelected=0)and(objet[0,2].quantite>0) then
          begin
               case tableau[gloutoman[2].x,gloutoman[2].y] of
                   0:begin
                   jouerSon(SND_POP);
                   tableau[gloutoman[2].x,gloutoman[2].y]:=19;
                   dec(objet[0,2].quantite);
                   gloutoman[2].arret:=true;
                   end;
               end;
          end;
          if (gloutoman[2].objetSelected=1)and(objet[1,2].quantite>0)and(gloutoman[2].vie<4) then
          begin
               dec(objet[1,2].quantite);
               inc(gloutoman[2].vie);
          end;
          if (gloutoman[2].objetSelected=2) then
          begin
               if not(dynamite[2].active)and not(bombe[2].active)and(objet[2,2].quantite>0) then
               begin
                    case tableau[gloutoman[2].x,gloutoman[2].y] of
                        0:begin
                        dec(objet[2,2].quantite);
                        tableau[gloutoman[2].x,gloutoman[2].y]:=27;
                        dynamite[2].x:=gloutoman[2].x;
                        dynamite[2].y:=gloutoman[2].y;
                        dynamite[2].active:=true;
                        end;
                    end;
               end
               else if dynamite[2].active then
               begin
                    explosion[2].x:=dynamite[2].x;
                    explosion[2].y:=dynamite[2].y;
                    explosion[2].active:=true;
                    tableau[dynamite[2].x,dynamite[2].y]:=0;
                    explosion_bombe(2);
               end;
          end;
          if (gloutoman[2].objetSelected=3) then
          begin
               if not(dynamite[2].active)and not(bombe[2].active)and(objet[3,2].quantite>0) then
               begin
                    case tableau[gloutoman[2].x,gloutoman[2].y] of
                        0:begin
                        dec(objet[3,2].quantite);
                        tableau[gloutoman[2].x,gloutoman[2].y]:=32;
                        bombe[2].x:=gloutoman[2].x;
                        bombe[2].y:=gloutoman[2].y;
                        bombe[2].active:=true;
                        end;
                    end;
               end
               else if bombe[2].active then
               begin
                    explosion[2].x:=bombe[2].x;
                    explosion[2].y:=bombe[2].y;
                    explosion[2].active:=true;
                    tableau[bombe[2].x,bombe[2].y]:=0;
                    explosion_bombe(2);
               end;
          end;
     end;
end;

procedure TFormMain.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if (key='-')and(gloutoman[1].objetSelected<3) then inc(gloutoman[1].objetSelected);
  if (key='*')and(gloutoman[1].objetSelected>0) then dec(gloutoman[1].objetSelected);
  if (key='é')and(gloutoman[2].objetSelected<3) then inc(gloutoman[2].objetSelected);
  if (key='&')and(gloutoman[2].objetSelected>0) then dec(gloutoman[2].objetSelected);
  if not(multijoueurs) then
  begin
          if key='p' then
          begin
               pause:=not(pause);
               pause1.visible:=pause;
          end;
          if (key='j') and (lettre=0) then lettre:=1;
          if (key='m') and (lettre=1) then lettre:=2;
          if (key='d') and (lettre=2) then lettre:=3;
          if (key='t') and (lettre=3) then lettre:=4;
          if (key='r') and (lettre=4) then lettre:=5;
          if (key='i') and (lettre=5) then lettre:=6;
          if (key='c') and (lettre=6) then lettre:=7;
          if (key='h') and (lettre=7) then lettre:=8;
          if (key='e') and (lettre=8) then
          begin
               lettre:=0;
               jouerSon(SND_CODE);
               triche:=not(triche);
               if triche then tricheur:=true
               else
               begin
                    invincible:=false;
                    all_objets:=false;
                    afficherTout:=false;
                    formProprietes.pagecontrol1.activepage:=formProprietes.tabsheet1;
               end;
               Chargeruntableau1.Visible:=tricheur;
          end;

     end
     else
     begin
          if key='z' then begin gloutoman[2].direction:=2; gloutoman[2].arret:=false; end
          else if key='d' then begin gloutoman[2].direction:=1; gloutoman[2].arret:=false; end
          else if key='s' then begin gloutoman[2].direction:=4; gloutoman[2].arret:=false; end
          else if key='q' then begin gloutoman[2].direction:=3; gloutoman[2].arret:=false; end;
          if key='p' then
          begin
               pause:=not(pause);
               pause1.visible:=pause;
          end
          else if (key='0') then
          begin
               if(gloutoman[1].objetSelected=0)and(objet[0,1].quantite>0) and gloutoman[1].present then
               begin
                    case tableau[gloutoman[1].x,gloutoman[1].y] of
                    0,8..12,19,20,24..27,32:begin
                    jouerSon(SND_POP);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=19;
                    dec(objet[0,1].quantite);
                    gloutoman[1].arret:=true;
                    end;
                    end;
               end;
               if (gloutoman[1].objetSelected=1)and(objet[1,1].quantite>0)and(gloutoman[1].vie<4) then
               begin
                    dec(objet[1,1].quantite);
                    inc(gloutoman[1].vie);
               end;
               if (gloutoman[1].objetSelected=2) then
          begin
               if not(dynamite[1].active)and not(bombe[1].active)and(objet[2,1].quantite>0) then
               begin
                    case tableau[gloutoman[1].x,gloutoman[1].y] of
                    0,8..12,19,20,24..27,29,32:begin
                    dec(objet[2,1].quantite);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=27;
                    dynamite[1].x:=gloutoman[1].x;
                    dynamite[1].y:=gloutoman[1].y;
                    dynamite[1].active:=true;
                    end;
               end;
               end
               else if dynamite[1].active then
               begin
                    explosion[1].x:=dynamite[1].x;
                    explosion[1].y:=dynamite[1].y;
                    explosion[1].active:=true;
                    tableau[dynamite[1].x,dynamite[1].y]:=0;
                    explosion_bombe(1);
               end;
          end;
          if (gloutoman[1].objetSelected=3) then
          begin
               if not(dynamite[1].active)and not(bombe[1].active)and(objet[3,1].quantite>0) then
               begin
                    case tableau[gloutoman[1].x,gloutoman[1].y] of
                    0,8..12,19,20,24..27,29,32:begin
                    dec(objet[3,1].quantite);
                    tableau[gloutoman[1].x,gloutoman[1].y]:=32;
                    bombe[1].x:=gloutoman[1].x;
                    bombe[1].y:=gloutoman[1].y;
                    bombe[1].active:=true;
                    end;
               end;
               end
               else if bombe[1].active then
               begin
                    explosion[1].x:=bombe[1].x;
                    explosion[1].y:=bombe[1].y;
                    explosion[1].active:=true;
                    tableau[bombe[1].x,bombe[1].y]:=0;
                    explosion_bombe(1);
               end;
          end;
          end;
     end;
end;

//
//  ++  Affichage des messages  ++
//
procedure TFormMain.affichageMessage(texte : String; typeAffichageMessage : Integer);
var
  x, y : Integer;
begin
  labelPoints.Visible := False;
  sleep(500);
  if animFermeture = False then
  begin
    animX := 0;
    animY := 0;
    animFermeture := True;
  end;

  case typeAffichageMessage of
    0:begin
      jouerSon(SND_GAGNE);
      typeMessage := False;
    end;
    1:begin
      jouerSon(SND_PERDU);
      typeMessage := False;
    end;
    2:begin
      jouerSon(SND_TUT);
      typeMessage := True;
    end;
  end;
  actionMessage := typeAffichageMessage;
  PanelMessages.Visible := True;

  // Affichage du panneau des messages
  imageFond.canvas.brush.color := couleur_fond;
  imageFond.canvas.pen.color := couleur_fond;
  imageFond.canvas.rectangle(0,0,282,178);
  for x := 1 to 35 do
  begin
    imageListMurs.draw(imageFond.canvas,x*8-8+1,1*8-8+1,trunc(random(6)));
    imageListMurs.draw(imageFond.canvas,x*8-8+1,22*8-8+1,trunc(random(6)));
  end;
  for y := 1 to 22 do
  begin
    imageListMurs.draw(imageFond.canvas,1*8-8+1,y*8-8+1,trunc(random(6)));
    imageListMurs.draw(imageFond.canvas,35*8-8+1,y*8-8+1,trunc(random(6)));
  end;
  Message.Caption := texte;
  if not(typeMessage) then
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

procedure TFormMain.ButtonOKClick(Sender: TObject);
begin
  case actionMessage of
    0:begin
      animFermeture := False;
      pause := False;
      PanelMessages.Visible := False;
      if not(one) then
      begin
        if level<nb_level then inc(level)
        else if (level=nb_level) then gagner;
        Debut_tableau;
      end
      else Gagner;
    end;
    1:begin
      affichageMessage(MESSAGE7, 2);
    end;
    2:begin
      animFermeture := False;
      pause := False;
      PanelMessages.Visible := False;
      Nouvelle_partie;
    end;
  end;
end;

procedure TFormMain.ButtonNonClick(Sender: TObject);
begin
  animFermeture := False;
  pause := False;
  PanelMessages.Visible := False;
  Close;
end;


//
//  **********************
//  **  Gestion du jeu  **
//  **********************
//
procedure TFormMain.nouvelle_partie;
var
  i : Integer;
begin
     one:=false;
     if multijoueurs then formMain.height:=537
     else formMain.height:=512;
     for i := 1 to 2 do
     begin
         objet[0,i].quantite:=4;
         gloutoman[i].score:=0;
         gloutoman[i].vie:=4;
     end;
     level:=1;
     debut_tableau;
end;

//
//  ++  Initialisation tableau  ++
//
procedure TFormMain.debut_tableau;
var
   x, y, i, o : Integer;
begin
     for x:=1 to NB_COLONNES do
     for y:=1 to NB_LIGNES do
         tableau[x,y]:=0;

     for x:=1 to NB_COLONNES do
     begin
          tableau[x,1]:=couleur_mur;
          tableau[x,NB_LIGNES]:=couleur_mur;
     end;
     for y:=1 to NB_LIGNES do
     begin
          tableau[1,y]:=couleur_mur;
          tableau[NB_COLONNES,y]:=couleur_mur;
     end;
     nb_fantomes:=0;
     for i:=1 to 2 do
     begin
          gloutoman[i].present:=false;
          gloutoman[i].x:=0;
          gloutoman[i].y:=0;
          gloutoman[i].pixelX:=gloutoman[1].x*8;
          gloutoman[i].pixelY:=gloutoman[1].y*8;
          gloutoman[i].etat:=0;
          gloutoman[i].positionInitX:=gloutoman[i].x;
          gloutoman[i].positionInitY:=gloutoman[i].y;
          gloutoman[i].direction:=1;
          gloutoman[i].arret:=true;
          gloutoman[i].etat:=0;
          scoreDebutNiveau[i] := gloutoman[i].score;
     end;
     for i:=1 to 10 do
     begin
          fantome[i].present:=false;
          fantome[i].x:=0;
          fantome[i].y:=0;
          fantome[i].pixelX:=fantome[i].x*8;
          fantome[i].pixelY:=fantome[i].y*8;
          fantome[i].etat:=0;
          fantome[i].couleur:=1;
          fantome[i].dureeDirection:=0;
          fantome[i].directionEnCours:=0;
     end;

     for i:=1 to 5 do
     begin
          bouton[i].present:=false;
          bouton[i].x:=0;
          bouton[i].y:=0;
          bouton[i].lien:=0;
          tempo[i].present:=false;
          tempo[i].x:=0;
          tempo[i].y:=0;
          tempo[i].valeur:=0;
          for o:=1 to 10 do
              tempo[i].lien[o]:=0;
          teleporteur[i].present:=false;
          teleporteur[i].x:=0;
          teleporteur[i].y:=0;
          teleporteur[i].lien:=0;
          cle[i].present:=false;
          cle[i].x:=0;
          cle[i].y:=0;
          cle[i].lien:=0;
     end;
     for i:=1 to 10 do
     begin
          porte[i].present:=false;
          porte[i].x:=0;
          porte[i].y:=0;
          porte[i].tempoActive:=false;
          porte[i].tempoFermeture:=0;
          porte[i].image_courante:=1;
     end;

     nb_cerises:=0;
     nb_bananes:=0;
     nb_bouton:=0;
     nb_tempo:=0;
     nb_porte:=0;
     nb_telep:=0;
     nb_cle:=0;

     scenario_cerises:=true;
     scenario_points:=false;
     recup_points:=0;
     scenario_objet:=false;
     recup_objet:=0;
     nom_image:='';
     temps_timer:=0;

     if not(one) then
     begin
          //nomfich:='level'+inttostr(level)+'.gty';
          //charger_tableau(ch_tableaux+nomfich);
          charger_tableau_resource(level);
     end
     else
     begin
          level:=0;
          charger_tableau(nomfich);
     end;
end;

//
//  ++  Chargement tableau Resources  ++
//
procedure TFormMain.charger_tableau_resource(level : Integer);
var
   niveauResource : TResourceStream;
   x, y, i, o, ligne : Integer;
   nomResource : String;
begin
    try
      nomResource := 'NIVEAU' + intToStr(level);
      lectureTableau.Clear;
      niveauResource := TResourceStream.Create(HInstance, nomResource, 'TEXT');
      lectureTableau.Lines.LoadFromStream(niveauResource);
    finally
      niveauResource.Free;
    end;
    ligne := 0;
    with lectureTableau do
    begin
      couleur_fond := strToInt(Lines[ligne]); inc(ligne);
      gloutoman[1].present:=strToBool(Lines[ligne]); inc(ligne);
      gloutoman[1].x := strToInt(Lines[ligne]); inc(ligne);
      gloutoman[1].y := strToInt(Lines[ligne]); inc(ligne);
      gloutoman[1].pixelX:=gloutoman[1].x*8;
      gloutoman[1].pixelY:=gloutoman[1].y*8;
      gloutoman[1].positionInitX:=gloutoman[1].x;
      gloutoman[1].positionInitY:=gloutoman[1].y;
      gloutoman[1].direction:=1;
      gloutoman[1].arret:=true;
      gloutoman[1].etat:=0;
      gloutoman[2].present:=strToBool(Lines[ligne]); inc(ligne);
      gloutoman[2].x := strToInt(Lines[ligne]); inc(ligne);
      gloutoman[2].y := strToInt(Lines[ligne]); inc(ligne);
      gloutoman[2].pixelX:=gloutoman[2].x*8;
      gloutoman[2].pixelY:=gloutoman[2].y*8;
      gloutoman[2].positionInitX:=gloutoman[2].x;
      gloutoman[2].positionInitY:=gloutoman[2].y;
      gloutoman[2].direction:=1;
      gloutoman[2].arret:=true;
      gloutoman[2].etat:=0;
      for i:=1 to 10 do
      begin
          fantome[i].present:=StrToBool(Lines[ligne]); inc(ligne);
          fantome[i].x := strToInt(Lines[ligne]); inc(ligne);
          fantome[i].y := strToInt(Lines[ligne]); inc(ligne);
          fantome[i].pixelX:=fantome[i].x*8;
          fantome[i].pixelY:=fantome[i].y*8;
          fantome[i].dureeDirection:=trunc(random(40)+24);
          fantome[i].directionEnCours:=0;
          fantome[i].couleur := strToInt(Lines[ligne]); inc(ligne);
          if fantome[i].present then inc(nb_fantomes,1);
      end;
     for x:=1 to 80 do
     for y:=1 to 50 do
     begin
          tableau[x,y] := strToInt(Lines[ligne]); inc(ligne);
          if tableau[x,y]=35 then
          begin
            lien_tableau := Lines[ligne];
            inc(ligne);
          end;
     end;
     for i:=1 to 5 do
     begin
          bouton[i].present:= strToBool(Lines[ligne]); inc(ligne);
          if bouton[i].present then inc(nb_bouton,1);
          bouton[i].x := strToInt(Lines[ligne]); inc(ligne);
          bouton[i].y := strToInt(Lines[ligne]); inc(ligne);
          bouton[i].lien := strToInt(Lines[ligne]); inc(ligne);
     end;
     for i:=1 to 5 do
     begin
          tempo[i].present := strToBool(Lines[ligne]); inc(ligne);
          if tempo[i].present then inc(nb_tempo,1);
          tempo[i].x := strToInt(Lines[ligne]); inc(ligne);
          tempo[i].y := strToInt(Lines[ligne]); inc(ligne);
          tempo[i].valeur := strToInt(Lines[ligne]); inc(ligne);
          lasttickcount[30+i,1]:=getTickCount;
          for o:=1 to 10 do
          begin
              tempo[i].lien[o] := strToInt(Lines[ligne]);
              inc(ligne);
          end;
     end;
     for i:=1 to 5 do
     begin
          teleporteur[i].present := strToBool(Lines[ligne]); inc(ligne);
          if teleporteur[i].present then inc(nb_telep,1);
          teleporteur[i].x := strToInt(Lines[ligne]); inc(ligne);
          teleporteur[i].y := strToInt(Lines[ligne]); inc(ligne);
          teleporteur[i].lien := strToInt(Lines[ligne]); inc(ligne);
     end;
     for i:=1 to 10 do
     begin
          porte[i].present := StrToBool(Lines[ligne]); inc(ligne);
          porte[i].x := strToInt(Lines[ligne]); inc(ligne);
          porte[i].y := strToInt(Lines[ligne]); inc(ligne);
          if porte[i].present then
          begin
            inc(nb_porte,1);
            porte[i].fermee:=true;
            if tableau[porte[i].x,porte[i].y]=18 then porte[i].modele:=true else porte[i].modele:=false;
          end;
          porte[i].tempoFermeture := strToInt(Lines[ligne]); inc(ligne);
     end;
     for i:=1 to 5 do
     begin
          cle[i].present := strToBool(Lines[ligne]); inc(ligne);
          if cle[i].present then inc(nb_cle,1);
          cle[i].x := strToInt(Lines[ligne]); inc(ligne);
          cle[i].y := strToInt(Lines[ligne]); inc(ligne);
          cle[i].lien := strToInt(Lines[ligne]); inc(ligne);
     end;
     scenario_cerises := strToBool(Lines[ligne]); inc(ligne);
     scenario_points := strToBool(Lines[ligne]); inc(ligne);
     recup_points := strToInt(Lines[ligne]); inc(ligne);
     scenario_objet := strToBool(Lines[ligne]); inc(ligne);
     recup_objet := strToInt(Lines[ligne]);
    end;

    gloutoman[2].present:=multijoueurs;

    animOuverture := True;
    animX := 0;
    animY := 0;

    dessiner;
end;

//
//  ++  Chargement tableau GTY  ++
//
procedure TFormMain.charger_tableau(nom_fichier:string);
var
   f1 : Textfile;
   x, y, i, o : Integer;
   s : String;
begin
     assignfile(f1,nom_fichier);
     reset(f1);
     readln(f1,couleur_fond);
     readln(f1,s);
     gloutoman[1].present:=StrToBool(s);
     readln(f1,gloutoman[1].x);
     readln(f1,gloutoman[1].y);
     gloutoman[1].pixelX:=gloutoman[1].x*8;
     gloutoman[1].pixelY:=gloutoman[1].y*8;
     gloutoman[1].positionInitX:=gloutoman[1].x;
     gloutoman[1].positionInitY:=gloutoman[1].y;
     gloutoman[1].direction:=1;
     gloutoman[1].arret:=true;
     gloutoman[1].etat:=0;
     readln(f1,s);
     gloutoman[2].present:=StrToBool(s);
     readln(f1,gloutoman[2].x);
     readln(f1,gloutoman[2].y);
     gloutoman[2].pixelX:=gloutoman[2].x*8;
     gloutoman[2].pixelY:=gloutoman[2].y*8;
     gloutoman[2].positionInitX:=gloutoman[2].x;
     gloutoman[2].positionInitY:=gloutoman[2].y;
     gloutoman[2].direction:=1;
     gloutoman[2].arret:=true;
     gloutoman[2].etat:=0;
     for i:=1 to 10 do
     begin
          readln(f1,s);
          fantome[i].present:=StrToBool(s);
          readln(f1,fantome[i].x);
          readln(f1,fantome[i].y);
          fantome[i].pixelX:=fantome[i].x*8;
          fantome[i].pixelY:=fantome[i].y*8;
          fantome[i].dureeDirection:=trunc(random(40)+24);
          fantome[i].directionEnCours:=0;
          readln(f1,fantome[i].couleur);
          if fantome[i].present then inc(nb_fantomes,1);
     end;
     for x:=1 to 80 do
     for y:=1 to 50 do
     begin
          readln(f1,tableau[x,y]);
          if tableau[x,y]=35 then readln(f1,lien_tableau);
     end;

     for i:=1 to 5 do
     begin
          readln(f1,s);
          bouton[i].present:=StrToBool(s);
          if bouton[i].present then inc(nb_bouton,1);
          readln(f1,bouton[i].x);
          readln(f1,bouton[i].y);
          readln(f1,bouton[i].lien);
     end;
     for i:=1 to 5 do
     begin
          readln(f1,s);
          tempo[i].present:=StrToBool(s);
          if tempo[i].present then inc(nb_tempo,1);
          readln(f1,tempo[i].x);
          readln(f1,tempo[i].y);
          readln(f1,tempo[i].valeur);
          lasttickcount[30+i,1]:=getTickCount;
          for o:=1 to 10 do
              readln(f1,tempo[i].lien[o]);
     end;
     for i:=1 to 5 do
     begin
          readln(f1,s);
          teleporteur[i].present:=StrToBool(s);
          if teleporteur[i].present then inc(nb_telep,1);
          readln(f1,teleporteur[i].x);
          readln(f1,teleporteur[i].y);
          readln(f1,teleporteur[i].lien);
     end;
     for i:=1 to 10 do
     begin
          readln(f1,s);
          porte[i].present:=StrToBool(s);
          readln(f1,porte[i].x);
          readln(f1,porte[i].y);
          if porte[i].present then
          begin
            inc(nb_porte,1);
            porte[i].fermee:=true;
            if tableau[porte[i].x,porte[i].y]=18 then porte[i].modele:=true else porte[i].modele:=false;
          end;
          readln(f1,porte[i].tempoFermeture);
     end;
     for i:=1 to 5 do
     begin
          readln(f1,s);
          cle[i].present:=StrToBool(s);
          if cle[i].present then inc(nb_cle,1);
          readln(f1,cle[i].x);
          readln(f1,cle[i].y);
          readln(f1,cle[i].lien);
     end;
     readln(f1,s);
     scenario_cerises:=StrToBool(s);
     readln(f1,s);
     scenario_points:=StrToBool(s);
     readln(f1,recup_points);
     readln(f1,s);
     scenario_objet:=StrToBool(s);
     readln(f1,recup_objet);
     closefile(f1);
     gloutoman[2].present:=multijoueurs;

     animOuverture := True;
     animX := 0;
     animY := 0;

     dessiner;
end;

//
//  ++  Gestion des déplacements et animations  ++
//
procedure TFormMain.TimerPrincipalTimer(Sender: TObject);
var
   tickcount, u, n, numTempo, numLienTempo, numPorte : Integer;
begin
     tickcount:=gettickcount;

     // Rafraichissement de l'affichage
     if (tickcount-lasttickcount[1,1]>=refresh) and (not(pause) or animFermeture or animOuverture) then
     begin
          lasttickcount[1,1]:=tickcount;
          dessiner;
     end;

     // Déplacement des fantômes
     if (gloutoman[1].etat=0) and (gloutoman[2].etat=0) then coef_vitesse_fantome := 1 else coef_vitesse_fantome := 0.7;

     if (tickcount-lasttickcount[2,1]>=vitesse_fantome*coef_vitesse_fantome) and not(pause) then
     begin
     lasttickcount[2,1]:=tickcount;
     for n:=1 to 10 do
     begin
          if fantome[n].present then
           begin
                if fantome[n].directionEnCours=0 then
                begin
                  fantome[n].direction:=trunc(random(4)+1);
                end;
                if temps_timer=0 then deplacer_fantome(n);
                inc(fantome[n].directionEnCours);
                if fantome[n].directionEnCours=fantome[n].dureeDirection then
                begin
                  fantome[n].directionEnCours:=0;
                  fantome[n].dureeDirection:=trunc(random(48)+48);  // Détermine la direction des fantômes
                end;
                test_collision;

                if fantome[n].reincarné then
                begin
                  jouerSon(SND_REINCARN);
                  fantome[n].reincarné := False;
                end;

          end;
     end;
     end;

     // Déplacements des GloutoMan
     if (tickcount-lasttickcount[3,1]>=gloutoman[1].vitesse) and not(pause) then
     begin
          if (gloutoman[1].present) then
               begin
                    lasttickcount[3,1]:=tickcount;
                    if not(gloutoman[1].pause) then
                    begin
                         deplacer_gloutoman(1);
                         verif_case(1);
                    end;
          end;
     end;
     if (tickcount-lasttickcount[3,2]>=gloutoman[2].vitesse) and not(pause) then
     begin
          if (gloutoman[2].present) then
               begin
                    lasttickcount[3,2]:=tickcount;
                    if not(gloutoman[2].pause) then
                    begin
                         deplacer_gloutoman(2);
                         verif_case(2);
                    end;
          end;
     end;

     // Animations des objets
     if animations then
     begin
         passage.Animate;
         viesupp.Animate;
         timer.Animate;
         bonus.Animate;
         telep.Animate;

         for u := 1 to 2 do
         begin
            dynamite[u].Animate;
            bombe[u].Animate;
         end;
     end;

     // Animations du Timer d'arrêt des fantômes
     if (tickcount-lasttickcount[7,1]>=1000) and not(pause) and (temps_timer>0) then
     begin
          lasttickcount[7,1]:=tickcount;
          temps_timer:=temps_timer-1;
     end;

     // Animations des portes
     if (tickcount-lasttickcount[8,1]>=vitesse_animations/3) and not(pause) then
     begin
          lasttickcount[8,1]:=tickcount;
          for u:=1 to 10 do
          begin
            if porte[u].present then
            begin
              if porte[u].modele=false then
              begin
                if porte[u].fermee then
                begin
                  if porte[u].image_courante=0 then jouerSon(SND_TUT);
                  inc(porte[u].image_courante)
                end
                else
                begin
                  if porte[u].image_courante<>0 then jouerSon(SND_TUT);
                  porte[u].image_courante:=0;
                end;
                if porte[u].image_courante=NBI_PORTE then porte[u].image_courante:=1;
              end
              else
              begin
                if (porte[u].fermee)and not(porte[u].fermeture) then porte[u].image_courante:=NBI_PORTE2-1
                else if porte[u].ouverture then
                begin
                  if porte[u].image_courante=NBI_PORTE2-1 then jouerSon(SND_PORTE);
                  if porte[u].image_courante>0 then porte[u].image_courante:=porte[u].image_courante-1
                  else porte[u].ouverture:=false;
                end
                else if porte[u].fermeture then
                begin
                  if porte[u].image_courante=0 then jouerSon(SND_PORTE);
                  if porte[u].image_courante<NBI_PORTE2-1 then porte[u].image_courante:=porte[u].image_courante+1
                  else porte[u].fermeture:=false;
                end;
              end;

            end;
          end;
     end;

     // Animations des explosions
     if (tickcount-lasttickcount[10,1]>=vitesse_animations/10) and not(pause) then
     begin
          lasttickcount[10,1]:=tickcount;
          if explosion[1].active then inc(explosion[1].image_courante) else explosion[1].image_courante:=0;
          if explosion[1].image_courante=NBI_EXPLOSION then
          begin
               explosion[1].image_courante:=1;
               explosion[1].active:=false;
          end;
     end;
     if (tickcount-lasttickcount[10,2]>=vitesse_animations/10) and not(pause) then
     begin
          lasttickcount[10,2]:=tickcount;
          if explosion[2].active then inc(explosion[2].image_courante) else explosion[2].image_courante:=0;
          if explosion[2].image_courante=NBI_EXPLOSION then
          begin
               explosion[2].image_courante:=1;
               explosion[2].active:=false;
          end;
     end;

     // Gestion des temporisations
     for numTempo := 1 to 5 do
     begin
        if tempo[numTempo].present then
        begin
          if (tickcount-lasttickcount[30+numTempo,1]>=tempo[numTempo].valeur*1000) and not(pause) then
          begin
            for numLienTempo := 1 to 10 do
            begin
              porte[tempo[numTempo].lien[numLienTempo]].fermee:=false;
              porte[tempo[numTempo].lien[numLienTempo]].ouverture:=true;
              porte[tempo[numTempo].lien[numLienTempo]].tempoActive:=true
            end;
          end;
        end;
     end;

     // Gestion de la refermeture des portes
     for numPorte := 1 to 10 do
     begin
      if (porte[numPorte].present)and(porte[numPorte].fermee=false) and(porte[numPorte].tempoActive=false) then
      begin
        if (tickcount-lasttickcount[40+numPorte,1]>=porte[numPorte].tempoFermeture*1000) and not(pause) then
        begin
          porte[numPorte].fermee:=true;
          porte[numPorte].fermeture:=true;
          porte[numPorte].ouverture:=false;
         end;
      end;

     end;

     // Animations des points récoltés
     if (tickcount-lasttickcount[54,1]>=700) and not(pause) then
     begin
      lasttickcount[54,1]:=tickcount;
      labelPoints.Visible:=false;
     end;

     // Animations de la Pause
     if (tickcount-lasttickcount[55,1]>=350) and pause then
     begin
          lasttickcount[55,1]:=tickcount;
          if pause1.font.color=clyellow then pause1.font.color:=cllime
          else if pause1.font.color=cllime then pause1.font.color:=clblue
          else if pause1.font.color=clblue then pause1.font.color:=clred
          else if pause1.font.color=clred then pause1.font.color:=clyellow;
     end;
end;

//
//  ++  Gestion des explosions  ++
//
procedure TFormMain.explosion_bombe(n:integer);
var
   i, j, u : Integer;
begin
//
  jouerSon(SND_EXPLOSION);
  if dynamite[n].active then
  begin
       lasttickcount[10,n]:=getTickCount;
       for i:=-3 to 3 do
       for j:=-3 to 3 do
       begin
            if ((j=-3)and(i>-3)and(i<3))or((j=3)and(i>-3)and(i<3))or((j>=-2)and(j<=2)) then
            begin
                case tableau[dynamite[n].x+i,dynamite[n].y+j] of
                16:tableau[dynamite[n].x+i,dynamite[n].y+j]:=0;
                end;
                for u:=1 to 10 do
                begin
                     if (fantome[u].x=dynamite[n].x+i)and(fantome[u].y=dynamite[n].y+j)then
                     begin
                          fantome[u].etat:=1;
                          lasttickcount[u+20,1]:=gettickcount;
                     end;
                end;
                for u:=1 to 2 do
                begin
                     if (gloutoman[u].x=dynamite[n].x+i)and(gloutoman[u].y=dynamite[n].y+j)then
                     begin
                          dec(gloutoman[u].vie);
                          gloutoman[u].x:=gloutoman[u].positionInitX;
                          gloutoman[u].y:=gloutoman[u].positionInitY;
                          gloutoman[u].pixelX:=gloutoman[u].x*8;
                          gloutoman[u].pixelY:=gloutoman[u].y*8;
                          gloutoman[u].direction:=1;
                          gloutoman[u].arret:=true;
                     end;
                end;
            end;
       end;
       dynamite[n].active:=false;
  end
  else if bombe[n].active then
  begin
       lasttickcount[10,n]:=getTickCount;
       for i:=-5 to 5 do
       for j:=-5 to 5 do
       begin
            if ((j=-5)and(i>-4)and(i<4))or((j=5)and(i>-4)and(i<4))or((j=-4)and(i>-5)and(i<5))or((j=4)and(i>-5)and(i<5))or((j>=-3)and(j<=3)) then
            begin
                case tableau[bombe[n].x+i,bombe[n].y+j] of
                1..16:if (bombe[n].x+i>1)and(bombe[n].x+i<NB_COLONNES) and (bombe[n].y+j>1)and(bombe[n].y+j<NB_LIGNES) then tableau[bombe[n].x+i,bombe[n].y+j]:=0;
                19, 22..25, 27, 30, 33..34, 37..40:tableau[bombe[n].x+i,bombe[n].y+j]:=0;
                end;
                for u:=1 to 10 do
                begin
                     if (fantome[u].x=bombe[n].x+i)and(fantome[u].y=bombe[n].y+j)then
                     begin
                          fantome[u].etat:=1;
                          lasttickcount[u+20,1]:=gettickcount;
                     end;
                end;
                for u:=1 to 2 do
                begin
                     if (gloutoman[u].x=bombe[n].x+i)and(gloutoman[u].y=bombe[n].y+j)then
                     begin
                          dec(gloutoman[u].vie);
                          gloutoman[u].x:=gloutoman[u].positionInitX;
                          gloutoman[u].y:=gloutoman[u].positionInitY;
                          gloutoman[u].pixelX:=gloutoman[u].x*8;
                          gloutoman[u].pixelY:=gloutoman[u].y*8;
                          gloutoman[u].direction:=1;
                          gloutoman[u].arret:=true;
                     end;
                end;
            end;
       end;
       bombe[n].active:=false;
  end;
end;

//
//  ++  Affichage des dessins  ++
//
procedure TFormMain.dessiner;
var
   x, y, i, u : Integer;
begin
     zoneJeux.canvas.brush.color:=couleur_fond;
     zoneJeux.canvas.pen.color:=couleur_fond;
     zoneJeux.canvas.rectangle(0,0,640,400);

     u:=0;

  //  Dessin du tableau
  for x:=1 to NB_COLONNES do
  for y:=1 to NB_LIGNES do
  begin
       case tableau[x,y] of
            1..15:imagelistMurs.draw(zoneJeux.canvas,x*8-8,y*8-8,tableau[x,y]-1);
            16:imagelistMurs.draw(zoneJeux.canvas,x*8-8,y*8-8,COUL_MURF);
            17:begin
              for i:=1 to 10 do
              begin
                if (porte[i].x=x) and (porte[i].y=y) then u:=i;
              end;
                if (tableau[x-2,y]>=1) and (tableau[x-2,y]<=15) then
                  imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PORTEV+porte[u].image_courante)
                else if (tableau[x,y+2]>=1) and (tableau[x,y+2]<=15) then
                  imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PORTEH+porte[u].image_courante)
                else imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_ERREUR);
                  if (tableau[x-2,y]>=1) and (tableau[x-2,y]<=15) and (tableau[x,y+2]>=1) and (tableau[x,y+2]<=15)then
                    imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_ERREUR);
            end;
            18:begin
              for i:=1 to 10 do
              begin
                if (porte[i].x=x) and (porte[i].y=y) then u:=i;
              end;
                if (tableau[x+2,y]>=1) and (tableau[x+2,y]<=15) then
                  imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PORTECOULV+porte[u].image_courante)
                else if (tableau[x,y-2]>=1) and (tableau[x,y-2]<=15) then
                  imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PORTECOULH+porte[u].image_courante)
                else imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_ERREUR);
                  if (tableau[x+2,y]>=1) and (tableau[x+2,y]<=15) and (tableau[x,y-2]>=1) and (tableau[x,y-2]<=15)then
                    imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_ERREUR);
            end;
            19:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_AIL);
            20:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_CERISE);
            21:if multijoueurs and adversaire then imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_BANANE);
            22:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_POINT);
            23:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PIECE);
            24:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_POMME);
            25:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_FLEUR);
            26:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_MULTIPLICATEUR+bonus.image_courante);
            27:if afficherTout then imagelistMurs.draw(zoneJeux.canvas,x*8-8,y*8-8,IMG_INVISIBLE);
            28:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_BOUTON);
            //29:imageListObjetsFixes.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_TEMPO); // Uniquement dans le programme Editeur
            30:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PACGOM);
            31:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_COLLE);
            32:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PATINOIRE);
            33:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_GLACE);
            34:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_TIMER+timer.image_courante);
            35:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_PASSAGE+passage.image_courante);
            36:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_TELEPORTEUR+telep.image_courante);
            37:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_VIESUPP+viesupp.image_courante);
            38:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_SECOURS);
            39:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_GOUSSE);
            40:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_POISON);
            //41:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_CLEF);
            42:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_DYNAMITE+dynamite[1].image_courante);
            43:imageListObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,IMG_BOMBE+bombe[1].image_courante);
            //44..48:imagelistObjets.draw(zoneJeux.canvas,x*8-16,y*8-16,tableau[x,y]-20);
       end;
  end;

  // Affichage des fantômes
  for i:=1 to nb_fantomes do fantome[i].Afficher(zoneJeux, (gloutoman[1].etat>0)or(gloutoman[2].etat>0));

  // Affichage des GloutoMan
  for i:=1 to 2 do gloutoman[i].Afficher(zoneJeux);

  // Affichage des explosions
  if explosion[1].active then imageListExplosion.Draw(zoneJeux.Canvas,explosion[1].x*8-40,explosion[1].y*8-40,IMG_EXPLOSION+explosion[1].image_courante);
  if explosion[2].active then imageListExplosion.Draw(zoneJeux.Canvas,explosion[2].x*8-40,explosion[2].y*8-40,IMG_EXPLOSION+explosion[2].image_courante);

  // Affichage du score
  afficher_score;

  // Animation d'ouverture du tableau
  if animOuverture then
  begin
     if animX<=320 then
      begin
          inc(animX,8);
          inc(animY,5);
          zoneJeux.canvas.rectangle(animX,animY,640-animX,400-animY);
      end
      else animOuverture:=false;
  end;

  // Animation de fermeture du tableau
  if animFermeture then
    begin
       if animX<=320 then
        begin
            inc(animX,8);
            inc(animY,5);
            zoneJeux.canvas.rectangle(320-animX,200-animY,320+animX,200+animY);
        end
        else zoneJeux.canvas.rectangle(0,0,640,400);
    end;

end;

//
//  ++  Deplacement des fantomes  ++
//
procedure TFormMain.deplacer_fantome(n:integer);
var
   pixelX, pixelY : Integer;
   u, i : Integer;
begin
  u:=0;
  pixelX:=fantome[n].pixelX;
  pixelY:=fantome[n].pixelY;

  case fantome[n].direction of

      1:begin
        if ((tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]=0)or(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]>15)and(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]<>19))and((tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+0)/8)]=0)or(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+0)/8)]>15)and(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+0)/8)]<>19))and((tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+BORD_F_BAS-avancePixels)/8)]=0)or(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+BORD_F_BAS-avancePixels)/8)]>15)and(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+BORD_F_HAUT+avancePixels)/8)]<>19)) then
        begin
          if (tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+0)/8)]=17)or(tableau[round((pixelX+BORD_F_DROITE)/8),round((pixelY+0)/8)]=18) then
          begin
            for i:=1 to 10 do
            begin
              if (porte[i].x=round((pixelX+BORD_F_DROITE)/8)) and (porte[i].y=round((pixelY+0)/8)) then u:=i;
            end;
            if not(porte[u].fermee) then pixelX:=pixelX+avancePixels;
          end
          else pixelX:=pixelX+avancePixels;
        end
        else fantome[n].directionEnCours:=fantome[n].dureeDirection-1;
        fantome[n].pixelX:=pixelX;
        fantome[n].x:=round(pixelX/8);
      end;

      2:begin
        if ((tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]=0)or(tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]>15)and(tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]<>19))and((tableau[round((pixelX+0)/8),round((pixelY-BORD_F_HAUT)/8)]=0)or(tableau[round((pixelX+0)/8),round((pixelY-BORD_F_HAUT)/8)]>15)and(tableau[round((pixelX+0)/8),round((pixelY-BORD_F_HAUT)/8)]<>19))and((tableau[round((pixelX+BORD_F_DROITE-avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]=0)or(tableau[round((pixelX+BORD_F_DROITE-avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]>15)and(tableau[round((pixelX+BORD_F_GAUCHE-avancePixels)/8),round((pixelY-BORD_F_HAUT)/8)]<>19)) then
        begin
          if (tableau[round((pixelX+0)/8),round((pixelY-BORD_F_HAUT)/8)]=17)or(tableau[round((pixelX+0)/8),round((pixelY-BORD_F_HAUT)/8)]=18) then
          begin
            for i:=1 to 10 do
            begin
              if (porte[i].x=round((pixelX+0)/8)) and (porte[i].y=round((pixelY-BORD_F_HAUT)/8)) then u:=i;
            end;
            if not(porte[u].fermee) then pixelY:=pixelY-avancePixels;
          end
          else pixelY:=pixelY-avancePixels;
        end
        else fantome[n].directionEnCours:=fantome[n].dureeDirection-1;
        fantome[n].pixelY:=pixelY;
        fantome[n].y:=round(pixelY/8);
      end;

      3:begin
        if ((tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]=0)or(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]>15)and(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY-BORD_F_HAUT+avancePixels)/8)]<>19))and((tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+0)/8)]=0)or(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+0)/8)]>15)and(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+0)/8)]<>19))and((tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+BORD_F_BAS-avancePixels)/8)]=0)or(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+BORD_F_BAS-avancePixels)/8)]>15)and(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+BORD_F_BAS-avancePixels)/8)]<>19)) then
        begin
          if (tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+0)/8)]=17)or(tableau[round((pixelX-BORD_F_GAUCHE)/8),round((pixelY+0)/8)]=18) then
          begin
            for i:=1 to 10 do
            begin
              if (porte[i].x=round((pixelX-BORD_F_GAUCHE)/8)) and (porte[i].y=round((pixelY+0)/8)) then u:=i;
            end;
            if not(porte[u].fermee) then pixelX:=pixelX-avancePixels;
          end
          else pixelX:=pixelX-avancePixels;
        end
        else fantome[n].directionEnCours:=fantome[n].dureeDirection-1;
        fantome[n].pixelX:=pixelX;
        fantome[n].x:=round(pixelX/8);
      end;

      4:begin
        if ((tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]=0)or(tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]>15)and(tableau[round((pixelX-BORD_F_GAUCHE+avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]<>19))and((tableau[round((pixelX+0)/8),round((pixelY+BORD_F_BAS)/8)]=0)or(tableau[round((pixelX+0)/8),round((pixelY+BORD_F_BAS)/8)]>15)and(tableau[round((pixelX+0)/8),round((pixelY+BORD_F_BAS)/8)]<>19))and((tableau[round((pixelX+BORD_F_DROITE-avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]=0)or(tableau[round((pixelX+BORD_F_DROITE-avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]>15)and(tableau[round((pixelX+BORD_F_DROITE-avancePixels)/8),round((pixelY+BORD_F_BAS)/8)]<>19)) then
        begin
          if (tableau[round((pixelX+0)/8),round((pixelY+BORD_F_BAS)/8)]=17)or(tableau[round((pixelX+0)/8),round((pixelY+BORD_F_BAS)/8)]=18) then
          begin
            for i:=1 to 10 do
            begin
              if (porte[i].x=round((pixelX+0)/8)) and (porte[i].y=round((pixelY+BORD_F_BAS)/8)) then u:=i;
            end;
            if not(porte[u].fermee) then pixelY:=pixelY+avancePixels;
          end
          else pixelY:=pixelY+avancePixels;
        end
        else fantome[n].directionEnCours:=fantome[n].dureeDirection-1;
        fantome[n].pixelY:=pixelY;
        fantome[n].y:=round(pixelY/8);
      end;
  end;
end;

//
//  ++  Deplacement des gloutoman  ++
//
procedure TFormMain.deplacer_gloutoman(n:integer);
var
   pixelX, pixelY : Integer;
   selectionPorte, numPorte : Integer;
begin
  selectionPorte:=0;
  pixelX:=gloutoman[n].pixelX;
  pixelY:=gloutoman[n].pixelY;

  if not(gloutoman[n].arret) then
  begin
    case gloutoman[n].direction of

        1:begin
          if ((tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]=0)or(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]>16)and(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]<>27))and((tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+0)/8)]=0)or(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+0)/8)]>16)and(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+0)/8)]<>27))and((tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]=0)or(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]>16)and(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]<>27)) then
          begin
            if (tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+0)/8)]=17)or(tableau[round((pixelX+BORD_G_DROITE)/8),round((pixelY+0)/8)]=18) then
            begin
              for numPorte:=1 to 10 do
              begin
                if (porte[numPorte].x=round((pixelX+BORD_G_DROITE)/8)) and (porte[numPorte].y=round((pixelY+0)/8)) then selectionPorte:=numPorte;
              end;
              if not(porte[selectionPorte].fermee) then pixelX:=pixelX+avancePixels;
            end
            else pixelX:=pixelX+avancePixels;
          end;
          gloutoman[n].pixelX:=pixelX;
          gloutoman[n].x:=round(pixelX/8);
        end;

        2:begin
          if ((tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]=0)or(tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]>16)and(tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]<>27))and((tableau[round((pixelX+0)/8),round((pixelY-BORD_G_HAUT)/8)]=0)or(tableau[round((pixelX+0)/8),round((pixelY-BORD_G_HAUT)/8)]>16)and(tableau[round((pixelX+0)/8),round((pixelY-BORD_G_HAUT)/8)]<>27))and((tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]=0)or(tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]>16)and(tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY-BORD_G_HAUT)/8)]<>27)) then
          begin
            if (tableau[round((pixelX+0)/8),round((pixelY-BORD_G_HAUT)/8)]=17)or(tableau[round((pixelX+0)/8),round((pixelY-BORD_G_HAUT)/8)]=18) then
            begin
              for numPorte:=1 to 10 do
              begin
                if (porte[numPorte].x=round((pixelX+0)/8)) and (porte[numPorte].y=round((pixelY-BORD_G_HAUT)/8)) then selectionPorte:=numPorte;
              end;
              if not(porte[selectionPorte].fermee) then pixelY:=pixelY-avancePixels;
            end
            else pixelY:=pixelY-avancePixels;
          end;
          gloutoman[n].pixelY:=pixelY;
          gloutoman[n].y:=round(pixelY/8);
        end;

        3:begin
          if ((tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]=0)or(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]>16)and(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY-BORD_G_HAUT+avancePixels)/8)]<>27))and((tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+0)/8)]=0)or(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+0)/8)]>16)and(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+0)/8)]<>27))and((tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]=0)or(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]>16)and(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+BORD_G_BAS-avancePixels)/8)]<>27)) then
          begin
            if (tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+0)/8)]=17)or(tableau[round((pixelX-BORD_G_GAUCHE)/8),round((pixelY+0)/8)]=18) then
            begin
              for numPorte:=1 to 10 do
              begin
                if (porte[numPorte].x=round((pixelX-BORD_G_GAUCHE)/8)) and (porte[numPorte].y=round((pixelY+0)/8)) then selectionPorte:=numPorte;
              end;
              if not(porte[selectionPorte].fermee) then pixelX:=pixelX-avancePixels;
            end
            else pixelX:=pixelX-avancePixels;
          end;
          gloutoman[n].pixelX:=pixelX;
          gloutoman[n].x:=round(pixelX/8);
        end;

        4:begin
          if ((tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]=0)or(tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]>16)and(tableau[round((pixelX-BORD_G_GAUCHE+avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]<>27))and((tableau[round((pixelX+0)/8),round((pixelY+BORD_G_BAS)/8)]=0)or(tableau[round((pixelX+0)/8),round((pixelY+BORD_G_BAS)/8)]>16)and(tableau[round((pixelX+0)/8),round((pixelY+BORD_G_BAS)/8)]<>27))and((tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]=0)or(tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]>16)and(tableau[round((pixelX+BORD_G_DROITE-avancePixels)/8),round((pixelY+BORD_G_BAS)/8)]<>27)) then
          begin
            if (tableau[round((pixelX+0)/8),round((pixelY+BORD_G_BAS)/8)]=17)or(tableau[round((pixelX+0)/8),round((pixelY+BORD_G_BAS)/8)]=18) then
            begin
              for numPorte:=1 to 10 do
              begin
                if (porte[numPorte].x=round((pixelX+0)/8)) and (porte[numPorte].y=round((pixelY+BORD_G_BAS)/8)) then selectionPorte:=numPorte;
              end;
              if not(porte[selectionPorte].fermee) then pixelY:=pixelY+avancePixels;
            end
            else pixelY:=pixelY+avancePixels;
          end;
          gloutoman[n].pixelY:=pixelY;
          gloutoman[n].y:=round(pixelY/8);
        end;
    end;
  end;
end;

//
//  ++  Affichage des scores  ++
//
procedure TFormMain.afficher_score;
begin
with zoneScore.canvas do
begin
     pen.color:=clblack;
     brush.color:=clblack;
     rectangle(0,0,zoneScore.width,zoneScore.height);
     font.style:=[fsbold];
     font.size:=11;
     font.name:='Arial';
     if not(multijoueurs) then
     begin
          font.color:=clwhite;
          textout((107-length('SCORE')*5),1,'SCORE');
          textout((318-length('LEVEL')*5),1,'LEVEL');
          textout((533-length('HIGH SCORE')*5),1,'HIGH SCORE');
          font.size:=12;
          textout((108-length(inttostr(gloutoman[1].score))*4),15,inttostr(gloutoman[1].score));
          textout((316-length(inttostr(level+1))*4),15,inttostr(level));
          textout((531-length(inttostr(hscore))*4),15,inttostr(hscore));
     end
     else
     begin
          font.color:=clyellow;
          font.size:=11;
          textout((107-length('SCORE')*5),1,'SCORE');
          font.size:=12;
          textout((108-length(inttostr(gloutoman[1].score))*4),15,inttostr(gloutoman[1].score));
          font.color:=clwhite;
          font.size:=11;
          textout((318-length('LEVEL')*5),1,'LEVEL');
          font.size:=12;
          textout((316-length(inttostr(level+1))*4),15,inttostr(level));
          font.color:=cllime;
          font.size:=11;
          textout((530-length('SCORE')*5),1,'SCORE');
          font.size:=12;
          textout((531-length(inttostr(gloutoman[2].score))*4),15,inttostr(gloutoman[2].score));
          font.color:=clwhite;
     end;
end;
with zoneObjets.canvas do
begin
     pen.color:=clblack;
     brush.color:=clblack;
     rectangle(0,0,zoneObjets.width,zoneObjets.height);

     if gloutoman[1].vie=0 then formMain.perdu;
     if gloutoman[1].vie>=1 then ImageListGloutoMan.Draw(zoneObjets.canvas,3,3,1);
     if gloutoman[1].vie>=2 then ImageListGloutoMan.Draw(zoneObjets.canvas,27,3,1);
     if gloutoman[1].vie>=3 then ImageListGloutoMan.Draw(zoneObjets.canvas,51,3,1);
     if gloutoman[1].vie>=4 then ImageListGloutoMan.Draw(zoneObjets.canvas,75,3,1);

     if gloutoman[2].vie=0 then formMain.perdu;
     if gloutoman[2].vie>=1 then ImageListGloutoMan.Draw(zoneObjets.canvas,3,30,49);
     if gloutoman[2].vie>=2 then ImageListGloutoMan.Draw(zoneObjets.canvas,27,30,49);
     if gloutoman[2].vie>=3 then ImageListGloutoMan.Draw(zoneObjets.canvas,51,30,49);
     if gloutoman[2].vie>=4 then ImageListGloutoMan.Draw(zoneObjets.canvas,75,30,49);

     if nb_cerises>=1 then ImageListObjets.Draw(zoneObjets.canvas,535,3,IMG_CERISE);
     if nb_cerises>=2 then ImageListObjets.Draw(zoneObjets.canvas,557,3,IMG_CERISE);
     if nb_cerises>=3 then ImageListObjets.Draw(zoneObjets.canvas,581,3,IMG_CERISE);
     if nb_cerises=4 then
     begin
          ImageListObjets.Draw(zoneObjets.canvas,607,3,IMG_CERISE);
          formMain.niveau_reussi;
     end;
     if nb_bananes>=1 then ImageListObjets.Draw(zoneObjets.canvas,538,30,IMG_BANANE);
     if nb_bananes>=2 then ImageListObjets.Draw(zoneObjets.canvas,562,30,IMG_BANANE);
     if nb_bananes>=3 then ImageListObjets.Draw(zoneObjets.canvas,586,30,IMG_BANANE);
     if nb_bananes=4 then
     begin
          ImageListObjets.Draw(zoneObjets.canvas,610,30,IMG_BANANE);
          formMain.niveau_reussi;
     end;

     case gloutoman[1].objetSelected of
          0:ImageListObjets.Draw(zoneObjets.canvas,318,4,IMG_AIL);
          //1:ImageListObjets.Draw(zoneObjets.canvas,319,3,IMG_CLEF);
          1:ImageListObjets.Draw(zoneObjets.canvas,320,3,IMG_SECOURS);
          2:ImageListObjets.Draw(zoneObjets.canvas,322,3,IMG_DYNAMITE);
          3:ImageListObjets.Draw(zoneObjets.canvas,322,2,IMG_BOMBE);
     end;
     case gloutoman[2].objetSelected of
          0:ImageListObjets.Draw(zoneObjets.canvas,318,31,IMG_AIL);
          //1:ImageListObjets.Draw(zoneObjets.canvas,319,30,IMG_CLEF);
          1:ImageListObjets.Draw(zoneObjets.canvas,320,30,IMG_SECOURS);
          2:ImageListObjets.Draw(zoneObjets.canvas,322,30,IMG_DYNAMITE);
          3:ImageListObjets.Draw(zoneObjets.canvas,322,29,IMG_BOMBE);
     end;
     font.color:=clwhite;
     font.style:=[fsbold];
     font.size:=12;
     font.name:='Arial';
     textout(302,8,inttostr(objet[gloutoman[1].objetSelected,1].quantite)+'x');
     textout(302,35,inttostr(objet[gloutoman[2].objetSelected,2].quantite)+'x');

     // Affichage de la barre de progression du Timer fantômes
     zoneObjets.canvas.brush.color:=claqua;
     if temps_timer<>0 then zoneObjets.canvas.rectangle(3,4,3+temps_timer*10,24);

     // Objets en mode Triche
     if all_objets then
     begin
          objet[0,1].quantite:=4;
          objet[0,2].quantite:=4;
          objet[1,1].quantite:=1;
          objet[1,2].quantite:=1;
          objet[2,1].quantite:=1;
          objet[2,2].quantite:=1;
          objet[3,1].quantite:=1;
          objet[3,2].quantite:=1;
          objet[4,1].quantite:=1;
          objet[4,2].quantite:=1;
     end;
 end;
end;

//
//  ++  Affichage des points  ++
//
Procedure TFormMain.afficherPoints(var n:integer; points:string);
begin
  lasttickcount[44,1]:=gettickcount;
  labelPoints.Visible:=true;
  labelPoints.Caption:=points;
  labelPoints.Left:=gloutoman[n].pixelX-1;
  labelPoints.Top:=gloutoman[n].pixelY+7;
end;

//
//  ++  Collisions avec l'environnement  ++
//
procedure TFormMain.verif_case(n:integer);
var
  numBouton, numTelep : Integer;
begin
     gloutoman[n].vitesse:=vitesse_selectglouto;

     case tableau[gloutoman[n].x,gloutoman[n].y] of
          20:begin
                 if not(multijoueurs)or((multijoueurs)and(cooperatif)) then
                 begin
                      jouerSon(SND_CERISE);
                      tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                      gloutoman[n].score:=gloutoman[n].score+200;
                      afficherPoints(n,'200');
                      inc(nb_cerises);
                 end
                 else if multijoueurs and adversaire and (n=1) then
                 begin
                      jouerSon(SND_CERISE);
                      tableau[gloutoman[1].x,gloutoman[1].y]:=0;
                      gloutoman[1].score:=gloutoman[1].score+200;
                      afficherPoints(n,'200');
                      inc(nb_cerises);
                 end;
          end;
          21:begin
                 if multijoueurs and adversaire and (n=2) then
                 begin
                      jouerSon(SND_CERISE);
                      tableau[gloutoman[2].x,gloutoman[2].y]:=0;
                      gloutoman[2].score:=gloutoman[2].score+200;
                      afficherPoints(n,'200');
                      inc(nb_bananes);
                 end;
          end;
          22:begin
                 tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                 gloutoman[n].score:=gloutoman[n].score+10;
          end;
          23:begin
                 jouerSon(SND_PIECE);
                 tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                 gloutoman[n].score:=gloutoman[n].score+100;
                 afficherPoints(n,'100');
          end;
          24:begin
                  jouerSon(SND_BONUS);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  gloutoman[n].score:=gloutoman[n].score+500;
                  afficherPoints(n,'500');
          end;
          25:begin
                  jouerSon(SND_BONUS2);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  gloutoman[n].score:=gloutoman[n].score+1000;
                  afficherPoints(n,'1000');
          end;
          26:begin
                  jouerSon(SND_BONUS2);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  gloutoman[n].score:=gloutoman[n].score*2;
                  afficherPoints(n,'x2');
          end;
          28:begin
                  if valeurPrec[n]<>28 then
                  begin
                    jouerSon(SND_TUT);
                    for numBouton := 1 to 5 do
                    begin
                      if (bouton[numBouton].x=gloutoman[n].x)and(bouton[numBouton].y=gloutoman[n].y) then
                      begin
                        porte[bouton[numBouton].lien].fermee:=false;
                        porte[bouton[numBouton].lien].ouverture:=true;
                        lasttickcount[40+bouton[numBouton].lien,1]:=getTickCount;
                      end;
                    end;

                  end;
          end;
          30:begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  gloutoman[n].Pacgom;
          end;
          31:gloutoman[n].vitesse:=vitesse_selectglouto+vcolle;
          32:gloutoman[n].vitesse:=vitesse_selectglouto-vpat;
          33:begin
                  if valeurPrec[n]<>33 then
                  begin
                    if not(gloutoman[n].pause)then jouerSon(SND_GELER);
                    gloutoman[n].Freeze;
                  end;
          end;
          34:begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  lasttickcount[7,1]:=gettickcount;
                  if temps_timer=0 then temps_timer:=10;
          end;
          35:begin
                  if (valeurPrec[n]<>35) and (gloutoman[n].score>20000) then
                  begin
                    gloutoman[n].pause:=true;
                    jouerSon(SND_PASSAGE);
                    dec(gloutoman[n].score, 20000);
                    inc(level);
                    debut_tableau;
                  end;
          end;
          36:begin
                  if valeurPrec[n]<>36 then
                  begin
                    jouerSon(SND_TELEP);
                    for numTelep := 1 to 5 do
                      begin
                        if (teleporteur[numTelep].x=gloutoman[n].x)and(teleporteur[numTelep].y=gloutoman[n].y) then
                          begin
                            gloutoman[n].x:=teleporteur[teleporteur[numTelep].lien].x;
                            gloutoman[n].y:=teleporteur[teleporteur[numTelep].lien].y;
                            gloutoman[n].pixelX:=gloutoman[n].x*8;
                            gloutoman[n].pixelY:=gloutoman[n].y*8;
                            gloutoman[n].arret:=true;
                            break;
                          end;
                      end;
                  end;
          end;
          37:begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  if gloutoman[n].vie<4 then gloutoman[n].vie:=gloutoman[n].vie+1;
          end;
          38:begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  inc(objet[1,n].quantite);
          end;
          39:begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  inc(objet[0,n].quantite);
          end;
          40:begin
                  jouerSon(SND_TUER);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  dec(gloutoman[n].vie);
          end;
          41:begin
                  jouerSon(SND_WIP);
                  if objet[1,n].quantite=0 then
                  begin
                       tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                       inc(objet[1,n].quantite);
                  end;
          end;
          42:if not(dynamite[n].active) then
          begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  inc(objet[2,n].quantite);
          end;
          43:if not(bombe[n].active) then
          begin
                  jouerSon(SND_WIP);
                  tableau[gloutoman[n].x,gloutoman[n].y]:=0;
                  inc(objet[3,n].quantite);
          end;

     end;
     valeurPrec[n]:=tableau[gloutoman[n].x,gloutoman[n].y];
end;

//
//  ++  Collisions avec les fantômes  ++
//
procedure TFormMain.test_collision;
var
   i, n, x, y, z : Integer;
begin
  for i:=1 to 10 do
  for n:=1 to 2 do
  begin
       if fantome[i].present then
       begin
            for x:=-1 to 1 do
            for y:=-1 to 1 do
            begin
            //if ((fantome[i].x+x=gloutoman[n].x-1) or (fantome[i].x+x=gloutoman[n].x) or (fantome[i].x+x=gloutoman[n].x+1)) and ((fantome[i].y+y=gloutoman[n].y-1) or (fantome[i].y+y=gloutoman[n].y) or (fantome[i].y+y=gloutoman[n].y+1)) and (gloutoman[n].present)and not(invincible) then
            if (fantome[i].x+x=gloutoman[n].x) and (fantome[i].y+y=gloutoman[n].y) and (gloutoman[n].present)and not(invincible) then
            begin
                 if (gloutoman[n].etat=0) and (fantome[i].etat=0) then
                 begin
                      if not(gloutoman[n].arret) then
                      begin
                           if not(triche) then jouerSon(SND_TUER) else jouerSon(SND_TUER_TRICHE);
                           dec(gloutoman[n].vie);
                           gloutoman[n].x:=gloutoman[n].positionInitX;
                           gloutoman[n].y:=gloutoman[n].positionInitY;
                           gloutoman[n].pixelX:=gloutoman[n].positionInitX*8;
                           gloutoman[n].pixelY:=gloutoman[n].positionInitY*8;
                           gloutoman[n].direction:=1;
                           gloutoman[n].arret:=true;
                      end;
                 end
                 else if fantome[i].etat=0 then
                 begin
                      jouerSon(SND_MANGER);
                      fantome[i].Mangé;
                      inc(gloutoman[n].score,300);
                      lasttickcount[i+20,1]:=gettickcount;
                      z:=n;
                      afficherPoints(z,'300');
                 end;
            end;
            end;
       end;
  end;
end;

//
//  ++  Niveau perdu  ++
//
procedure TFormMain.perdu;
begin
     if multijoueurs then
     begin
          if gloutoman[1].vie=0 then gloutoman[1].present:=false;
          if gloutoman[2].vie=0 then gloutoman[2].present:=false;
          if (gloutoman[1].vie=0) and (gloutoman[2].vie=0) then
          begin
               pause:=true;
               if cooperatif then if not(animFermeture) then affichageMessage(MESSAGE2, 1)
               else
               begin
                    if gloutoman[1].score>gloutoman[2].score then if not(animFermeture) then affichageMessage(MESSAGE8, 0)
                    else if not(animFermeture) then affichageMessage(MESSAGE9, 0);
               end;
               if not(animFermeture) then affichageMessage(MESSAGE7, 2);
          end;
     end
     else
     begin
          if (gloutoman[1].score>hscore)and not(tricheur) then hscore:=gloutoman[1].score;
          pause:=true;
          if not(animFermeture) then affichageMessage(MESSAGE2, 1);
     end;
end;

//
//  ++  Niveau réussi  ++
//
procedure TFormMain.niveau_reussi;
begin
     if not(multijoueurs)or((multijoueurs)and(cooperatif))then
     begin
          pause:=true;
          if not(animFermeture) then affichageMessage(MESSAGE1+inttostr(level), 0);
     end
     else if multijoueurs and adversaire then
     begin
          if nb_cerises=4 then
          begin
               pause:=true;
               if not(animFermeture) then
               begin
                 AffichageMessage(MESSAGE3+inttostr(level), 0);
                 inc(gloutoman[1].score,5000);
               end;
          end
          else if nb_bananes=4 then
          begin
               pause:=true;
               if not(animFermeture) then
               begin
                 AffichageMessage(MESSAGE4+inttostr(level), 0);
                 inc(gloutoman[2].score,5000);
               end;
          end;
     end;
end;

//
//  ++  Partie gagnée  ++
//
procedure TFormMain.gagner;
begin
     pause:=true;
     if not(multijoueurs)and(gloutoman[1].score>hscore)and not(tricheur) then hscore:=gloutoman[1].score;
     if multijoueurs and adversaire then
     begin
         if gloutoman[1].score>gloutoman[2].score then if not(animFermeture) then AffichageMessage(MESSAGE8, 0)
         else if not(animFermeture) then AffichageMessage(MESSAGE9, 0);
     end;
     if not(animFermeture) then AffichageMessage(MESSAGE6, 2);
end;

//
//  ************************
//  **  Fin du programme  **
//  ************************
//
end.
