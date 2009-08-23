unit uallDisasmEx;

{$I 'uallCollection.inc'}

interface

uses uallUtil;

const regX:  array[0..7] of pchar = ('EAX','ECX','EDX','EBX','ESP','EBP','ESI','EDI');
      regLH: array[0..7] of pchar = ('AL' ,'CL' ,'DL' ,'BL' ,'AH' ,'CH' ,'DH' ,'BH');
      regLHS:array[0..7] of pchar = ('AX' ,'CX' ,'DX' ,'BX' ,'SP' ,'BP' ,'SI' ,'DI');
      regX2: array[0..7] of pchar = ('EAX','ECX','EDX','EBX','§','<DW>','ESI','EDI');
      regX3: array[0..7] of pchar = ('EAX','ECX','EDX','EBX','§','EBP','ESI','EDI');
      d0:    array[0..7] of pchar = ('ROL','ROR','RCL','RCR','SHL','SHR','SAL','SAR');
      d8:    array[0..7] of pchar = ('FADD','FMUL','FCOM','FCOMP','FSUB','FSUBR','FDIV','FDIVR');
      d9:    array[0..7] of pchar = ('FLD','DB','FST','FSTP','FLDENV','FLDCW','FSTENV','FSTCW');

      dA1:   array[0..7] of pchar = ('FIADD','FIMUL','FICOM','FICOMP','FISUB','FISUBR','FIDIV','FIDIVR');
      dA2:   array[0..7] of pchar = ('FCMOVB','FCMOVE','FCMOVBE','FCMOVU','FISUB','FISUBR','FIDIV','FIDIVR');

      dB1:   array[0..7] of pchar = ('FILD','DB','FIST','FISTP','DB','FLD','DB','FSTP');
      dB2:   array[0..7] of pchar = ('FCMOVNB','FCMOVNE','FCMOVNBE','FCMOVNU','','FUCOMI','FCOMI','SGT');
      dB3:   array[0..7] of pchar = ('FENI','FDISI','FCLEX','FNINIT','FSETPM','DB','DB','DB');

      dD1:   array[0..7] of pchar = ('FLD','DB','FST','FSTP','FRSTOR','DB','FSAVE','SFTSW');
      dD2:   array[0..7] of pchar = ('FFREE','DB','FST','FSTP','FUCOM','FUCOMP','FSAVE','SFTSW');

      dE1:   array[0..7] of pchar = ('FIADD','FIMUL','FICOM','FICOMP','FISUB','FISUBR','FIDIV','FIDIVR');
      dE2:   array[0..7] of pchar = ('FADDP','FMULP','FICOM','DB','FSUBRP','FSUBP','FDIVRP','FDIVP');

      dF1:   array[0..7] of pchar = ('FILD','DB','FIST','FISTP','TBLD','FILD','FBSTP','FISTP');
      dF2:   array[0..7] of pchar = ('FFREEP','DB','FIST','FISTP','FBLD','DB','FCOMIP','FISTP');
      i80:   array[0..7] of pchar = ('ADD','OR','ADC','SBB','AND','SUB','XOR','CMP');
      i8c:   array[0..7] of pchar = ('ES','CS','SS','DS','FS','GS','HS','IS');
      if6:   array[0..7] of pchar = ('TEST','TEST ','NOT','NEG','MUL','IMUL','DIV','IDIV');
      iff:   array[0..7] of pchar = ('INC','DEC ','CALL','CALL','JMP','JMP','PUSH','DB');

      i0F00: array[0..7] of pchar = ('SLDT','STR','LLDT','LTR','VERR','VERW','DB','DB');

function Table0F00(b: byte): string;
function TableFF(b: byte): string;
function TableF6(b: byte): string;
function TableF7(b: byte): string;

function Table63(b: byte): string;

function Table80(b: byte): string;
function Table81(b: byte): string;
function Table82(b: byte): string;
function Table83(b: byte): string;
function Table8C(b: byte): string;

function TableD8(b: byte): string;
function TableDA(b: byte): string;
function TableDD(b: byte): string;
function TableDE(b: byte): string;
function TableDB(b: byte): string;
function TableD9(b: byte): string;
function TableDF(b: byte): string;

function TableReg(b: byte): string;
function TableRegComb(b: byte): string;
function TableRegByte(b: byte): string;
function TableRegByteP(b: byte): string;
function TableRegLH(b: byte): string;

function TableD0RegLH(b: byte): string;
function TableD0Reg(b: byte): string;



implementation



