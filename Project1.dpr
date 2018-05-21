program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  AL_Lib in '..\AL_Lib.pas',
  VirtualOpenAL in 'VirtualOpenAL.pas',
  smallvectorlib in 'smallvectorlib.pas';

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
