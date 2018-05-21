{ *********************************************************************** }
{                                                                         }
{ Cool audio management unit                                              }
{ Prototype 1A 2009200X                                                   }
{                                                                         }
{ Notes:                                                                  }
{ replace bidirectional bubble sort with something.. better?              }
{                                                                         }
{ Copyright (c) 2001-2006 Jernej L.                                       }
{                                                                         }
{ *********************************************************************** }

{
USAGE:

remember, whatever timer you use in your game, assign it every frame to
ClockMS variable, this will ensure stutter-less switching of sounds,
gettickcount is usually good, but you can use timegettime or performance
counter if you wish, use whatever is the most precise that you have availible!

you may need to replace some external vector library functions with your own.
glscene's vector unit should work without problem.

}

unit VirtualOpenAL;

interface

uses
   sysutils, classes, windows, dialogs, al_lib, smallvectorlib;

type

  Twavheader = packed record
    ChunkID:     array[0..3] of char;     // 'RIFF' text
    ChunkSize:   longword;
    Format:      array[0..3] of char;      // 'WAVE' text
    Subchunk1ID: array[0..3] of char; // 'fmt ' text
    Subchunk1Size: longword;
    AudioFormat: word;
    NumChannels: word;
    SampleRate:  longword;
    ByteRate:    longword;
    BlockAlign:  word;
    BitsPerSample: word;
    Subchunk2ID: array[0..3] of char; // 'data' text
    Subchunk2Size: longword;
  end;

  // reprisents loaded sound buffers
  Taudiosample = packed record
    ID:     longword;
    buffer: ALuint;
  end;

  Tvirtualsource = packed record
    SwapOutTime: longword;

    Gain:      single;
    Min_Gain:  single;
    Max_Gain:  single;
    Position:  Vector;
    Velocity:  Vector;
    Direction: Vector;
    Head_Relative_Mode: longword;
    Reference_Distance: single;
    Max_Distance: single;
    RollOff_Factor: single;
    Inner_Angle: single;
    Outer_Angle: single;
    Cone_Outer_Gain: single;
    Pitch:     single;
    Looping:   longword;
    SEC_Offset: single;
    Byte_Offset: integer;
    Sample_Offset: integer;
    Attached_Buffer: longword;
    //  read only, but needed
    Source_State: longword;
    //  Buffers_Queued: longword;
    //  Buffers_Processed: longword;
  end;

  Pvirtualsource = ^Tvirtualsource;

  TSourceMode = (SMSwappedOut, SMInOpenAL, SMDeleted);

  // when it is deleted, it will call this function to let you know you lost the buffer.
  TDeleteNotifyproc = procedure(src: longword; userdata: pointer);

  Tsource = packed record
    UserDat:  Pointer;
    mode:     TSourceMode;
    ALsource: ALuint;
    DeleteCB: TDeleteNotifyproc;
    VirtualSource: Tvirtualsource;
  end;

  TSortInfo = packed record
    SourceNum:      longword;
    SourceDistance: single;
  end;

  TListenerOrientation = array[0..5] of ALfloat;

// create a source which will play the sound, if loop = false then it will destroy itself after playing the effect.
function SourceCreate(Buffer: longword; Loc: Vector; loop: boolean;
  DeleteCallBack: TDeleteNotifyproc; userdata: Pointer): longword;

// sets some most common source properties
procedure SourceModify(src: longword; Loc, Vel: Vector; Loop: boolean;
  Pitch, Volume: single);

// sets source stream position (CHANGE IT SO IT DOES IT BY PERCENT OF LENGTH OF THE STREAM!)
procedure SourceSeek(src: longword; loc: single);

// retrieves current buffer position  (CHANGE IT SO IT DOES IT BY PERCENT OF LENGTH OF THE STREAM!)
function SourceGetOffset(src: longword): single;

// forcefuly destroys a sound source
procedure SourceDestroy(src: longword);

// swap source into openal and back
procedure InternalSwapIN(src: longword);
procedure InternalSwapOUT(src: longword);