function Table0F00(b: byte): string;
begin
  result := '';
  if (i0f00[(b div 8) mod 8] = 'DB') then result := 'DB' else
  if (b < $40) then
    result := i0f00[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := i0f00[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := i0f00[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := i0f00[(b div 8) mod 8]+' '+regLHS[((b and $1F) mod 8)];
end;

function TableFF(b: byte): string;
begin
  result := '';
  if (iff[(b div 8) mod 8] = 'DB') then result := 'DB' else
  if (b < $40) then
    result := iff[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := iff[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := iff[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := iff[(b div 8) mod 8]+' '+regX2[((b and $1F) mod 8)];
end;

function TableF6(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := if6[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := if6[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := if6[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := if6[(b div 8) mod 8]+' '+regLH[((b and $1F) mod 8)];
  if copy(result,1,4) = 'TEST' then result := result+', <B>';
end;

function TableF7(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := if6[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := if6[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := if6[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := if6[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)];
  if copy(result,1,4) = 'TEST' then result := result+', <DW>';
end;

function Table8C(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+'], '+i8c[(b div 8) mod 8] else
  if (b < $80) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>], '+i8c[(b div 8) mod 8] else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#DW>], '+i8c[(b div 8) mod 8] else
    result := regX[((b and $1F) mod 8)]+', '+i8c[(b div 8) mod 8];
end;

function Table80(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := i80[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+'], <B>' else
  if (b < $80) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>], <B>' else
  if (b < $C0) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>], <B>' else
    result := i80[(b div 8) mod 8]+' '+regLH[((b and $1F) mod 8)]+', <B>';
end;

function Table83(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := i80[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+'], <B>' else
  if (b < $80) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>], <B>' else
  if (b < $C0) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>], <B>' else
    result := i80[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)]+', <B>';
end;

function Table81(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := i80[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+'], <DW>' else
  if (b < $80) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>], <DW>' else
  if (b < $C0) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>], <DW>' else
    result := i80[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)]+', <DW>';
end;

function Table82(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := i80[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+'], <#B>' else
  if (b < $80) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>], <#B>' else
  if (b < $C0) then
    result := i80[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>], <#B>' else
    result := i80[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)]+', <#B>';
end;

function TableDF(b: byte): string;
begin
  result := '';
  if (dF1[(b div 8) mod 8] = 'DB') or (dF2[(b div 8) mod 8] = 'DB') then
    result := 'DB' else
  if (b < $40) then
    result := de1[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := de1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := de1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
  if ((b >= $C0) and (b < $C8)) then
    result := de2[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')' else
  if (b = $E0) then
    result := 'FSTSW AX' else
    result := de2[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)];
end;

function TableDE(b: byte): string;
begin
  result := '';
  if (de2[(b div 8) mod 8] = 'DB') then
    result := 'DB' else
  if (b < $40) then
    result := de1[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := de1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := de1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := de2[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')';
end;

function TableDD(b: byte): string;
begin
  result := '';
  if (dd2[(b div 8) mod 8] = 'DB') or (dd1[(b div 8) mod 8] = 'DB')  then
    result := 'DB' else
  if (b < $40) then
    result := dd1[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := dd1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := dd1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
  if (b < $F0) then
    result := dd2[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')' else
    result := dd2[(b div 8) mod 8]+' '+regX[(b and $1F) mod 8];
end;

function TableDB(b: byte): string;
begin
  result := '';
  if (db1[(b div 8) mod 8] = 'DB') or (db3[(b div 8) mod 8] = 'DB') then
    result := 'DB' else
  if (b < $40) then
    result := db1[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := db1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := db1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
  if (b < $E0) or (b > $E7) then
    result := db2[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')' else
    result := db3[(b and $1F) mod 8];
end;

function TableRegComb(b: byte): string;
var i, j: integer;
begin
  j := 2;
  for i := 1 to (b div $40) do j := j*2;
  j := j div 2;
  if ((b+$20) div 8) mod 8 = 0 then
    result := regX[(b and $0F) mod 8] else
  if (b < $40) then
    result := regX2[(b and $0F) mod 8]+'+'+regX[((b div 8) mod 8)] else
    result := regX2[(b and $0F) mod 8]+'+'+regX[((b div 8) mod 8)]+'*'+
       inttostr(j);
end;

function TableRegLH(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+'], '+regLH[(b div 8) mod 8] else
  if (b < $80) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>], '+regLH[(b div 8) mod 8] else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#DW>], '+regLH[(b div 8) mod 8] else
    result := regLH[((b and $1F) mod 8)]+', '+regLH[(b div 8) mod 8];
end;

function Table63(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+'], '+regLHS[(b div 8) mod 8] else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>], '+regLHS[(b div 8) mod 8] else
    result := regLHS[((b and $1F) mod 8)]+', '+regLHS[(b div 8) mod 8];
end;

function TableD0RegLH(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := d0[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := d0[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := d0[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := d0[(b div 8) mod 8]+' '+regLH[((b and $1F) mod 8)];
end;

function TableD0Reg(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := d0[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := d0[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := d0[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := d0[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)];
end;

function TableD8(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := d8[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := d8[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := d8[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := d8[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')';
end;

function TableDA(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := dA1[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := dA1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := dA1[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
  if (b < $E0) then
    result := dA2[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')' else
    result := dA2[(b div 8) mod 8]+' '+regX[((b and $1F) mod 8)];
end;

function TableD9(b: byte): string;
begin
  result := '';
  if (d9[(b div 8) mod 8] = 'DB') then
    result := 'DB' else
  if (b < $40) then
    result := d9[(b div 8) mod 8]+' ['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := d9[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := d9[(b div 8) mod 8]+' ['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := d9[(b div 8) mod 8]+' ST('+inttostr((b and $1F) mod 8)+')';
end;

function TableRegByteP(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := regLH[((b and $1F) mod 8)];
end;

function TableReg(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+'], '+regX[(b div 8) mod 8] else
  if (b < $80) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>], '+regX[(b div 8) mod 8] else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#DW>], '+regX[(b div 8) mod 8] else
    result := regX[((b and $1F) mod 8)]+', '+regX[(b div 8) mod 8];
end;

function TableRegByte(b: byte): string;
begin
  result := '';
  if (b < $40) then
    result := '['+regX2[((b and $1F) mod 8)]+']' else
  if (b < $80) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#B>]' else
  if (b < $C0) then
    result := '['+regX3[((b and $1F) mod 8)]+'+<#DW>]' else
    result := regX[((b and $1F) mod 8)];
end;

end.
