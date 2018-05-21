unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, Buttons, al_lib, VirtualOpenAL, smallvectorlib;

type

  TForm1 = class(TForm)
    BitBtn4: TBitBtn;
    Timer1: TTimer;
    procedure BitBtn4Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  fazer: longword;
  dofunstuff: boolean = false;

implementation

{$R *.DFM}

procedure notifydeletion(src: Longword; userdata: pointer);
begin
showmessage('A source was deleted: ' + inttostr(src));
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin

VirtualOpenDevice(nil); 

// create as much openal sources as you want now, to reserve them for your own use!
// like music streaming, etc.. the rest will be used by Virtual OpenAL.

VirtualInitialize;

// send some wave data to the buffer

setlength(WaveBuffers, length(WaveBuffers) +1);
with WaveBuffers[high(WaveBuffers)] do begin
ID:= 1;
XALLoadWave(buffer, pchar('warpbreachsooner.wav'));
end;

setlength(WaveBuffers, length(WaveBuffers) +1);
with WaveBuffers[high(WaveBuffers)] do begin
ID:= 2;
XALLoadWave(buffer, pchar('Phaser.wav'));
end;

// make some sounds!

VirtualModifyListener(makevector(0.0, 0.0, 0.0), makevector(0.0, 0.0, 0.0), virtualopenal.ListenerOrientationarray);

SourceCreate(WaveBuffers[FindBuffer(1)].buffer, makevector(0, 0, 0), true , nil            , nil);
fazer:= SourceCreate(WaveBuffers[FindBuffer(2)].buffer,   makevector(1, 0, 0), false, notifydeletion, nil);

VirtualSwapInSwapOut;

dofunstuff:= true;

end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
virtualopenal.ClockMS:= gettickcount; // very important! unit relies on your own external timer (whatever you want to use)
VirtualProcess;

if dofunstuff = false then exit;

{SourceModify(
fazer,
makevector(sin(gettickcount div 100), cos(gettickcount div 100), 0),
makevector(0, 0, 0),
false,
1);}

end;

end.
 