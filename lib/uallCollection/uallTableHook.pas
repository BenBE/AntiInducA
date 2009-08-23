unit uallTableHook;

{$I 'uallCollection.inc'}

interface

uses windows, uallKernel;

function InstructionLength(pAddr: Pointer): DWord; stdcall;
function UnhookApijmp(pNewFunction: Pointer): Boolean; stdcall;
function HookApiJmp(pOrigFunction, pCallbackFunction: Pointer; var pNewFunction: Pointer): Boolean; stdcall;

implementation


const
  OP_eins = -1;
  OPnull = 0;
  OPeins = 1;
  OPzwei = 2;
  OPdrei = 3;
  OPvier = 4;
  OPfuenf = 5;
  OPsechs = 6;
  OPsieben = 7;
  OPacht = 8;
  OPneun = 9;
  OPzehn = 10;
  OPtable7 = 11;  // table2 +1  (ok)
  OPtable2 = 12;  //            (ok)
  OPtable5 = 15;  //            (ok)
  OPtable6 = 16;  // table2 +4  (ok)
  OPtableFF = 17; //            (ok)
  OPtableF7 = 18; //            (ok)
  OPtable8 = 19;  //            (ok)
  OPtableFE = 20; //            (ok)
  OPtableDD = 21; //            (ok)
  OPtable0F = 22; //            (ok)
  OPtable = 23;
  OPtable3 = 24;

var firsttable: array[$00..$FF] of integer =

(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPnull  ,OPtable0F,
OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPtable ,OPnull  ,OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPtable ,OPnull  ,
OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPtable ,OPnull  ,OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPvier  ,OPtable ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPtable2,OPtable2,OPtable ,OPtable ,OPtable ,OPtable ,OPvier  ,OPtable6,OPeins  ,OPtable7,OPnull  ,OPnull,  OPnull  ,OPnull  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,
OPtable7,OPtable6,OPtable7,OPtable7,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPsechs ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,
OPtable7,OPzwei  ,OPzwei  ,OPnull  ,OPtable2,OPtable2,OPtable7,OPtable6,OPvier  ,OPnull  ,OPzwei  ,OPnull  ,OPnull  ,OPeins  ,OPnull  ,OPnull  ,
OPtable2,OPtable2,OPtable2,OPtable2,OPeins  ,OPeins  ,OPnull  ,OPnull  ,OPtable2,OPtable2,OPtable2,OPtable2,OPtable2,OPtableDD,OPtable2,OPtable2,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPvier  ,OPvier  ,OPsechs ,OPeins  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPtable ,OPnull  ,OPtable ,OPtable ,OPnull  ,OPnull  ,OPtable8,OPtableF7,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPtableFE,OPtableFF);


var thirdtable: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPvier  ,OPnull  ,OPnull);

var secondtable: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPtable3  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPtable3  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPtable3  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPtable3  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  );

var fftable: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins );

var f7table: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPacht  ,OPvier  ,OPvier  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPfuenf ,OPeins  ,OPeins  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPsechs ,OPfuenf ,OPfuenf ,OPfuenf ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPacht  ,OPacht  ,OPacht  ,OPacht  ,OPneun  ,OPacht  ,OPacht  ,OPacht  ,OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPsechs ,OPfuenf ,OPfuenf ,OPfuenf ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull);

var table8: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPfuenf ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPfuenf ,OPeins  ,OPeins  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPdrei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPzwei  ,OPdrei  ,OPzwei  ,OPzwei  ,OPzwei  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPsechs ,OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPfuenf ,OPsechs ,OPfuenf ,OPfuenf ,OPfuenf ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull);

var fetable: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins);

var ddtable: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPeins  ,OPvier  ,OPnull  ,OPnull  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPeins  ,OPzwei  ,OPeins  ,OPeins  ,OPeins  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,OP_eins ,
OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPvier  ,OPfuenf ,OPnull ,OPvier  ,OPvier  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OP_eins  ,OPnull  ,OPnull ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,
OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OPnull  ,OP_eins ,OPnull  ,OPnull  );

var table0F: array[$00..$FF] of integer =
(
  // $0     $1      $2        $3      $4       $5      $6        $7       $8        $9      $a       $b       $c       $d       $e      $f
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OP_eins  ,OP_eins  ,OPnull   ,OP_eins  ,OPnull   ,OP_eins  ,OP_eins  ,OPnull   ,OP_eins  ,OPtable  ,OPnull   ,OPtable ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins  ,OP_eins ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier   ,OPvier  ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull    ,OPnull  ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull   ,OPnull  ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,
OP_eins  ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OPtable2 ,OP_eins);