// call this every few frames, NOT every frame since it is a little more intensive procedure (does sorting and source swapping)
procedure VirtualSwapInSwapOut;
// pause / unpause the sounds
procedure VirtualPause(paused: boolean);
// process sources, will delete sources that have finished playing
procedure VirtualProcess;
// opens the sound device of your choosing
// send NIL to open default device that openal will prefer, otherwise you can tell it to try:
// 'MMSYSTEM', 'Generic Software' , 'DirectSound' , 'Generic Hardware' , 'DirectSound3D'

// Default on windows:
// 'Generic Hardware' -> 'DirectSound3D'
// 'Generic Software' -> 'DirectSound'
// on vista, directsound is no longer hardware accelerated, you need to choose accelerated hardware device.
procedure VirtualOpenDevice(DeviceID: PChar);
// initializes the virtual sound manager, before calling this you can create sources to reserve them for whatever you would need them.
procedure VirtualInitialize;
// sets up listener, if you don't want to bother with listener orientation just pass it ListenerOrientationarray
procedure VirtualModifyListener(Position, Velocity: Vector;
  listener: TListenerOrientation);

procedure XALLoadWave(var albuf: ALuint; const filen: string);
function FindBuffer(id: longword): longword;

var
  CBackProc: procedure(src: longword; userdata: Pointer);

  Device:  PALCdevice;
  Context: PALCcontext;

  ClockMS: longword;
  MaxSourceDistance: single = 10; // only sources closer than this will play
//  MaxSourcesToUse: integer;

  PrePaused, Pause: boolean;
  PauseTime: longword;

  PhySourcesAvail: integer;
  PhySourcesUsed:  integer;

  Sources: array of Tsource;
  Sorting: array of TSortInfo;

  WaveBuffers: array of Taudiosample; // wave buffers

  ListenerPosition, ListenerVelocity: Vector;
  // first vector for direction, second is attitude (the up vector).
  ListenerOrientationarray: TListenerOrientation = (0.0, 0.0, -1.0, 0.0, 1.0, 0.0);

implementation

procedure XALLoadWave(var albuf: ALuint; const filen: string);
var
  wavheader: Twavheader;

  format: ALEnum;
  size:   ALSizei;
  freq:   ALSizei;

  buffer: PChar;

  f: Tmemorystream;
begin

  f := Tmemorystream.Create;
  f.LoadFromFile(filen);

  f.Read(wavheader, sizeof(wavheader));

  getmem(buffer, wavheader.Subchunk2Size);
  f.Read(buffer^, wavheader.Subchunk2Size);

  format := AL_FORMAT_MONO8 + ((wavheader.BitsPerSample div 8) - 1) +
    (wavheader.NumChannels - 1) * 2;

  size := wavheader.Subchunk2Size;
  freq := wavheader.SampleRate;

  AlGenBuffers(1, @albuf);
  AlBufferData(albuf, format, buffer, size, freq);

  freemem(buffer);
  f.Clear;
end;

function FindBuffer(id: longword): longword;
var
  i: integer;
begin
  Result := 0;

  for i := low(WaveBuffers) to high(WaveBuffers) do
    if id = WaveBuffers[i].ID then
    begin
      Result := i;
      break;
    end;

end;

// create a source which will play the sound, if loop = false then it will destroy itself after playing the effect.
function SourceCreate(Buffer: longword; Loc: Vector; loop: boolean;
  DeleteCallBack: TDeleteNotifyproc; userdata: Pointer): longword;
var
  i:      integer;
  Picked: integer;
