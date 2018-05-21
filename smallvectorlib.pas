{ *********************************************************************** }
{                                                                         }
{ Very easy Very basic vector unit for VirtualOpenAL demo app.            }
{ Prototype 1A 2009200X                                                   }
{                                                                         }
{ Notes:                                                                  }
{ replace bidirectional bubble sort with something.. better?              }
{                                                                         }
{ Copyright (c) 2001-2006 Jernej L.                                       }
{                                                                         }
{ *********************************************************************** }

unit smallvectorlib;

interface

type

  // a vector for general processing
  Vector = packed record
    case boolean of
      True: (x, y, z: single);
      False: (componens: array[0..2] of single);
  end;
  Pvector = ^Vector;

function vectordistance(const v1, v2: Vector): single;
function makevector(const x, y, z: single): Vector;
function VectorSize(const vector: Vector): single;
function SubVectors(const First, second: Vector): Vector;

implementation

function VectorSize(const vector: Vector): single;
begin
  Result := sqrt(vector.x * vector.x + vector.y * vector.y + vector.z * vector.z);
end;

function makevector(const x, y, z: single): Vector;
begin
  Result.x := x;
  Result.y := y;
  Result.z := z;
end;

function SubVectors(const First, second: Vector): Vector;
begin
result:= makevector(first.x - second.x, first.y - second.y, first.z - second.z);
end;

function vectordistance(const v1, v2: Vector): single;
var
  tmp: Vector;
begin
  tmp    := SubVectors(v2, v1);
  Result := VectorSize(tmp);
end;

end.