function InstructionLength(pAddr: Pointer): DWord; stdcall;
var dwCount: DWord;
    finished: Boolean;
    b: PByte;
    x: Integer;
begin
  finished := false;
  dwCount := 1;
  b := paddr;
  x := firsttable[b^];
  repeat
    case x of
      -1..10:
      begin
        inc(dwCount,x);
        finished := true;
      end;
      OPtable:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        x := firsttable[b^];
      end;
      OPtable2:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        x := secondtable[b^];
      end;
      OPtable7:
      begin
        inc(dwCount,2);
        b := pointer(integer(b)+1);
        x := secondtable[b^];
      end;
      OPtable6:
      begin
        inc(dwCount,5);
        b := pointer(integer(b)+1);
        x := secondtable[b^];
      end;
      OPtableFF:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,FFtable[b^]);
        finished := true;
      end;
      OPtableF7:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,F7table[b^]);
        finished := true;
      end;
      OPtableFE:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,FEtable[b^]);
        finished := true;
      end;
      OPtableDD:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,DDtable[b^]);
        finished := true;
      end;
      OPtable8:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,table8[b^]);
        finished := true;
      end;
      OPtable3:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        inc(dwCount,thirdtable[b^]);
        finished := true;
      end;
      OPtable0f:
      begin
        inc(dwCount);
        b := pointer(integer(b)+1);
        x := table0f[b^];
      end else finished := true
    end;
  until finished;
  result := dwCount;
end;


function UnhookAPIJMP(pNewFunction: Pointer): Boolean; stdcall;
var dwOldProtect: DWord;
    dwCount: DWord;
    dwAllCount: DWord;
    JmpCode: PJmpCode;
    pNew: Pointer;
begin
  result := false;
  dwAllCount := 0;
  pNew := pNewFunction;
  repeat
    if (isBadReadPtr(pNew,12)) then
      Exit;
    dwCount := InstructionLength(pNew);
    pNew := pointer(cardinal(pNew)+dwCount);
    inc(dwAllCount,dwCount);
  until dwAllCount >= sizeof(TJmpCode);

  JmpCode := pNew;
  if (JmpCode^.bPush <> $68) or
     (JmpCode^.bRet <> $C3) then
    Exit;

  JmpCode := Pointer(DWord(JmpCode^.pAddr)-dwAllCount);
  if (JmpCode^.bPush <> $68) or
     (JmpCode^.bRet <> $C3) then
    Exit;

  if (not VirtualProtect(JmpCode,dwAllCount,PAGE_EXECUTE_READWRITE, dwOldProtect)) then
    Exit;

  CopyMemory(JmpCode,pNewFunction,dwAllCount);
  Result := true;
  VirtualProtect(JmpCode,dwAllCount,dwOldProtect, dwOldProtect);
  VirtualFree(pNewFunction,dwAllCount+sizeof(TJmpCode),MEM_RELEASE);
end;

function HookAPIJMP(pOrigFunction,pCallbackFunction: pointer; var pNewFunction: Pointer): Boolean; stdcall;
var dwCount: DWord;
    dwAllCount: DWord;
    dwOldProtect: DWord;
    JmpCode: TJmpCode;
    pOrig: Pointer;
begin
  Result := false;
  JmpCode.bPush := $68;
  JmpCode.bRet := $C3;
  dwAllCount := 0;
  pOrig := pOrigFunction;
  repeat
    if (isBadReadPtr(pOrig,12)) then
      Exit;

    dwCount := InstructionLength(pOrig);
    pOrig := pointer(DWord(pOrig)+dwCount);
    inc(dwAllCount,dwCount);
  until (dwAllCount >= SizeOf(TJmpCode));

  if (not VirtualProtect(pOrigFunction,dwAllCount,PAGE_EXECUTE_READWRITE,dwOldProtect)) then
    Exit;
    
  pNewFunction := VirtualAlloc(nil,dwAllCount+SizeOf(TJmpCode),MEM_RESERVE or MEM_COMMIT,PAGE_EXECUTE_READWRITE);

  CopyMemory(pNewFunction,pOrigFunction,dwAllCount);
  JmpCode.pAddr := Pointer(DWord(pOrigFunction)+dwAllCount);
  Copymemory(pointer(DWord(pNewFunction)+dwAllCount),@JmpCode,SizeOf(TJmpCode));

  JmpCode.pAddr := pCallbackFunction;
  copymemory(pOrigFunction,@JmpCode,SizeOf(JmpCode));

  result := true;
  VirtualProtect(pOrigFunction,dwAllCount,dwOldProtect,dwOldProtect);
end;

end.