begin
  //  loc:= VectorMultiply(loc, 2);

  Picked := -1;

  for i := 0 to length(Sources) - 1 do
  begin
    if Sources[i].mode = smdeleted then
    begin
      Picked := i;
      break;
    end;
  end;

  if Picked = -1 then
  begin
    setlength(Sources, length(Sources) + 1);
    Picked := high(Sources);
  end;

  with sources[Picked] do
  begin
    mode     := SMSwappedOut;
    DeleteCB := DeleteCallBack;
    UserDat  := UserData;

    fillchar(VirtualSource, sizeof(VirtualSource), 0);
    with VirtualSource do
    begin
      SwapOutTime := ClockMS;
      Gain     := 1;
      //  Min_Gain:= 0;
      Max_Gain := 1;
      Position := Loc;
      //  Velocity:= Vector;
      //  Direction:= Vector;
      //  Head_Relative_Mode:= 0;
      Reference_Distance := 1;
      Max_Distance := 3.4028234664e+38; // zomg, who at openal made up this constant?!?
      RollOff_Factor := 1;
      Inner_Angle := 360;
      Outer_Angle := 360;
      //  Cone_Outer_Gain:= 0;
      Pitch    := 1;
      Looping  := integer(Loop);

      //  SEC_Offset:= 0;
      //  Byte_Offset:= 0;
      //  Sample_Offset:= 0;
      Attached_Buffer := Buffer;
      Source_State    := AL_PLAYING;
    end;
  end;

  Result := Picked;
end;

// sets some most common source properties
procedure SourceModify(src: longword; Loc, Vel: Vector; Loop: boolean;
  Pitch, Volume: single);
begin

  //  loc:= VectorMultiply(loc, 2);

  with Sources[src] do
  begin
    VirtualSource.Position := Loc;
    VirtualSource.Velocity := Vel;
    VirtualSource.Pitch    := Pitch;
    VirtualSource.Looping  := integer(Loop);
    VirtualSource.Gain     := Volume;

    if mode = SMInOpenAL then
    begin
      alSourcefv(ALsource, AL_POSITION, @Loc);
      alSourcefv(ALsource, AL_VELOCITY, @Vel);
      alSourcefv(ALsource, AL_PITCH, @Pitch);
      alSourceiv(ALsource, AL_LOOPING, @Loop);
      alSourcefv(ALsource, AL_GAIN, @VirtualSource.Gain);
    end;
  end;
end;

// sets source stream position (CHANGE IT SO IT DOES IT BY PERCENT OF LENGTH OF THE STREAM!)
procedure SourceSeek(src: longword; loc: single);
var
  //fullbufflen: longword;
  bo: longword;
begin
  with Sources[src] do
  begin
    VirtualSource.Byte_Offset := trunc(loc);

    if mode = SMInOpenAL then
    begin
      //  alGetBufferi(VirtualSource.Attached_Buffer, AL_SIZE, @buffsize);
      bo := trunc(loc);
      alSourceiv(ALsource, AL_BYTE_OFFSET, @bo);
    end;
  end;
end;

// retrieves current buffer position  (CHANGE IT SO IT DOES IT BY PERCENT OF LENGTH OF THE STREAM!)
function SourceGetOffset(src: longword): single;
  //var
  //fullbufflen: longword;
begin
  Result := 0;

  with Sources[src] do
  begin
    if mode = SMInOpenAL then
    begin
      //  alGetBufferi(VirtualSource.Attached_Buffer, AL_SIZE, @buffsize);
      alGetSourcei(ALsource, AL_BYTE_OFFSET, @VirtualSource.Byte_Offset);
      Result := VirtualSource.Byte_Offset;
    end;
  end;
end;

procedure InternalSwapIN(src: longword);
var
  buffsize, bits, freq: longword;
  one_frame_ms: single;
  timepassedms: single;
