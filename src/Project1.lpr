program Project1;

{$MODE Delphi}

uses
  Forms, Interfaces, objects,
  Unit1 in 'Unit1.pas' {Form1},
  Pacman in 'Pacman.pas',
  Map in 'Map.pas',
  MapObject in 'MapObject.pas',
  Food in 'Food.pas',
  LinkedList in 'LinkedList.pas',
  Ghost in 'Ghost.pas',
  Animation in 'Animation.pas',
  Astar in 'Astar.pas';

{.$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
