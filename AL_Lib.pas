{ *********************************************************************** }
{                                                                         }
{ OpenAL AL and ALC headers, translation from C headers                   }
{                                                                         }
{ Copyright (c) 2001-2005 Jernej L.                                       }
{                                                                         }
{ *********************************************************************** }

unit AL_Lib;

interface

{
  OpenAL cross platform audio library
  Copyright (C) 1999-2000 by authors.
  This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.
 
  This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.
 
  You should have received a copy of the GNU Library General Public
   License along with this library; if not, write to the
   Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA  02111-1307, USA.
  Or go to http://www.gnu.org/copyleft/lgpl.html
 }

const

  openal = 'OpenAL32.dll';

  AL_MAX_CHANNELS	= 4;
  AL_MAX_SOURCES	= 32;

//                                                                              AL header

Type

{ 8-bit boolean }
ALboolean= boolean;
PALboolean= ^boolean;

{ character }
ALchar= char;
PALchar = Pchar;

{ signed 8-bit 2's complement integer }
ALbyte= byte;
PALbyte= ^byte;

{ unsigned 8-bit integer }
ALubyte = byte;
PALubyte = ^byte;

{ signed 16-bit 2's complement integer }
ALshort= shortint;
PALshort= ^shortint;

{ unsigned 16-bit integer }
ALushort= word;
PALushort= ^word;

{ signed 32-bit 2's complement integer }
ALint= integer;
PALint= ^integer;

{ unsigned 32-bit integer }
ALuint= longword;
PALuint= ^longword;

{ non-negative 32-bit binary integer size }
ALsizei= integer;
PALsizei= ^integer;

{ enumerated 32-bit value }
ALenum= integer;
PALenum= ^integer;

{ 32-bit IEEE754 floating-point }
ALfloat= single;
PALfloat= ^single;

{ 64-bit IEEE754 floating-point }
ALdouble= double;
PALdouble= ^double;

{ void type (for opaque pointers only) }
ALvoid= pointer;
PALvoid= pointer;

const
{ Enumerant values begin at column 50. No tabs. }

{ bad value }
AL_INVALID                                = -1;

AL_NONE                                   = 0;

{ Boolean False. }
AL_FALSE                                  = 0;

{ Boolean True. }
AL_TRUE                                   = 1;

{ Indicate Source has relative coordinates. }
AL_SOURCE_RELATIVE                        = $202;



{
  Directional source, inner cone angle, in degrees.
  Range:    [0-360]
  Default:  360
 }
AL_CONE_INNER_ANGLE                       = $1001;

{
  Directional source, outer cone angle, in degrees.
  Range:    [0-360]
  Default:  360
 }
AL_CONE_OUTER_ANGLE                       = $1002;

{
  Specify the pitch to be applied, either at source,
   or on mixer results, at listener.
  Range:   [0.5-2.0]
  Default: 1.0
 }
AL_PITCH                                  = $1003;
  
{ 
  Specify the current location in three dimensional space.
  OpenAL, like OpenGL, uses a right handed coordinate system,
   where in a frontal default view X (thumb) points right,
   Y points up (index finger), and Z points towards the
   viewer/camera (middle finger).
  To switch from a left handed coordinate system, flip the
   sign on the Z coordinate.
  Listener position is always in the world coordinate system.
 }
AL_POSITION                               = $1004;
  
{ Specify the current direction. }
AL_DIRECTION                              = $1005;
  
{ Specify the current velocity in three dimensional space. }
AL_VELOCITY                               = $1006;

{
  Indicate whether source is looping.
  Type: ALboolean?
  Range:   [AL_TRUE, AL_FALSE]
  Default: FALSE.
 }
AL_LOOPING                                = $1007;

{
  Indicate the buffer to provide sound samples. 
  Type: ALuint.
  Range: any valid Buffer id.
 }
AL_BUFFER                                 = $1009;
  
{
  Indicate the gain (volume amplification) applied. 
  Type:   ALfloat.
  Range:  ]0.0-  ]
  A value of 1.0 means un-attenuated/unchanged.
  Each division by 2 equals an attenuation of -6dB.
  Each multiplicaton with 2 equals an amplification of +6dB.
  A value of 0.0 is meaningless with respect to a logarithmic
   scale; it is interpreted as zero volume - the channel
   is effectively disabled.
 }
AL_GAIN                                   = $100A;

{
  Indicate minimum source attenuation
  Type: ALfloat
  Range:  [0.0 - 1.0]
 
  Logarthmic
 }
AL_MIN_GAIN                               = $100D;

{
  Indicate maximum source attenuation
  Type: ALfloat
  Range:  [0.0 - 1.0]
 
  Logarthmic
 }
AL_MAX_GAIN                               = $100E;

{
  Indicate listener orientation.
 
  at/up 
 }
AL_ORIENTATION                            = $100F;

{
  Specify the channel mask. (Creative)
  Type: ALuint
  Range: [0 - 255]
 }
AL_CHANNEL_MASK                           = $3000;


{
  Source state information.
 }
AL_SOURCE_STATE                           = $1010;
AL_INITIAL                                = $1011;
AL_PLAYING                                = $1012;
AL_PAUSED                                 = $1013;
AL_STOPPED                                = $1014;

{
  Buffer Queue params
 }
AL_BUFFERS_QUEUED                         = $1015;
AL_BUFFERS_PROCESSED                      = $1016;

{
  Source buffer position information
 }
AL_SEC_OFFSET                             = $1024;
AL_SAMPLE_OFFSET                          = $1025;
AL_BYTE_OFFSET                            = $1026;

{
  Source type (Static, Streaming or undetermined)
  Source is Static if a Buffer has been attached using AL_BUFFER
  Source is Streaming if one or more Buffers have been attached using alSourceQueueBuffers
  Source is undetermined when it has the NULL buffer attached
 }
AL_SOURCE_TYPE                            = $1027;
AL_STATIC                                 = $1028;
AL_STREAMING                              = $1029;
AL_UNDETERMINED                           = $1030;

{ Sound samples: format specifier. }
AL_FORMAT_MONO8                           = $1100;
AL_FORMAT_MONO16                          = $1101;
AL_FORMAT_STEREO8                         = $1102;
AL_FORMAT_STEREO16                        = $1103;

{
  source specific reference distance
  Type: ALfloat
  Range:  0.0 - +inf
 
  At 0.0, no distance attenuation occurs.  Default is
  1.0.
 }
AL_REFERENCE_DISTANCE                     = $1020;

{
  source specific rolloff factor
  Type: ALfloat
  Range:  0.0 - +inf
 
 }
AL_ROLLOFF_FACTOR                         = $1021;

{
  Directional source, outer cone gain.
 
  Default:  0.0
  Range:    [0.0 - 1.0]
  Logarithmic
 }
AL_CONE_OUTER_GAIN                        = $1022;

{
  Indicate distance above which sources are not
  attenuated using the inverse clamped distance model.
 
  Default: +inf
  Type: ALfloat
  Range:  0.0 - +inf
 }
AL_MAX_DISTANCE                           = $1023;

{ 
  Sound samples: frequency, in units of Hertz [Hz].
  This is the number of samples per second. Half of the
   sample frequency marks the maximum significant
   frequency component.
 }
AL_FREQUENCY                              = $2001;
AL_BITS                                   = $2002;
AL_CHANNELS                               = $2003;
AL_SIZE                                   = $2004;

{
  Buffer state.
 
  Not supported for public use (yet).
 }
AL_UNUSED                                 = $2010;
AL_PENDING                                = $2011;
AL_PROCESSED                              = $2012;


{ Errors: No Error. }
AL_NO_ERROR                               = AL_FALSE;

{ 
  Invalid Name paramater passed to AL call.
 }
AL_INVALID_NAME                           = $A001;

{ 
  Invalid parameter passed to AL call.
 }
AL_ILLEGAL_ENUM                           = $A002;
AL_INVALID_ENUM                           = $A002;

{ 
  Invalid enum parameter value.
 }
AL_INVALID_VALUE                          = $A003;

{ 
  Illegal call.
 }
AL_ILLEGAL_COMMAND                        = $A004;
AL_INVALID_OPERATION                      = $A004;

  
{
  No mojo.
 }
AL_OUT_OF_MEMORY                          = $A005;


{ Context strings: Vendor Name. }
AL_VENDOR                                 = $B001;
AL_VERSION                                = $B002;
AL_RENDERER                               = $B003;
AL_EXTENSIONS                             = $B004;

{ Global tweakage. }

{
  Doppler scale.  Default 1.0
 }
AL_DOPPLER_FACTOR                         = $C000;

{
  Tweaks speed of propagation.
 }
AL_DOPPLER_VELOCITY                       = $C001;

{
  Speed of Sound in units per second
 }
AL_SPEED_OF_SOUND                         = $C003;

{
  Distance models
 
  used in conjunction with DistanceModel
 
  implicit: NONE, which disances distance attenuation.
 }
AL_DISTANCE_MODEL                         = $D000;
AL_INVERSE_DISTANCE                       = $D001;
AL_INVERSE_DISTANCE_CLAMPED               = $D002;
AL_LINEAR_DISTANCE                        = $D003;
AL_LINEAR_DISTANCE_CLAMPED                = $D004;
AL_EXPONENT_DISTANCE                      = $D005;
AL_EXPONENT_DISTANCE_CLAMPED              = $D006;


{
  Renderer State management
 }
Procedure alEnable( capability : ALenum ); cdecl; external openal;

Procedure alDisable( capability : ALenum ); cdecl; external openal;

Function alIsEnabled( capability : ALenum ): ALboolean; cdecl; external openal;


{
  State retrieval
 }
Function alGetString( param : ALenum ): PALchar; cdecl; external openal;

Procedure alGetBooleanv( param: ALenum ; data : PALboolean ); cdecl; external openal;

Procedure alGetIntegerv( param: ALenum ; data : PALint ); cdecl; external openal;

Procedure alGetFloatv( param: ALenum ; data : PALfloat ); cdecl; external openal;

Procedure alGetDoublev( param: ALenum ; data : PALdouble ); cdecl; external openal;

Function alGetBoolean( param : ALenum ): ALboolean; cdecl; external openal;

Function alGetInteger( param : ALenum ): ALint; cdecl; external openal;

Function alGetFloat( param : ALenum ): ALfloat; cdecl; external openal;

Function alGetDouble( param : ALenum ): ALdouble; cdecl; external openal;


{
  Error support.
  Obtain the most recent error generated in the AL state machine.
 }

Function alGetError: ALenum; cdecl; external openal;

{ 
  Extension support.
  Query for the presence of an extension; and obtain any appropriate
  function pointers and enum values.
 }
Function alIsExtensionPresent( const PALcharextname ): ALboolean; cdecl; external openal;

Function alGetProcAddress( const name: PALchar ): ALvoid; cdecl; external openal;

Function alGetEnumValue( const PALcharename ): ALenum; cdecl; external openal;


{
  LISTENER
  Listener represents the location and orientation of the
  'user' in 3D-space.

  Properties include: -

  Gain         AL_GAIN         ALfloat
  Position     AL_POSITION     ALfloat[3]
  Velocity     AL_VELOCITY     ALfloat[3]
  Orientation  AL_ORIENTATION  ALfloat[6] (Forward then Up vectors)
}

{
  Set Listener parameters
 }
Procedure alListenerf( param: ALenum ; value: ALfloat ); cdecl; external openal;

Procedure alListener3f( param: ALenum ; value1: ALfloat; value2: ALfloat; value3 : ALfloat); cdecl; external openal;

Procedure alListenerfv( param: ALenum ; const values : PALfloat); cdecl; external openal;

Procedure alListeneri( param: ALenum ; value : ALint); cdecl; external openal;

Procedure alListener3i( param: ALenum ; value1: ALint; value2: ALint; value3 : ALint); cdecl; external openal;

Procedure alListeneriv( param: ALenum ; const values : PALint); cdecl; external openal;

{
  Get Listener parameters
 }
Procedure alGetListenerf( param: ALenum ; value : PALfloat); cdecl; external openal;

Procedure alGetListener3f( param: ALenum ; value1: PALfloat; value2: PALfloat; value3 : PALfloat); cdecl; external openal;

Procedure alGetListenerfv( param: ALenum ; values : PALfloat); cdecl; external openal;

Procedure alGetListeneri( param: ALenum ; value : PALint); cdecl; external openal;

Procedure alGetListener3i( param: ALenum ; value1: PALint; value2: PALint; value3 : PALint); cdecl; external openal;

Procedure alGetListeneriv( param: ALenum ; values : PALint); cdecl; external openal;


{
  SOURCE
  Sources represent individual sound objects in 3D-space.
  Sources take the PCM data provided in the specified Buffer;
  apply Source-specific modifications; and then
  submit them to be mixed according to spatial arrangement etc.
  
  Properties include: -
 
  Gain                              AL_GAIN                 ALfloat
  Min Gain                          AL_MIN_GAIN             ALfloat
  Max Gain                          AL_MAX_GAIN             ALfloat
  Position                          AL_POSITION             ALfloat[3]
  Velocity                          AL_VELOCITY             ALfloat[3]
  Direction                         AL_DIRECTION            ALfloat[3]
  Head Relative Mode                AL_SOURCE_RELATIVE      ALint (AL_TRUE or AL_FALSE)
  Reference Distance                AL_REFERENCE_DISTANCE   ALfloat
  Max Distance                      AL_MAX_DISTANCE         ALfloat
  RollOff Factor                    AL_ROLLOFF_FACTOR       ALfloat
  Inner Angle                       AL_CONE_INNER_ANGLE     ALint or ALfloat
  Outer Angle                       AL_CONE_OUTER_ANGLE     ALint or ALfloat
  Cone Outer Gain                   AL_CONE_OUTER_GAIN      ALint or ALfloat
  Pitch                             AL_PITCH                ALfloat
  Looping                           AL_LOOPING              ALint (AL_TRUE or AL_FALSE)
  MS Offset                         AL_MSEC_OFFSET          ALint or ALfloat
  Byte Offset                       AL_BYTE_OFFSET          ALint or ALfloat
  Sample Offset                     AL_SAMPLE_OFFSET        ALint or ALfloat
  Attached Buffer                   AL_BUFFER               ALint
  State (Query only)                AL_SOURCE_STATE         ALint
  Buffers Queued (Query only)       AL_BUFFERS_QUEUED       ALint
  Buffers Processed (Query only)    AL_BUFFERS_PROCESSED    ALint
 }

{ Create Source objects }
Procedure alGenSources( n: ALsizei; sources : PALuint); cdecl; external openal;

{ Delete Source objects }
Procedure alDeleteSources( n: ALsizei; const sources : PALuint); cdecl; external openal;

{ Verify a handle is a valid Source } 
Function alIsSource( sid : ALuint): ALboolean; cdecl; external openal;

{
  Set Source parameters
 }
Procedure alSourcef( sid: ALuint; param: ALenum ; value : ALfloat); cdecl; external openal;

Procedure alSource3f( sid: ALuint; param: ALenum ; value1: ALfloat; value2: ALfloat; value3 : ALfloat); cdecl; external openal;

Procedure alSourcefv( sid: ALuint; param: ALenum ; const values: PALfloat ); cdecl; external openal;

Procedure alSourcei( sid: ALuint; param: ALenum ; value : ALint); cdecl; external openal;

Procedure alSource3i( sid: ALuint; param: ALenum ; value1: ALint; value2: ALint; value3 : ALint); cdecl; external openal;

Procedure alSourceiv( sid: ALuint; param: ALenum ; const values : PALint); cdecl; external openal;

{
  Get Source parameters
 }
Procedure alGetSourcef( sid: ALuint; param: ALenum ; value : PALfloat); cdecl; external openal;

Procedure alGetSource3f( sid: ALuint; param: ALenum ; value1: PALfloat; value2: PALfloat; value3: PALfloat); cdecl; external openal;

Procedure alGetSourcefv( sid: ALuint; param: ALenum ; values : PALfloat); cdecl; external openal;

Procedure alGetSourcei( sid: ALuint;  param: ALenum ; value : PALint); cdecl; external openal;

Procedure alGetSource3i( sid: ALuint; param: ALenum ; value1: PALint; value2: PALint; value3: PALint); cdecl; external openal;

Procedure alGetSourceiv( sid: ALuint;  param: ALenum ; values : PALint); cdecl; external openal;


{
  Source vector based playback calls
 }

{ Play; replay; or resume (if paused) a list of Sources }
Procedure alSourcePlayv( ns: ALsizei; const sids : PALuint); cdecl; external openal;

{ Stop a list of Sources }
Procedure alSourceStopv( ns: ALsizei; const sids : PALuint); cdecl; external openal;

{ Rewind a list of Sources }
Procedure alSourceRewindv( ns: ALsizei; const sids : PALuint); cdecl; external openal;

{ Pause a list of Sources }
Procedure alSourcePausev( ns: ALsizei; const sids : PALuint); cdecl; external openal;

{
  Source based playback calls
 }

{ Play; replay; or resume a Source }
Procedure alSourcePlay( sid : ALuint); cdecl; external openal;

{ Stop a Source }
Procedure alSourceStop( sid : ALuint); cdecl; external openal;

{ Rewind a Source (set playback postiton to beginning) }
Procedure alSourceRewind( sid : ALuint); cdecl; external openal;

{ Pause a Source }
Procedure alSourcePause( sid : ALuint); cdecl; external openal;

{
  Source Queuing 
 }
Procedure alSourceQueueBuffers( sid: ALuint; numEntries: ALsizei; const bids : PALuint); cdecl; external openal;

Procedure alSourceUnqueueBuffers( sid: ALuint; numEntries: ALsizei; bids : PALuint); cdecl; external openal;


{
  BUFFER
  Buffer objects are storage space for sample data.
  Buffers are referred to by Sources. One Buffer can be used
  by multiple Sources.

  Properties include: -

  Frequency (Query only)    AL_FREQUENCY      ALint
  Size (Query only)         AL_SIZE           ALint
  Bits (Query only)         AL_BITS           ALint
  Channels (Query only)     AL_CHANNELS       ALint
 }

{ Create Buffer objects }
Procedure alGenBuffers( n: ALsizei; buffers : PALuint); cdecl; external openal;

{ Delete Buffer objects }
Procedure alDeleteBuffers( n: ALsizei; const buffers : PALuint); cdecl; external openal;

{ Verify a handle is a valid Buffer }
Function alIsBuffer( bid : ALuint): ALboolean; cdecl; external openal;

{ Specify the data to be copied into a buffer }
Procedure alBufferData( bid: ALuint; format: ALenum ; data: PALvoid ; size: ALsizei ; freq : ALsizei); cdecl; external openal;


{
  Set Buffer parameters
 }

Procedure alBufferf( bid: ALuint; param : ALenum ; value : ALfloat); cdecl; external openal;

Procedure alBuffer3f( bid: ALuint; param: ALenum ; value1: ALfloat; value2: ALfloat; value3 : ALfloat); cdecl; external openal;

Procedure alBufferfv( bid: ALuint; param: ALenum ; const values : PALfloat ); cdecl; external openal;

Procedure alBufferi( bid: ALuint; param: ALenum ; value : ALint); cdecl; external openal;

Procedure alBuffer3i( bid: ALuint; param: ALenum ; value1: ALint; value2: ALint; value3 : ALint); cdecl; external openal;

Procedure alBufferiv( bid: ALuint; param: ALenum ; const values : PALint ); cdecl; external openal;

{
  Get Buffer parameters
 }
Procedure alGetBufferf( bid: ALuint; param: ALenum ; value : PALfloat); cdecl; external openal;

Procedure alGetBuffer3f( bid: ALuint; param: ALenum ; value1: PALfloat; value2: PALfloat; value3: PALfloat); cdecl; external openal;

Procedure alGetBufferfv( bid: ALuint; param: ALenum ; values : PALfloat); cdecl; external openal;

Procedure alGetBufferi( bid: ALuint; param: ALenum ; value : PALint); cdecl; external openal;

Procedure alGetBuffer3i( bid: ALuint; param: ALenum ; value1: PALint; value2: PALint; value3: PALint); cdecl; external openal;

Procedure alGetBufferiv( bid: ALuint; param: ALenum ; values : PALint); cdecl; external openal;


{
  Global Parameters
 }
Procedure alDopplerFactor( value : ALfloat); cdecl; external openal;

Procedure alDopplerVelocity( value : ALfloat); cdecl; external openal;

Procedure alSpeedOfSound( value : ALfloat); cdecl; external openal;

Procedure alDistanceModel( distanceModel : ALenum ); cdecl; external openal;

//                                                                              // ALC header

Type

ALCdevice= pointer;
PALCdevice= ^pointer;

ALCcontext= pointer;
PALCcontext= ^pointer;

{ 8-bit boolean }
ALCboolean= boolean;
PALCboolean= ^boolean;

{ character }
ALCchar= char;
PALCchar = Pchar;

{ signed 8-bit 2's complement integer }
ALCbyte= byte;
PALCbyte= ^byte;

{ unsigned 8-bit integer }
ALCubyte = byte;
PALCubyte = ^byte;

{ signed 16-bit 2's complement integer }
ALCshort= shortint;
PALCshort= ^shortint;

{ unsigned 16-bit integer }
ALCushort= word;
PALCushort= ^word;

{ signed 32-bit 2's complement integer }
ALCint= integer;
PALCint= ^integer;

{ unsigned 32-bit integer }
ALCuint= longword;
PALCuint= ^longword;

{ non-negative 32-bit binary integer size }
ALCsizei= integer;
PALCsizei= ^integer;

{ enumerated 32-bit vALCue }
ALCenum= integer;
PALCenum= ^integer;

{ 32-bit IEEE754 floating-point }
ALCfloat= single;
PALCfloat= ^single;

{ 64-bit IEEE754 floating-point }
ALCdouble= double;
PALCdouble= ^double;

{ void type (for opaque pointers only) }
ALCvoid= pointer;
PALCvoid= ^pointer;

const
{ Enumerant values begin at column 50. No tabs. }

{ bad value }
ALC_INVALID                              = 0;

{ Boolean False. }
ALC_FALSE                                = 0;

{ Boolean True. }
ALC_TRUE                                 = 1;

{ 
  followed by <int> Hz
 }
ALC_FREQUENCY                            = $1007;

{ 
  followed by <int> Hz
 }
ALC_REFRESH                              = $1008;

{ 
  followed by AL_TRUE, AL_FALSE
 }
ALC_SYNC                                 = $1009;

{ 
  followed by <int> Num of requested Mono (3D) Sources
 }
ALC_MONO_SOURCES                         = $1010;

{ 
  followed by <int> Num of requested Stereo Sources
 }
ALC_STEREO_SOURCES                       = $1011;

{ 
  errors
 }

{ 
  No error
 }
ALC_NO_ERROR                             = ALC_FALSE;

{ 
  No device
 }
ALC_INVALID_DEVICE                       = $A001;

{ 
  invalid context ID
 }
ALC_INVALID_CONTEXT                      = $A002;

{ 
  bad enum
 }
ALC_INVALID_ENUM                         = $A003;

{ 
  bad value
 }
ALC_INVALID_VALUE                        = $A004;

{ 
  Out of memory.
 }
ALC_OUT_OF_MEMORY                        = $A005;


{ 
  The Specifier string for default device
 }
ALC_DEFAULT_DEVICE_SPECIFIER             = $1004;
ALC_DEVICE_SPECIFIER                     = $1005;
ALC_EXTENSIONS                           = $1006;

ALC_MAJOR_VERSION                        = $1000;
ALC_MINOR_VERSION                        = $1001;

ALC_ATTRIBUTES_SIZE                      = $1002;
ALC_ALL_ATTRIBUTES                       = $1003;

{ 
  Capture extension
 }
ALC_CAPTURE_DEVICE_SPECIFIER             = $310;
ALC_CAPTURE_DEFAULT_DEVICE_SPECIFIER     = $311;
ALC_CAPTURE_SAMPLES                      = $312;

{
  Context Management
 }
Function alcCreateContext( device: PALCdevice; const attrlist: PALCint ): PALCcontext; cdecl; external openal;

Function alcMakeContextCurrent( context: PALCcontext ): ALCboolean; cdecl; external openal;

Procedure alcProcessContext( context: ALCcontext ); cdecl; external openal;

Procedure alcSuspendContext( context: ALCcontext ); cdecl; external openal;

Procedure alcDestroyContext( context: ALCcontext ); cdecl; external openal;

Function alcGetCurrentContext: ALCcontext; cdecl; external openal;

Function alcGetContextsDevice( context: PALCcontext ): ALCdevice; cdecl; external openal;


{
  Device Management
 }
Function alcOpenDevice( const devicename: PALCchar ): ALCdevice; cdecl; external openal;

Function alcCloseDevice( device: PALCdevice ): ALCboolean; cdecl; external openal;


{
  Error support.
  Obtain the most recent Context error
 }
Function alcGetError( device: PALCdevice ): ALCenum; cdecl; external openal;


{ 
  Extension support.
  Query for the presence of an extension, and obtain any appropriate
  function pointers and enum values. cdecl; external openal;
 }
Function alcIsExtensionPresent( device: PALCdevice; const extname: PALCchar ): ALCboolean; cdecl; external openal;

Procedure alcGetProcAddress( device: PALCdevice; const funcname: PALCchar ); cdecl; external openal;

Function alcGetEnumValue( device: ALCdevice; const enumname: PALCchar ): ALCenum; cdecl; external openal;


{
  Query functions
 }
Function alcGetString( device: PALCdevice ; param: ALCenum ): ALCchar; cdecl; external openal;

Procedure alcGetIntegerv( device: PALCdevice; param: ALCenum; size: ALCsizei; data: PALCint ); cdecl; external openal;


{
  Capture functions
 }
Function alcCaptureOpenDevice( const devicename: PALCchar; frequency: ALCuint; format: ALCenum; buffersize: ALCsizei ): PALCdevice; cdecl; external openal;

Function alcCaptureCloseDevice( device: PALCdevice ): ALCboolean; cdecl; external openal;

Procedure alcCaptureStart( device: PALCdevice ); cdecl; external openal;

Procedure alcCaptureStop( device: PALCdevice ); cdecl; external openal;

Procedure alcCaptureSamples( device: PALCdevice ; buffer: PALCvoid ; samples: ALCsizei ); cdecl; external openal;

implementation

end.