begin
  with Sources[src] do
  begin
    // get buffer information
    alGetBufferi(VirtualSource.Attached_Buffer, AL_SIZE, @buffsize);
    alGetBufferi(VirtualSource.Attached_Buffer, AL_BITS, @bits);
    bits := bits div 8; // to bytes
    alGetBufferi(VirtualSource.Attached_Buffer, AL_FREQUENCY, @freq);

    // calculate how much time would whole sound take to play at current pitch.
    one_frame_ms := buffsize / bits / freq; // 44100
    one_frame_ms := one_frame_ms / VirtualSource.Pitch;

    // calculate how much time passed since the sound was swaped-out (according to current pitch).
    timepassedms := ((ClockMS - VirtualSource.SwapOutTime) / 1000);
    timepassedms := timepassedms / VirtualSource.Pitch;

    // add time passed to the time offset of the source
    VirtualSource.SEC_Offset := VirtualSource.SEC_Offset + timepassedms;

    // if not to be looped, and time passed long time ago for this sound,
    // then do not recreate, but DESTROY this sound!
    if (VirtualSource.Looping = 0) and (VirtualSource.SEC_Offset > one_frame_ms) then
    begin
      SourceDestroy(src);
      exit;
    end;

    // clamp new time to source length
    if VirtualSource.SEC_Offset > one_frame_ms then
      VirtualSource.SEC_Offset :=
        VirtualSource.SEC_Offset - (trunc(VirtualSource.SEC_Offset / one_frame_ms) *
        one_frame_ms);

    AlGenSources(1, @ALsource);
    PhySourcesUsed := PhySourcesUsed + 1;

    alSourcefv(ALsource, AL_GAIN, @VirtualSource.Gain);
    alSourcefv(ALsource, AL_MIN_GAIN, @VirtualSource.Min_Gain);
    alSourcefv(ALsource, AL_MAX_GAIN, @VirtualSource.Max_Gain);
    alSourcefv(ALsource, AL_POSITION, @VirtualSource.Position);
    alSourcefv(ALsource, AL_VELOCITY, @VirtualSource.Velocity);
    alSourcefv(ALsource, AL_DIRECTION, @VirtualSource.Direction);
    alSourceiv(ALsource, AL_SOURCE_RELATIVE, @VirtualSource.Head_Relative_Mode);
    alSourcefv(ALsource, AL_REFERENCE_DISTANCE, @VirtualSource.Reference_Distance);
    alSourcefv(ALsource, AL_MAX_DISTANCE, @VirtualSource.Max_Distance);
    alSourcefv(ALsource, AL_ROLLOFF_FACTOR, @VirtualSource.RollOff_Factor);
    alSourcefv(ALsource, AL_CONE_INNER_ANGLE, @VirtualSource.Inner_Angle);
    alSourcefv(ALsource, AL_CONE_OUTER_ANGLE, @VirtualSource.Outer_Angle);
    alSourcefv(ALsource, AL_CONE_OUTER_GAIN, @VirtualSource.Cone_Outer_Gain);

    //  0.01 to 4.53516983
    alSourcefv(ALsource, AL_PITCH, @VirtualSource.Pitch);
    alSourceiv(ALsource, AL_LOOPING, @VirtualSource.Looping);

    // restore only the seconds offset, since it is modified according to the pitch
    // and sample and byte offset will be restored as well.
    alSourcefv(ALsource, AL_SEC_OFFSET, @VirtualSource.SEC_Offset);
    //  alSourceiv(ALsource, AL_BYTE_OFFSET, @VirtualSource.Byte_Offset);
    //  alSourceiv(ALsource, AL_SAMPLE_OFFSET, @VirtualSource.Sample_Offset);

    alSourceiv(ALsource, AL_BUFFER, @VirtualSource.Attached_Buffer);

    //  these are according to documentation read only, we don't set them.
    //  alSourcefv(ALsource, AL_SOURCE_STATE, @VirtualSource.State); {AL_INITIAL, AL_PLAYING, AL_PAUSED, AL_STOPPED}
    //  alSourcefv(ALsource, AL_BUFFERS_QUEUED, @VirtualSource.Buffers_Queued);
    //  alSourcefv(ALsource, AL_BUFFERS_PROCESSED, @VirtualSource.Buffers_Processed);

    //  but we must restore AL_SOURCE_STATE, using AlSourcePlay and companion calls
    case VirtualSource.Source_State of
      AL_INITIAL: alSourceRewind(ALsource);
      AL_PLAYING: alSourcePlay(ALsource);
      AL_PAUSED: alSourcePause(ALsource);
      AL_STOPPED: alSourceStop(ALsource);
    end; // case

    mode := SMInOpenAL;
  end;
end;

procedure InternalSwapOUT(src: longword);
begin
  with Sources[src] do
  begin
    alGetSourcef(ALsource, AL_GAIN, @VirtualSource.Gain);
    alGetSourcef(ALsource, AL_MIN_GAIN, @VirtualSource.Min_Gain);
    alGetSourcef(ALsource, AL_MAX_GAIN, @VirtualSource.Max_Gain);
    alGetSourcef(ALsource, AL_POSITION, @VirtualSource.Position);
    alGetSourcef(ALsource, AL_VELOCITY, @VirtualSource.Velocity);
    alGetSourcef(ALsource, AL_DIRECTION, @VirtualSource.Direction);
    alGetSourcei(ALsource, AL_SOURCE_RELATIVE, @VirtualSource.Head_Relative_Mode);
    alGetSourcef(ALsource, AL_REFERENCE_DISTANCE, @VirtualSource.Reference_Distance);
    alGetSourcef(ALsource, AL_MAX_DISTANCE, @VirtualSource.Max_Distance);
    alGetSourcef(ALsource, AL_ROLLOFF_FACTOR, @VirtualSource.RollOff_Factor);
    alGetSourcef(ALsource, AL_CONE_INNER_ANGLE, @VirtualSource.Inner_Angle);
    alGetSourcef(ALsource, AL_CONE_OUTER_ANGLE, @VirtualSource.Outer_Angle);
    alGetSourcef(ALsource, AL_CONE_OUTER_GAIN, @VirtualSource.Cone_Outer_Gain);
    alGetSourcef(ALsource, AL_PITCH, @VirtualSource.Pitch);
    alGetSourcei(ALsource, AL_LOOPING, @VirtualSource.Looping);
    alGetSourcef(ALsource, AL_SEC_OFFSET, @VirtualSource.SEC_Offset);
    alGetSourcei(ALsource, AL_BYTE_OFFSET, @VirtualSource.Byte_Offset);
    alGetSourcei(ALsource, AL_SAMPLE_OFFSET, @VirtualSource.Sample_Offset);
    alGetSourcei(ALsource, AL_BUFFER, @VirtualSource.Attached_Buffer);
    //  read only
    alGetSourcei(ALsource, AL_SOURCE_STATE, @VirtualSource.Source_State);
    //  alGetSourcei(ALsource, AL_BUFFERS_QUEUED, @VirtualSource.Buffers_Queued);
    //  alGetSourcei(ALsource, AL_BUFFERS_PROCESSED, @VirtualSource.Buffers_Processed);

    alDeleteSources(1, @ALsource);
    PhySourcesUsed := PhySourcesUsed - 1;

    VirtualSource.SwapOutTime := ClockMS;

    mode := SMSwappedOut;
  end;
end;

// forcefuly destroys a sound source
procedure SourceDestroy(src: longword);
begin

  // get rid of the source
  if Sources[src].mode = SMSwappedOut then
  begin
    Sources[src].mode := SMDeleted;
  end;

  if Sources[src].mode = SMInOpenAL then
  begin
    alDeleteSources(1, @Sources[src].ALsource);
    PhySourcesUsed    := PhySourcesUsed - 1;
    Sources[src].mode := SMDeleted;
  end;

  // notify application that source got lost..
  if Assigned(Sources[src].DeleteCB) = True then
    Sources[src].DeleteCB(src, Sources[src].UserDat);
end;

procedure VirtualSwapInSwapOut;
var
  i: integer;
  sortarrayused: integer;
  has_swapped: boolean;

  procedure swapitems(First, second: longword);
  var
    n: TSortInfo;
  begin
    move(Sorting[First], n, sizeof(TSortInfo));
    move(Sorting[second], Sorting[First], sizeof(TSortInfo));
    move(n, Sorting[second], sizeof(TSortInfo));
  end;

begin

  if Pause = True then
    exit;

  // swap sources in and out

  sortarrayused := 0;
  setlength(Sorting, length(Sources));

  for i := 0 to high(Sources) do
    if Sources[i].mode <> SMDeleted then
    begin
      Sorting[sortarrayused].SourceNum := i;
      Sorting[sortarrayused].SourceDistance :=
        vectordistance(Sources[i].VirtualSource.Position, ListenerPosition);

      sortarrayused := sortarrayused + 1;
    end;

  // bidirectional bubble sort! .o0O.°o.0
  // replace with something better!

  repeat
    has_swapped := False;

    for i := 0 to sortarrayused - 2 do
    begin
      if Sorting[i].SourceDistance > Sorting[i + 1].SourceDistance then
      begin
        swapitems(i, i + 1);
        has_swapped := True;
      end;
    end;

    // now go go the other way around
    if has_swapped = True then
      for i := sortarrayused - 2 downto 0 do
      begin
        if Sorting[i].SourceDistance > Sorting[i + 1].SourceDistance then
        begin
          swapitems(i, i + 1);
          has_swapped := True;
        end;
      end;

  until has_swapped = False;

  // now activate nearby and deactivate far distant sounds

  for i := 0 to sortarrayused - 1 do
  begin

    if (i < PhySourcesAvail) and (Sorting[i].SourceDistance < MaxSourceDistance) then
      if Sources[Sorting[i].SourceNum].mode = SMSwappedOut then
        InternalSwapIN(Sorting[i].SourceNum);

    if (i > PhySourcesAvail) or (Sorting[i].SourceDistance > MaxSourceDistance) then
      if Sources[Sorting[i].SourceNum].mode = SMInOpenAL then
        InternalSwapOut(Sorting[i].SourceNum);
  end;

end;

procedure VirtualPause(paused: boolean);
var
  i: integer;
begin
  // pause audio?

  if paused = Pause then
    exit; // no change, exit.

  PrePaused := Pause;
  Pause     := Paused;

  // going into pause, swap-out all sources
  if (prepaused = False) and (Pause = True) then
  begin

    PauseTime := ClockMS;

    for i := 0 to length(Sources) - 1 do
    begin
      if Sources[i].mode = SMInOpenAL then
        InternalSwapOut(i);
    end;

  end;

  // exitting pause, adjust timing, swapinswapout call will swap sounds back.
  if (prepaused = True) and (Pause = False) then
  begin

    for i := 0 to length(Sources) - 1 do
      if Sources[i].mode <> SMDeleted then
      begin
        Sources[i].VirtualSource.SwapOutTime :=
          Sources[i].VirtualSource.SwapOutTime + (ClockMS - PauseTime);
      end;

  end;

end;

procedure VirtualProcess;
var
  i: integer;
begin
  if Pause = True then
    exit;

  // delete sources which are to be deleted.
  for i := 0 to high(Sources) do
  begin

    if Sources[i].mode = SMDeleted then
      continue;

    if Sources[i].mode = SMInOpenAL then
      alGetSourcei(Sources[i].ALsource, AL_SOURCE_STATE,
        @Sources[i].VirtualSource.Source_State);

    if Sources[i].VirtualSource.Source_State = AL_STOPPED then
      SourceDestroy(i);
  end;
end;

procedure VirtualOpenDevice(DeviceID: PChar);
begin
  Device := alcOpenDevice(DeviceID);
  if Device = nil then
    showmessage('No Audio devices found..?');
  Context := alcCreateContext(Device, nil);
  if Context = nil then
    showmessage('No Context..?');
  alcMakeContextCurrent(Context);
end;

procedure VirtualInitialize;
var
  i: integer;
  x: array[1..2048] of Aluint;
begin
  PhySourcesAvail := -1;

  fillchar(x, sizeof(x), 0);

  // allocate as much sources as possible
  for i := 1 to 2048 do
  begin
    alGetError;
    AlGenSources(1, @x[i]);
    if alGetError <> AL_NO_ERROR then
    begin
      PhySourcesAvail := i - 1;
      break;
    end;
  end;

  // if apparently there are more than 2048.. if this ever happens, assume 2048
  if PhySourcesAvail = -1 then PhySourcesAvail:= 2048;

  // free all sources
  alDeleteSources(PhySourcesAvail, @x);

  PhySourcesUsed := 0;
end;

procedure VirtualModifyListener(Position, Velocity: Vector;
  listener: TListenerOrientation);
begin
  ListenerPosition := Position;
  ListenerVelocity := Velocity;
  ListenerOrientationarray := listener;

  //  ListenerPosition:= VectorMultiply(ListenerPosition, 2);
  AlListenerfv(AL_POSITION, @ListenerPosition);
  AlListenerfv(AL_VELOCITY, @ListenerVelocity);
  AlListenerfv(AL_ORIENTATION, @ListenerOrientationarray);
end;

end.

