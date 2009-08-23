unit uallDisasm;

{$I 'uallCollection.inc'}

interface

uses windows, uallUtil, uallDisasmEx, uallKernel;

function InstructionInfo(pAddr: Pointer; var sInstructionName: String; var dwSize: DWord): Boolean; stdcall;

implementation

type
  PInstruction = ^TInstruction;
  PInstructionTable = ^TInstructionTable;
  TInstruction = packed record
                   InstrByte: Byte;
                   Name     : PChar;
                 end;

  TInstructiontable = array[0..$FF] of TInstruction;

var InstructionTable: TInstructionTable;
    Table0F: TInstructionTable;
    Initialized: Boolean = False;

const
    TUndefined: TInstruction = (instrbyte: $00; name: 'undefined');

    Taddal    : TInstruction = (instrbyte: $04; name: 'add al, <b>'    );
    Taddeax   : TInstruction = (instrbyte: $05; name: 'add eax, <dw>'  );
    Tpushes   : TInstruction = (instrbyte: $06; name: 'push es'        );
    Tpopes    : TInstruction = (instrbyte: $07; name: 'pop es'         );
    Toral     : TInstruction = (instrbyte: $0C; name: 'or al, <b>'     );
    Toreax    : TInstruction = (instrbyte: $0D; name: 'or eax, <dw>'   );
    Tpushcs   : TInstruction = (instrbyte: $0E; name: 'push cs'        );

    Tadcal    : TInstruction = (instrbyte: $14; name: 'adc al, <b>'    );
    Tadceax   : TInstruction = (instrbyte: $15; name: 'adc eax, <dw>'  );
    Tpushss   : TInstruction = (instrbyte: $16; name: 'push ss'        );
    Tpopss    : TInstruction = (instrbyte: $17; name: 'pop ss'         );
    Tsbbal    : TInstruction = (instrbyte: $1C; name: 'sbb al, <b>'    );
    Tsbbeax   : TInstruction = (instrbyte: $1D; name: 'sbb eax, <dw>'  );
    Tpushds   : TInstruction = (instrbyte: $1E; name: 'push ds'        );
    Tpopds    : TInstruction = (instrbyte: $1F; name: 'pop ds'         );

    Tandal    : TInstruction = (instrbyte: $24; name: 'and al, <b>'    );
    Tandeax   : TInstruction = (instrbyte: $25; name: 'and eax, <dw>'  );
    Tdaa      : TInstruction = (instrbyte: $27; name: 'daa'            );
    Tsubal    : TInstruction = (instrbyte: $2C; name: 'sub al, <b>'    );
    Tsubeax   : TInstruction = (instrbyte: $2D; name: 'sub eax, <dw>'  );
    Tdas      : TInstruction = (instrbyte: $2F; name: 'das'            );

    Txoral    : TInstruction = (instrbyte: $34; name: 'xor al, <b>'    );
    Txoreax   : TInstruction = (instrbyte: $35; name: 'and xor, <dw>'  );
    Taaa      : TInstruction = (instrbyte: $37; name: 'aaa'            );
    Tcmpal    : TInstruction = (instrbyte: $3C; name: 'cmp al, <b>'    );
    Tcmpeax   : TInstruction = (instrbyte: $3D; name: 'cmp eax, <dw>'  );
    Taas      : TInstruction = (instrbyte: $3F; name: 'aas'            );

    Tinceax   : TInstruction = (instrbyte: $40; name: 'inc eax'      );
    Tincecx   : TInstruction = (instrbyte: $41; name: 'inc ecx'      );
    Tincedx   : TInstruction = (instrbyte: $42; name: 'inc edx'      );
    Tincebx   : TInstruction = (instrbyte: $43; name: 'inc ebx'      );
    Tincesp   : TInstruction = (instrbyte: $44; name: 'inc esp'      );
    Tincebp   : TInstruction = (instrbyte: $45; name: 'inc ebp'      );
    Tincesi   : TInstruction = (instrbyte: $46; name: 'inc esi'      );
    Tincedi   : TInstruction = (instrbyte: $47; name: 'inc edi'      );
    Tdeceax   : TInstruction = (instrbyte: $48; name: 'dec eax'      );
    Tdececx   : TInstruction = (instrbyte: $49; name: 'dec ecx'      );
    Tdecedx   : TInstruction = (instrbyte: $4A; name: 'dec edx'      );
    Tdecebx   : TInstruction = (instrbyte: $4B; name: 'dec ebx'      );
    Tdecesp   : TInstruction = (instrbyte: $4C; name: 'dec esp'      );
    Tdecebp   : TInstruction = (instrbyte: $4D; name: 'dec ebp'      );
    Tdecesi   : TInstruction = (instrbyte: $4E; name: 'dec esi'      );
    Tdecedi   : TInstruction = (instrbyte: $4F; name: 'dec edi'      );

    Tpusheax  : TInstruction = (instrbyte: $50; name: 'push eax'      );
    Tpushecx  : TInstruction = (instrbyte: $51; name: 'push ecx'      );
    Tpushedx  : TInstruction = (instrbyte: $52; name: 'push edx'      );
    Tpushebx  : TInstruction = (instrbyte: $53; name: 'push ebx'      );
    Tpushesp  : TInstruction = (instrbyte: $55; name: 'push esp'      );
    Tpushebp  : TInstruction = (instrbyte: $55; name: 'push ebp'      );
    Tpushesi  : TInstruction = (instrbyte: $56; name: 'push esi'      );
    Tpushedi  : TInstruction = (instrbyte: $57; name: 'push edi'      );
    Tpopeax   : TInstruction = (instrbyte: $58; name: 'pop eax'      );
    Tpopecx   : TInstruction = (instrbyte: $59; name: 'pop ecx'      );
    Tpopedx   : TInstruction = (instrbyte: $5A; name: 'pop edx'      );
    Tpopebx   : TInstruction = (instrbyte: $5B; name: 'pop ebx'      );
    Tpopesp   : TInstruction = (instrbyte: $5C; name: 'pop esp'      );
    Tpopebp   : TInstruction = (instrbyte: $5D; name: 'pop ebp'      );
    Tpopesi   : TInstruction = (instrbyte: $5E; name: 'pop esi'      );
    Tpopedi   : TInstruction = (instrbyte: $5F; name: 'pop edi'      );

    Tpushad   : TInstruction = (instrbyte: $60; name: 'pushad'      );
    Tpopad    : TInstruction = (instrbyte: $61; name: 'popad'       );
    Tpushbyte : TInstruction = (instrbyte: $6A; name: 'push <b>'    );
    Tinsb     : TInstruction = (instrbyte: $6C; name: 'insb'        );
    Tinsd     : TInstruction = (instrbyte: $6D; name: 'insd'        );
    Toutsb    : TInstruction = (instrbyte: $6E; name: 'outsb'       );
    Toutsd    : TInstruction = (instrbyte: $6F; name: 'outsd'       );
    Tpush     : TInstruction = (instrbyte: $68; name: 'push <dw>'   );

    Tjo       : TInstruction = (instrbyte: $70; name: 'jo <#b>'     );
    Tjno      : TInstruction = (instrbyte: $71; name: 'jno <#b>'    );
    Tjb       : TInstruction = (instrbyte: $72; name: 'jb <#b>'     );
    Tjnb      : TInstruction = (instrbyte: $73; name: 'jnb <#b>'    );
    Tje       : TInstruction = (instrbyte: $74; name: 'je <#b>'     );
    Tjne      : TInstruction = (instrbyte: $75; name: 'jne <#b>'    );
    Tjbe      : TInstruction = (instrbyte: $76; name: 'jbe <#b>'    );
    Tjnbe     : TInstruction = (instrbyte: $77; name: 'jnbe <#b>'   );
    Tjs       : TInstruction = (instrbyte: $78; name: 'js <#b>'     );
    Tjns      : TInstruction = (instrbyte: $79; name: 'jns <#b>'    );
    Tjp       : TInstruction = (instrbyte: $7A; name: 'jp <#b>'     );
    Tjnp      : TInstruction = (instrbyte: $7B; name: 'jnp <#b>'    );
    Tjl       : TInstruction = (instrbyte: $7C; name: 'jl <#b>'     );
    Tjnl      : TInstruction = (instrbyte: $7D; name: 'jnl <#b>'    );
    Tjle      : TInstruction = (instrbyte: $7E; name: 'jle <#b>'    );
    Tjnle     : TInstruction = (instrbyte: $7F; name: 'jnle <#b>'   );

    Tnop        : TInstruction = (instrbyte: $90; name: 'nop'             );
    Txchgeaxecx : TInstruction = (instrbyte: $91; name: 'xchg eax, ecx'   );
    Txchgeaxedx : TInstruction = (instrbyte: $92; name: 'xchg eax, edx'   );
    Txchgeaxebx : TInstruction = (instrbyte: $93; name: 'xchg eax, ebx'   );
    Txchgeaxesp : TInstruction = (instrbyte: $94; name: 'xchg eax, esp'   );
    Txchgeaxebp : TInstruction = (instrbyte: $95; name: 'xchg eax, ebp'   );
    Txchgeaxesi : TInstruction = (instrbyte: $96; name: 'xchg eax, esi'   );
    Txchgeaxedi : TInstruction = (instrbyte: $97; name: 'xchg eax, edi'   );
    Tcwde       : TInstruction = (instrbyte: $98; name: 'cwde'      );
    Tcdq        : TInstruction = (instrbyte: $99; name: 'cdq'       );
    Twait       : TInstruction = (instrbyte: $9B; name: 'wait'      );
    Tpushfd     : TInstruction = (instrbyte: $9C; name: 'pushfd'    );
    Tpopfd      : TInstruction = (instrbyte: $9D; name: 'popfd'    );
    Tsahf       : TInstruction = (instrbyte: $9E; name: 'sahf'      );
    Tlahf       : TInstruction = (instrbyte: $9F; name: 'lahf'      );

    Tmovaldw  : TInstruction = (instrbyte: $A0; name: 'mov al, [<dw>]'       );
    Tmoveaxdw : TInstruction = (instrbyte: $A1; name: 'mov eax, [<dw>]'      );
    Tmovdwal  : TInstruction = (instrbyte: $A2; name: 'mov [<dw>], al'       );
    Tmovdweax : TInstruction = (instrbyte: $A3; name: 'mov [<dw>], eax'      );
    Tmovsb    : TInstruction = (instrbyte: $A4; name: 'movsb');
    Tmovsd    : TInstruction = (instrbyte: $A5; name: 'movsd');
    Tcmpsb    : TInstruction = (instrbyte: $A6; name: 'cmpsb'      );
    Tcmpsd    : TInstruction = (instrbyte: $A7; name: 'cmpsd'      );
    Ttestal   : TInstruction = (instrbyte: $A8; name: 'test al, <b>'        );
    Ttesteax  : TInstruction = (instrbyte: $A9; name: 'test eax, <dw>'      );
    Tstossb   : TInstruction = (instrbyte: $AA; name: 'stosb'      );
    Tstossd   : TInstruction = (instrbyte: $AB; name: 'stosd'      );
    Tlodsb    : TInstruction = (instrbyte: $AC; name: 'lodsb'      );
    Tlodsd    : TInstruction = (instrbyte: $AD; name: 'lodsd'      );
    Tscasb    : TInstruction = (instrbyte: $AE; name: 'scasb'      );
    Tscasd    : TInstruction = (instrbyte: $AF; name: 'scasd'      );

    Tmoval    : TInstruction = (instrbyte: $B0; name: 'mov al, <b>'        );
    Tmovcl    : TInstruction = (instrbyte: $B1; name: 'mov cl, <b>'        );
    Tmovdl    : TInstruction = (instrbyte: $B2; name: 'mov dl, <b>'        );
    Tmovbl    : TInstruction = (instrbyte: $B3; name: 'mov bl, <b>'        );
    Tmovah    : TInstruction = (instrbyte: $B4; name: 'mov ah, <b>'        );
    Tmovch    : TInstruction = (instrbyte: $B5; name: 'mov ch, <b>'        );
    Tmovdh    : TInstruction = (instrbyte: $B6; name: 'mov dh, <b>'        );
    Tmovbh    : TInstruction = (instrbyte: $B7; name: 'mov bh, <b>'        );
    Tmoveax   : TInstruction = (instrbyte: $B8; name: 'mov eax, <dw>'      );
    Tmovecx   : TInstruction = (instrbyte: $B9; name: 'mov ecx, <dw>'      );
    Tmovedx   : TInstruction = (instrbyte: $BA; name: 'mov edx, <dw>'      );
    Tmovebx   : TInstruction = (instrbyte: $BB; name: 'mov ebx, <dw>'      );
    Tmovesp   : TInstruction = (instrbyte: $BC; name: 'mov esp, <dw>'      );
    Tmovebp   : TInstruction = (instrbyte: $BD; name: 'mov ebp, <dw>'      );
    Tmovesi   : TInstruction = (instrbyte: $BE; name: 'mov esi, <dw>'      );
    Tmovedi   : TInstruction = (instrbyte: $BF; name: 'mov edi, <dw>'      );

    Tretw     : TInstruction = (instrbyte: $C2; name: 'ret <w>'              );
    Tret      : TInstruction = (instrbyte: $C3; name: 'ret'                  );
    Tenter    : TInstruction = (instrbyte: $C8; name: 'enter <w>, <b>'       );
    Tleave    : TInstruction = (instrbyte: $C9; name: 'leave'                );
    Tretw2    : TInstruction = (instrbyte: $CA; name: 'ret <w>'              );
    Tret2     : TInstruction = (instrbyte: $CB; name: 'ret'                  );
    Tbp       : TInstruction = (instrbyte: $CC; name: 'breakpoint'           );
    Tint      : TInstruction = (instrbyte: $CD; name: 'int <b>'              );
    Tinto     : TInstruction = (instrbyte: $CE; name: 'into   '              );
    Tiret     : TInstruction = (instrbyte: $CF; name: 'iret'                 );

    Taam      : TInstruction = (instrbyte: $D4; name: 'aam <b>'              );
    Taad      : TInstruction = (instrbyte: $D5; name: 'aad <b>'              );
    Tdbd6     : TInstruction = (instrbyte: $D6; name: '$DB'                  );
    Txlat     : TInstruction = (instrbyte: $D7; name: 'xlat'                 );

    Tloopne   : TInstruction = (instrbyte: $E0; name: 'loopne <#b>'            );
    Tloope    : TInstruction = (instrbyte: $E1; name: 'loope <#b>'             );
    Tloop     : TInstruction = (instrbyte: $E2; name: 'loop <#b>'              );
    Tjcxz     : TInstruction = (instrbyte: $E3; name: 'jcxz <#b>'              );
    Tinal     : TInstruction = (instrbyte: $E4; name: 'in al, <b>'             );
    Tineax    : TInstruction = (instrbyte: $E5; name: 'in eax, <b>'            );
    Toutal    : TInstruction = (instrbyte: $E6; name: 'in <b>, al'             );
    Touteax   : TInstruction = (instrbyte: $E7; name: 'in <b>, eax'            );
    Tcall     : TInstruction = (instrbyte: $E8; name: 'call <#dw>'           );
    Tjmp      : TInstruction = (instrbyte: $E9; name: 'jmp <#dw>'            );
    Tjpwdw    : TInstruction = (instrbyte: $EA; name: 'jp <w> : <dw>'        );
    Tjmpshotz : TInstruction = (instrbyte: $EB; name: 'jmp <#b>'             );
    Tinaldx   : TInstruction = (instrbyte: $EC; name: 'in al, dx'            );
    Tineaxdx  : TInstruction = (instrbyte: $ED; name: 'in eax, dx'           );
    Toutdxal  : TInstruction = (instrbyte: $EE; name: 'out dx, al'           );
    Toutdxeax : TInstruction = (instrbyte: $EF; name: 'out dx, eax'          );

    Tdbf1     : TInstruction = (instrbyte: $F1; name: '$DB'          );
    Thlt      : TInstruction = (instrbyte: $F4; name: 'hlt'          );
    Tcmc      : TInstruction = (instrbyte: $F5; name: 'cmc'          );
    Tclc      : TInstruction = (instrbyte: $F8; name: 'clc'          );
    Tstc      : TInstruction = (instrbyte: $F9; name: 'stc'          );
    Tcli      : TInstruction = (instrbyte: $FA; name: 'cli'          );
    Tsti      : TInstruction = (instrbyte: $FB; name: 'sti'          );
    Tcld      : TInstruction = (instrbyte: $FC; name: 'cld'          );
    Tstd      : TInstruction = (instrbyte: $FD; name: 'std'          );
    Tdbfe     : TInstruction = (instrbyte: $FE; name: '$DB'          );

//
    Tadd1     : TInstruction = (instrbyte: $00; name: 'add %'  );   // xx1
    Tadd2     : TInstruction = (instrbyte: $02; name: 'add %!' );   // xx1
    Tadd3     : TInstruction = (instrbyte: $01; name: 'add %'  );   // xx1
    Tadd4     : TInstruction = (instrbyte: $03; name: 'add %!' );   // xx1

    Tadc1     : TInstruction = (instrbyte: $10; name: 'adc %'  );   // xx1
    Tadc2     : TInstruction = (instrbyte: $12; name: 'adc %!' );   // xx1
    Tadc3     : TInstruction = (instrbyte: $11; name: 'adc %'  );   // xx1
    Tadc4     : TInstruction = (instrbyte: $13; name: 'adc %!' );   // xx1

    Tand1     : TInstruction = (instrbyte: $20; name: 'and %'  );   // xx1
    Tand2     : TInstruction = (instrbyte: $22; name: 'and %!' );   // xx1
    Tand3     : TInstruction = (instrbyte: $21; name: 'and %'  );   // xx1
    Tand4     : TInstruction = (instrbyte: $23; name: 'and %!' );   // xx1

    Txor1     : TInstruction = (instrbyte: $30; name: 'xor %'  );   // xx1
    Txor2     : TInstruction = (instrbyte: $32; name: 'xor %!' );   // xx1
    Txor3     : TInstruction = (instrbyte: $31; name: 'xor %'  );   // xx1
    Txor4     : TInstruction = (instrbyte: $33; name: 'xor %!' );   // xx1

    Tor1     : TInstruction = (instrbyte: $08; name: 'or %'  );   // xx1
    Tor2     : TInstruction = (instrbyte: $0A; name: 'or %!' );   // xx1
    Tor3     : TInstruction = (instrbyte: $09; name: 'or %'  );   // xx1
    Tor4     : TInstruction = (instrbyte: $0B; name: 'or %!' );   // xx1

    Tsbb1     : TInstruction = (instrbyte: $18; name: 'sbb %'  );   // xx1
    Tsbb2     : TInstruction = (instrbyte: $1A; name: 'sbb %!' );   // xx1
    Tsbb3     : TInstruction = (instrbyte: $19; name: 'sbb %'  );   // xx1
    Tsbb4     : TInstruction = (instrbyte: $1B; name: 'sbb %!' );   // xx1

    Tsub1     : TInstruction = (instrbyte: $28; name: 'sub %'  );   // xx1
    Tsub2     : TInstruction = (instrbyte: $2A; name: 'sub %!' );   // xx1
    Tsub3     : TInstruction = (instrbyte: $29; name: 'sub %'  );   // xx1
    Tsub4     : TInstruction = (instrbyte: $2B; name: 'sub %!' );   // xx1

    Tcmp1     : TInstruction = (instrbyte: $38; name: 'cmp %'  );   // xx1
    Tcmp2     : TInstruction = (instrbyte: $3A; name: 'cmp %!' );   // xx1
    Tcmp3     : TInstruction = (instrbyte: $39; name: 'cmp %'  );   // xx1
    Tcmp4     : TInstruction = (instrbyte: $3B; name: 'cmp %!' );   // xx1

    Ttest1    : TInstruction = (instrbyte: $84; name: 'test %'  );   // xx1
    Ttest2    : TInstruction = (instrbyte: $85; name: 'test %'  );   // xx1
    Txchg1    : TInstruction = (instrbyte: $86; name: 'xchg %'  );   // xx1
    Txchg2    : TInstruction = (instrbyte: $87; name: 'xchg %'  );   // xx1

    Tmov1     : TInstruction = (instrbyte: $88; name: 'mov %'   );   // xx1
    Tmov2     : TInstruction = (instrbyte: $8A; name: 'mov %!'  );   // xx1
    Tmov3     : TInstruction = (instrbyte: $89; name: 'mov %'   );   // xx1
    Tmov4     : TInstruction = (instrbyte: $8B; name: 'mov %!'  );   // xx1

    Tmov5     : TInstruction = (instrbyte: $8C; name: 'mov °8C'   );   // xx1
    Tmov6     : TInstruction = (instrbyte: $8E; name: 'mov °8C!'  );   // xx1

    Tcall2    : TInstruction = (instrbyte: $9A; name: 'call <w>:<dw>'  );   // xx1

    Tlea      : TInstruction = (instrbyte: $8D; name: 'lea %!'  );
    Tpop      : TInstruction = (instrbyte: $8F; name: 'pop &';  );
    Td0       : TInstruction = (instrbyte: $D0; name: '~, 1';  );
    Td1       : TInstruction = (instrbyte: $D1; name: '~, 1';  );
    Td2       : TInstruction = (instrbyte: $D2; name: '~, cl';  );
    Td3       : TInstruction = (instrbyte: $D3; name: '~, cl';  );
    TC0       : TInstruction = (instrbyte: $C0; name: '~, <b>';  );
    TC1       : TInstruction = (instrbyte: $C1; name: '~, <b>';  );

    Tarpl     : TInstruction = (instrbyte: $63; name: 'arpl °63'  );   // xx1
    Td8       : TInstruction = (instrbyte: $D8; name: '°D8';  );
    Td9       : TInstruction = (instrbyte: $D9; name: '°D9';  );
    Tda       : TInstruction = (instrbyte: $DA; name: '°DA';  );
    Tdb       : TInstruction = (instrbyte: $DB; name: '°DB';  );
    Tdc       : TInstruction = (instrbyte: $DC; name: '°D8';  );
    Tdd       : TInstruction = (instrbyte: $DD; name: '°DD';  );
    Tde       : TInstruction = (instrbyte: $DE; name: '°DE';  );
    Tdf       : TInstruction = (instrbyte: $DF; name: '°DF';  );
    Tles      : TInstruction = (instrbyte: $C4; name: 'les °C4'  );   // xx1
    Tlds      : TInstruction = (instrbyte: $C5; name: 'lds °C4'  );   // xx1
    Timul     : TInstruction = (instrbyte: $6B; name: 'imul °C4, <b>';  );
    Timul2    : TInstruction = (instrbyte: $69; name: 'imul °C4, <dw>';  );
    Tbound    : TInstruction = (instrbyte: $62; name: 'bound °C4';  );
    Tmov7     : TInstruction = (instrbyte: $C6; name: 'mov &, <b>'   );   // xx1
    Tmov8     : TInstruction = (instrbyte: $C7; name: 'mov &, <dw>'  );   // xx1
    Tf6       : TInstruction = (instrbyte: $F6; name: '°F6';  );
    Tf7       : TInstruction = (instrbyte: $F7; name: '°F7';  );
    Tff       : TInstruction = (instrbyte: $FF; name: '°FF';  );
    T80       : TInstruction = (instrbyte: $80; name: '°80';  );
    T81       : TInstruction = (instrbyte: $81; name: '°81';  );
    T82       : TInstruction = (instrbyte: $82; name: '°82';  );
    T83       : TInstruction = (instrbyte: $83; name: '°83';  );


    Trepnz    : TInstruction = (instrbyte: $F2; name: 'repnz |';  );
    Trep      : TInstruction = (instrbyte: $F3; name: 'rep |';  );
    Tlock     : TInstruction = (instrbyte: $F0; name: 'lock |';  );

    Tcs       : TInstruction = (instrbyte: $2E; name: '-cs|';  );
    Tds       : TInstruction = (instrbyte: $3E; name: '-ds|';  );
    Tfs       : TInstruction = (instrbyte: $64; name: '-fs|';  );
    Tgs       : TInstruction = (instrbyte: $65; name: '-gs|';  );

    T67       : TInstruction = (instrbyte: $67; name: ';|';  );
    T66       : TInstruction = (instrbyte: $66; name: '+|';  );

    TTable0F  : TInstruction = (instrbyte: $0F; name: '';  );


//     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
// 00   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 10   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 20   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 30   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 40   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 50   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 60   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 70   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 80   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 90   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// A0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// B0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// C0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// D0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// E0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// F0   !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !


//Table0F:
//     00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
// 00               !  !  !  !  !  !  !  !
// 10
// 20
// 30
// 40
// 50
// 60
// 70
// 80  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !  !
// 90
// A0  !  !  !                 !  !  !
// B0
// C0
// D0
// E0
// F0  !                                            !


    Tclts     : TInstruction = (instrbyte: $06; name: 'clts';        );
    Tinvd     : TInstruction = (instrbyte: $08; name: 'invd';        );
    Twbinvd   : TInstruction = (instrbyte: $09; name: 'wbinvd';      );
    Tuds      : TInstruction = (instrbyte: $0B; name: 'uds';         );
    Tfemms    : TInstruction = (instrbyte: $0E; name: 'uds';         );
    Tjo2      : TInstruction = (instrbyte: $80; name: 'jo <#dw>';    );
    Tjno2     : TInstruction = (instrbyte: $81; name: 'jno <#dw>');
    Tjb2      : TInstruction = (instrbyte: $82; name: 'jb <#dw>';    );
    Tjnb2     : TInstruction = (instrbyte: $83; name: 'jnb <#dw>');
    Tje2      : TInstruction = (instrbyte: $84; name: 'je <#dw>';    );
    Tjne2     : TInstruction = (instrbyte: $85; name: 'jne <#dw>');
    Tjbe2     : TInstruction = (instrbyte: $86; name: 'jbe <#dw>');
    Tjnbe2    : TInstruction = (instrbyte: $87; name: 'jnbe <#dw>';  );
    Tjs2      : TInstruction = (instrbyte: $88; name: 'js <#dw>';    );
    Tjns2     : TInstruction = (instrbyte: $89; name: 'jns <#dw>');
    Tjp2      : TInstruction = (instrbyte: $8A; name: 'jp <#dw>';    );
    Tjnp2     : TInstruction = (instrbyte: $8B; name: 'jnp <#dw>');
    Tjl2      : TInstruction = (instrbyte: $8C; name: 'jl <#dw>';    );
    Tjnl2     : TInstruction = (instrbyte: $8D; name: 'jnl <#dw>');
    Tjle2     : TInstruction = (instrbyte: $8E; name: 'jle <#dw>');
    Tjnle2    : TInstruction = (instrbyte: $8F; name: 'jnle <#dw>';  );

    Tpushfs   : TInstruction = (instrbyte: $A0; name: 'push fs';     );
    Tpopfs    : TInstruction = (instrbyte: $A1; name: 'pop fs';      );
    Tcpuid    : TInstruction = (instrbyte: $A2; name: 'cpuid';       );
    Tpushgs   : TInstruction = (instrbyte: $A8; name: 'push gs';     );
    Tpopgs    : TInstruction = (instrbyte: $A9; name: 'pop gs';      );
    Trsm      : TInstruction = (instrbyte: $AA; name: 'rsm';         );

    T0F00      : TInstruction = (instrbyte: $00; name: '0F00';       );

function ChangeASM(sInstr: string): string;
var
  dwPos: DWord;
begin
  while Pos(' ', sInstr) > 0 do
    Delete(sInstr,pos(' ',sInstr),1);
  dwPos := Pos(',',sInstr);
  if (dwPos = 0) then
    Result := sInstr else
    Result := Copy(sInstr,dwPos+1,Length(sInstr))+', '+Copy(sInstr,1,dwPos-1);
end;

procedure changeHex(var s: String; var pAddr: Pointer; var dwSize: DWord);
var
  t: string;
  posf, lenf: integer;
  b2: PByte;
  c2: PDWord;
  d2: PWord;
begin
  while (pos('<', s) > 0) do
  begin
    posf := pos('<',s);
    lenf := pos('>',s)-posf+1;
    t := Copy(s,posf,lenf);
    Delete(s,posf,lenf);

    if (t = '<#B>') then
    begin
      b2 := pointer(integer(pAddr)+1);
      
      if (b2^ >= (high(byte) div 2)) then
      begin
        b2^ := high(byte)-b2^+1;
        Insert('-0x'+inttohex(b2^,2),s,posf);
        if length(s) >= posf-1 then
          if s[posf-1] = '+' then delete(s,posf-1,1);
      end else
        Insert('0x'+inttohex(b2^,2),s,posf);

      inc(dwSize,1);
      pAddr := pointer(integer(pAddr)+1);
    end else
    if (t = '<B>') then
    begin
      b2 := pointer(integer(pAddr)+1);
      insert('0x'+inttohex(b2^,2),s,posf);
      inc(dwSize,1);
      pAddr := pointer(integer(pAddr)+1);
    end else
    if (t = '<#DW>') then
    begin
      c2 := pointer(integer(pAddr)+1);

      if (c2^ >= (high(cardinal) div 2)) then
      begin
        c2^ := high(cardinal)-c2^+1;
        insert('-0x'+IntToHex(c2^,8),s,posf);
        if length(s) >= posf-1 then
          if s[posf-1] = '+' then delete(s,posf-1,1);
      end else
        insert('0x'+inttohex(c2^,8),s,posf);


      inc(dwSize,4);
      pAddr := pointer(integer(pAddr)+4);
    end else
    if (t = '<DW>') then
    begin
      c2 := pointer(integer(pAddr)+1);
      insert('0x'+inttohex(c2^,8),s,posf);
      inc(dwSize,4);
      pAddr := pointer(integer(pAddr)+4);
    end else
    if (t = '<W>') then
    begin
      d2 := pointer(integer(pAddr)+1);
      insert('0x'+inttohex(d2^,4),s,posf);
      inc(dwSize,2);
      pAddr := pointer(integer(pAddr)+2);
    end else
    if (t = '<#W>') then
    begin
      d2 := pointer(integer(pAddr)+1);

      if (d2^ >= (high(word) div 2)) then
      begin
        d2^ := high(word)-d2^+1;
        insert('-0x'+inttohex(d2^,4),s,posf);
        if length(s) >= posf-1 then
          if s[posf-1] = '+' then delete(s,posf-1,1);
      end else
        insert('0x'+inttohex(d2^,4),s,posf);

      Inc(dwSize,2);
      pAddr := Pointer(DWord(pAddr)+2);
    end;
  end;
  inc(dwSize,1);
end;

procedure changeReg(var s: String; var pAddr: Pointer; var dwSize: DWord; b: Byte);
var
  posf: integer;
  mn: string;
begin
  posf := pos('%',s);
  if (posf > 0) then
  begin
    delete(s,posf,1);
    if (b mod 2 <> 0) then
      mn := TableReg(pbyte(integer(pAddr)+1)^) else
      mn := TableRegLH(pbyte(integer(pAddr)+1)^);
    if (posf <= length(s)) and (s[posf] = '!' ) then
    begin
      delete(s,posf,1);
      mn := changeasm(mn);
    end;
    insert(mn,s,posf);
    inc(dwSize,1);
    pAddr := pointer(integer(pAddr)+1);
  end;
end;

procedure changeD0(var s: string; var pAddr: Pointer; var dwSize: DWord; b: Byte);
var posf: integer;
    mn: string;
begin
  posf := pos('~',s);
  if (posf > 0) then
  begin
    delete(s,posf,1);
    if b mod 2 = 0 then
      mn := TableD0RegLH(pbyte(integer(pAddr)+1)^) else
      mn := TableD0Reg(pbyte(integer(pAddr)+1)^);
    insert(mn,s,posf);
    inc(dwSize,1);
    pAddr := pointer(integer(pAddr)+1);
  end;
end;

procedure changeRegByte(var s: String; var pAddr: pointer; var dwSize: DWord; b: Byte);
var posf: integer;
    mn: string;
begin
  posf := pos('&',s);
  if (posf > 0) then
  begin
    delete(s,posf,1);
    if (b mod 2 <> 0) then
      mn := TableRegByte(pbyte(integer(pAddr)+1)^) else
      mn := TableRegByteP(pbyte(integer(pAddr)+1)^);
    pAddr := pointer(integer(pAddr)+1);
    if (posf <= length(s)) and (s[posf] = '!' ) then
    begin
      delete(s,posf,1);
      mn := changeasm(mn);
    end;
    insert(mn,s,posf);
    inc(dwSize,1);
  end;
end;

procedure change8C(var s: String; var pAddr: Pointer; var dwSize: DWord);
var posf: integer;
    mn: string;
begin
  posf := pos('°8C',s);
  if (posf > 0) then
  begin
    delete(s,posf,3);
    mn := Table8C(pbyte(integer(pAddr)+1)^);
    if (posf <= length(s)) and (s[posf] = '!' ) then
    begin
      delete(s,posf,1);
      mn := changeasm(mn);
    end;
    insert(mn,s,posf);
    inc(dwSize,1);
    pAddr := pointer(integer(pAddr)+1);
  end;
end;

procedure changeRegComb(var s: String; var pAddr: Pointer; var dwSize: DWord);
var posf: integer;
begin
  posf := pos('§',s);
  if (posf > 0) then
  begin
    delete(s,posf,1);
    insert(TableRegComb(pbyte(integer(pAddr)+1)^),s,posf);
    pAddr := pointer(integer(pAddr)+1);
    inc(dwSize);
  end;
end;

procedure changeES(var s: String; var pAddr: Pointer; var dwSize: DWord);
var t, u: string;
    posf, i, a: integer;
begin
  if (length(s) > 0) and (s[1] = '-') then
  begin
    t := copy(s,2,2);
    delete(s,1,3);
    posf := pos('[',s);
    if (posf > 0) and ((s[posf+1] = '<') or (s[posf+1] = '0') or (s[posf+1] = 'E')) and ((pos(':',s) = 0) or (pos(': ',s) <> 0)) then
      insert(t+':',s,posf) else
    if (posf = 0) then
    begin
      a := 0;
      for i := 0 to 7 do
      begin
        if (pos(regX[i],s) > 0) then inc(a);
        if (pos(regLH[i],s) > 0) then inc(a);
        if (pos(regLHS[i],s) > 0) and (pos('E'+regLHS[i],s) = 0) then inc(a);
      end;
      if (a = 2) then
      begin
        posf := 0;
        for i := 1 to length(s) do if s[i] = ',' then a := i;
        u := copy(s,1,a);
        for i := 0 to 7 do
        begin
          if (pos(regX[i],u) > 0) then posf := pos(regX[i],u);
          if (pos(regLH[i],u) > 0) then posf := pos(regLH[i],u);
          if (pos(regLHS[i],u) > 0) and (pos('E'+regLHS[i],u) = 0) then posf := pos(regLHS[i],u);
        end;
      end;
      insert(t+':',s,posf);
    end;
  end;
end;

procedure changeWord(var s: String; var pAddr: Pointer; var dwSize: DWord);
var posf, i, j: integer;
begin
  if (length(s) > 0) and (s[1] = '+') then
  begin
    delete(s,1,1);

    for i := 0 to 7 do
    begin
      repeat
          posf := 0;
          for j := 1 to length(s) do
            if (copy(s,j,3) = regX[i]) and ((j = 1) or ((s[j-1] <> '[') and (s[j-1] <> '+'))) then
              posf := j;
        if (posf > 0) then
          delete(s,posf,1);
      until (posf = 0);
    end;

    while pos('<DW>',s) > 0 do delete(s,pos('<DW>',s)+1,1);
    inc(dwSize);
  end;
end;

procedure changeSI(var s: String; var pAddr: Pointer; var dwSize: DWord);
var posf, sizef: integer;
  t: string;
begin
  if (length(s) > 0) and (s[1] = ';') then
  begin
    delete(s,1,1);
    posf := pos('[',s)+1;
    sizef := pos(']',s)-posf;
    if posf > 0 then
    begin
      t := copy(s,posf,sizef);
      delete(s,posf,sizef);
      if ((pos('+',t) > 0) and (pos('+0',t) = 0)) or (pos('*',t) > 0) or (pos('ESP',t) > 0) then
        insert('SI',s,posf) else
      if (t = 'EAX') then
        insert('BX+SI',s,posf) else
      if (t = 'EBX') then
      begin
        insert('BP+DI',s,posf);
        insert('SS:',s,posf-1);
      end else
      if (t = 'ECX') then
        insert('BX+DI',s,posf) else
      if (t = 'EDX') then
      begin
        insert('BP+SI',s,posf);
        insert('SS:',s,posf-1);
      end else
      if (copy(t,1,3) = 'EBP') then
        insert('DI',s,posf) else
      if (t = 'EDI') then
        insert('BX',s,posf) else
      if (t = 'ESI') then
        insert('<W>',s,posf) else
        insert(t,s,posf);
    end;
  end;
end;

function InstructionInfoX(pAddr: Pointer; var sInstructionName: string; var dwSize: DWord; changebytes: boolean): boolean; forward;

procedure changeRepeat(var s: string; var pAddr: pointer; var dwSize: DWord);
var sName: string;
    dwfSize: DWord;
begin
  if pos('|',s) > 0 then
  begin
    delete(s,pos('|',s),1);
    InstructionInfoX(pointer(integer(pAddr)+1),sName, dwfSize, false);

    if (s = 'REP ') and (pos('REPNZ ',sName) > 0) then
      delete(sName,pos('REPNZ ',sName),6) else
    if ((pos(s,sName) > 0)) and ((s = 'REP ') or (s = 'REPNZ ')) then
      delete(sName,pos(s,sName),length(s));

    if not((s = 'REPNZ ') and (pos('REP ',sName) > 0)) then
      s := s+sName else s := sName;

    inc(dwSize,dwfSize+1);
  end;
end;

procedure changeN(var s: String; t: String; var pAddr: Pointer; pFunctionAddr: Pointer; var dwSize: DWord);
var posf: integer;
    mn: string;
    dummy: function(b: byte): string;
begin
  posf := pos(t,s);
  dummy := pFunctionAddr;
  if (posf > 0) then
  begin
    delete(s,posf,length(t));
    pAddr := pointer(integer(pAddr)+1);
    mn := dummy(pbyte(pAddr)^);
    insert(mn,s,posf);
    inc(dwSize,1);
  end;
end;



procedure changeTableReg(var s: String; var pAddr: Pointer; var dwSize: DWord);
var posf: integer;
    mn: string;
begin
  posf := pos('°C4',s);
  if (posf > 0) then
  begin
    delete(s,posf,3);
      mn := changeasm(TableReg(pbyte(integer(pAddr)+1)^));
    insert(mn,s,posf);
    inc(dwSize,1);
    pAddr := pointer(integer(pAddr)+1);
  end;
end;


procedure changeTable0F(var s: string; t: string; pFunctionAddr: pointer; var pAddr: pointer; var dwSize: DWord);
var posf: integer;
    mn: string;
    dummy: function(b: byte): string;
begin
  @dummy := pFunctionAddr;
  posf := pos(t,s);
  if (posf > 0) then
  begin
    delete(s,posf,length(t));
      mn := dummy(pbyte(integer(pAddr)+1)^);
    insert(mn,s,posf);
    inc(dwSize,1);
    pAddr := pointer(integer(pAddr)+1);
  end;
end;

function InstructionInfo0F(p: pointer; var name: string; var dwSize: DWord): boolean;
var OldProtect: DWord;
    b: PByte;
    instrx: TInstruction;
    s: string;
begin
  Result := False;
  name := '';
  dwSize := 1;
  if not VirtualProtect(p,1,PAGE_EXECUTE_READWRITE,OldProtect) then
    Exit;

  b := p;
  instrx := Table0f[b^];
  if (instrx.name = 'undefined') then
    Exit;

  if (instrx.instrbyte <> b^) then
    Exit;

  s := uppercase(instrx.name);
  changeTable0F(s,'0F00',@table0f00,p,dwSize);

  changeHex(s, p, dwSize);                   // <b> <dw>
  name := s;
  result := true;

  VirtualProtect(p,1,OldProtect,OldProtect);
end;



var px: pointer;
function InstructionInfoX(pAddr: Pointer; var sInstructionName: string; var dwSize: DWord; changebytes: boolean): boolean;
var
  dwOldProtect: DWord;
  b: PByte;
  Instruction: TInstruction;
  sInstrName: string;
begin
  result := false;
  dwSize := 0;
  sInstructionName := '';
  if VirtualProtect(pAddr,$20,PAGE_EXECUTE_READWRITE,dwOldProtect) or (is9x) then
  begin
    b := pAddr;
    Instruction := instructiontable[b^];

    if (Instruction.name <> 'undefined') and (Instruction.instrbyte = b^) then
    begin
      sInstrName := UpperCase(Instruction.name);
      changeReg(sInstrName, pAddr, dwSize, Instruction.instrbyte); // % table 2 [2 operanden]
      changeRegByte(sInstrName, pAddr, dwSize, Instruction.instrbyte); // &! mov
      changeD0(sInstrName, pAddr, dwSize, Instruction.instrbyte); // ~ , 1, cl

      changeN(sInstrName,'°D8',pAddr,@TableD8,dwSize);
      changeN(sInstrName,'°D9',pAddr,@TableD9,dwSize);
      changeN(sInstrName,'°DA',pAddr,@TableDA,dwSize);
      changeN(sInstrName,'°DB',pAddr,@TableDB,dwSize);
      changeN(sInstrName,'°DD',pAddr,@TableDD,dwSize);
      changeN(sInstrName,'°DE',pAddr,@TableDE,dwSize);
      changeN(sInstrName,'°DF',pAddr,@TableDF,dwSize);
      changeN(sInstrName,'°80',pAddr,@Table80,dwSize);
      changeN(sInstrName,'°81',pAddr,@Table81,dwSize);
      changeN(sInstrName,'°82',pAddr,@Table82,dwSize);
      changeN(sInstrName,'°83',pAddr,@Table83,dwSize);
      changeN(sInstrName,'°F6',pAddr,@TableF6,dwSize);
      changeN(sInstrName,'°F7',pAddr,@TableF7,dwSize);
      changeN(sInstrName,'°FF',pAddr,@TableFF,dwSize);
      changeN(sInstrName,'°63',pAddr,@Table63,dwSize);

      change8C(sInstrName, pAddr, dwSize);                  // %! mov [eax], es
      changeTableReg(sInstrName, pAddr, dwSize);                  // eax, [eax]

      changeRegComb(sInstrName, pAddr, dwSize);             // Register Combinations like [eax+edx]

      changeRepeat(sInstrName, pAddr, dwSize);              // Repeat
      changeWord(sInstrName, pAddr, dwSize);                // Word
      changeES(sInstrName, pAddr, dwSize);                  // ES: ...
      changeSI(sInstrName, pAddr, dwSize);                  // SI: ...


      if (px = nil) then
        px := pAddr;

      if changebytes then
        changeHex(sInstrName, px, dwSize);

      sInstructionName := sInstrName;
      Result := True;
      if Instruction.instrbyte = TTable0F.instrbyte then
        Result := InstructionInfo0F(pointer(integer(pAddr)+1),sInstructionName,dwSize);
    end;
    VirtualProtect(pAddr,$20,dwOldProtect,dwOldProtect);
  end;
end;

procedure Init;
begin
  InstructionTable[$00] := Tadd1;
  InstructionTable[$01] := Tadd3;
  InstructionTable[$02] := Tadd2;
  InstructionTable[$03] := Tadd4;
  InstructionTable[$04] := Taddal;
  InstructionTable[$05] := Taddeax;
  InstructionTable[$06] := Tpushes;
  InstructionTable[$07] := Tpopes;
  InstructionTable[$08] := Tor1;
  InstructionTable[$09] := Tor3;
  InstructionTable[$0A] := Tor2;
  InstructionTable[$0B] := Tor4;
  InstructionTable[$0C] := Toral;
  InstructionTable[$0D] := Toreax;
  InstructionTable[$0E] := Tpushcs;
  InstructionTable[$0F] := TTable0F;

  InstructionTable[$10] := Tadc1;
  InstructionTable[$11] := Tadc3;
  InstructionTable[$12] := Tadc2;
  InstructionTable[$13] := Tadc4;
  InstructionTable[$14] := Tadcal;
  InstructionTable[$15] := Tadceax;
  InstructionTable[$16] := Tpushss;
  InstructionTable[$17] := Tpopss;
  InstructionTable[$18] := Tsbb1;
  InstructionTable[$19] := Tsbb3;
  InstructionTable[$1A] := Tsbb2;
  InstructionTable[$1B] := Tsbb4;
  InstructionTable[$1C] := Tsbbal;
  InstructionTable[$1D] := Tsbbeax;
  InstructionTable[$1E] := Tpushds;
  InstructionTable[$1F] := Tpopds;

  InstructionTable[$20] := Tand1;
  InstructionTable[$21] := Tand3;
  InstructionTable[$22] := Tand2;
  InstructionTable[$23] := Tand4;
  InstructionTable[$24] := Tandal;
  InstructionTable[$25] := Tandeax;
  InstructionTable[$26] := TUndefined;
  InstructionTable[$27] := Tdaa;
  InstructionTable[$28] := Tsub1;
  InstructionTable[$29] := Tsub3;
  InstructionTable[$2A] := Tsub2;
  InstructionTable[$2B] := Tsub4;
  InstructionTable[$2C] := Tsubal;
  InstructionTable[$2D] := Tsubeax;
  InstructionTable[$2E] := Tcs;
  InstructionTable[$2F] := Tdas;

  InstructionTable[$30] := Txor1;
  InstructionTable[$31] := Txor3;
  InstructionTable[$32] := Txor2;
  InstructionTable[$33] := Txor4;
  InstructionTable[$34] := Txoral;
  InstructionTable[$35] := Txoreax;
  InstructionTable[$36] := TUndefined;
  InstructionTable[$37] := Taaa;
  InstructionTable[$38] := Tcmp1;
  InstructionTable[$39] := Tcmp3;
  InstructionTable[$3A] := Tcmp2;
  InstructionTable[$3B] := Tcmp4;
  InstructionTable[$3C] := Tcmpal;
  InstructionTable[$3D] := Tcmpeax;
  InstructionTable[$3E] := Tds;
  InstructionTable[$3F] := Taas;

  InstructionTable[$40] := Tinceax;
  InstructionTable[$41] := Tincecx;
  InstructionTable[$42] := Tincedx;
  InstructionTable[$43] := Tincebx;
  InstructionTable[$44] := Tincesp;
  InstructionTable[$45] := Tincebp;
  InstructionTable[$46] := Tincesi;
  InstructionTable[$47] := Tincedi;
  InstructionTable[$48] := Tdeceax;
  InstructionTable[$49] := Tdececx;
  InstructionTable[$4A] := Tdecedx;
  InstructionTable[$4B] := Tdecebx;
  InstructionTable[$4C] := Tdecesp;
  InstructionTable[$4D] := Tdecebp;
  InstructionTable[$4E] := Tdecesi;
  InstructionTable[$4F] := Tdecedi;

  InstructionTable[$50] := Tpusheax;
  InstructionTable[$51] := Tpushecx;
  InstructionTable[$52] := Tpushedx;
  InstructionTable[$53] := Tpushebx;
  InstructionTable[$54] := Tpushesp;
  InstructionTable[$55] := Tpushebp;
  InstructionTable[$56] := Tpushesi;
  InstructionTable[$57] := Tpushedi;
  InstructionTable[$58] := Tpopeax;
  InstructionTable[$59] := Tpopecx;
  InstructionTable[$5A] := Tpopedx;
  InstructionTable[$5B] := Tpopebx;
  InstructionTable[$5C] := Tpopesp;
  InstructionTable[$5D] := Tpopebp;
  InstructionTable[$5E] := Tpopesi;
  InstructionTable[$5F] := Tpopedi;

  InstructionTable[$60] := Tpushad;
  InstructionTable[$61] := Tpopad;
  InstructionTable[$62] := Tbound;
  InstructionTable[$63] := tarpl;
  InstructionTable[$64] := Tfs;
  InstructionTable[$65] := Tgs;
  InstructionTable[$66] := T66;
  InstructionTable[$67] := T67;
  InstructionTable[$68] := Tpush;
  InstructionTable[$69] := timul2;
  InstructionTable[$6A] := Tpushbyte;
  InstructionTable[$6B] := Timul;
  InstructionTable[$6C] := Tinsb;
  InstructionTable[$6D] := Tinsd;
  InstructionTable[$6E] := Toutsb;
  InstructionTable[$6F] := Toutsd;

  InstructionTable[$70] := Tjo;
  InstructionTable[$71] := Tjno;
  InstructionTable[$72] := Tjb;
  InstructionTable[$73] := Tjnb;
  InstructionTable[$74] := Tje;
  InstructionTable[$75] := Tjne;
  InstructionTable[$76] := Tjbe;
  InstructionTable[$77] := Tjnbe;
  InstructionTable[$78] := Tjs;
  InstructionTable[$79] := Tjns;
  InstructionTable[$7A] := Tjp;
  InstructionTable[$7B] := Tjnp;
  InstructionTable[$7C] := Tjl;
  InstructionTable[$7D] := Tjnl;
  InstructionTable[$7E] := Tjle;
  InstructionTable[$7F] := Tjnle;

  InstructionTable[$80] := T80;
  InstructionTable[$81] := T81;
  InstructionTable[$82] := T82;
  InstructionTable[$83] := T83;
  InstructionTable[$84] := Ttest1;
  InstructionTable[$85] := Ttest2;
  InstructionTable[$86] := Txchg1;
  InstructionTable[$87] := Txchg2;
  InstructionTable[$88] := Tmov1;
  InstructionTable[$89] := Tmov3;
  InstructionTable[$8A] := Tmov2;
  InstructionTable[$8B] := Tmov4;
  InstructionTable[$8C] := Tmov5;
  InstructionTable[$8D] := Tlea;
  InstructionTable[$8E] := Tmov6;
  InstructionTable[$8F] := Tpop;

  InstructionTable[$90] := Tnop;
  InstructionTable[$91] := Txchgeaxecx;
  InstructionTable[$92] := Txchgeaxedx;
  InstructionTable[$93] := Txchgeaxebx;
  InstructionTable[$94] := Txchgeaxesp;
  InstructionTable[$95] := Txchgeaxebp;
  InstructionTable[$96] := Txchgeaxesi;
  InstructionTable[$97] := Txchgeaxedi;
  InstructionTable[$98] := Tcwde;
  InstructionTable[$99] := Tcdq;
  InstructionTable[$9A] := Tcall2;
  InstructionTable[$9B] := Twait;
  InstructionTable[$9C] := Tpushfd;
  InstructionTable[$9D] := Tpopfd;
  InstructionTable[$9E] := Tsahf;
  InstructionTable[$9F] := Tlahf;

  InstructionTable[$A0] := Tmovaldw;
  InstructionTable[$A1] := Tmoveaxdw;
  InstructionTable[$A2] := Tmovdwal;
  InstructionTable[$A3] := Tmovdweax;
  InstructionTable[$A4] := Tmovsb;
  InstructionTable[$A5] := Tmovsd;
  InstructionTable[$A6] := Tcmpsb;
  InstructionTable[$A7] := Tcmpsd;
  InstructionTable[$A8] := Ttestal;
  InstructionTable[$A9] := Ttesteax;
  InstructionTable[$AA] := Tstossb;
  InstructionTable[$AB] := Tstossd;
  InstructionTable[$AC] := Tlodsb;
  InstructionTable[$AD] := Tlodsd;
  InstructionTable[$AE] := Tscasb;
  InstructionTable[$AF] := Tscasd;

  InstructionTable[$B0] := Tmoval;
  InstructionTable[$B1] := Tmovcl;
  InstructionTable[$B2] := Tmovdl;
  InstructionTable[$B3] := Tmovbl;
  InstructionTable[$B4] := Tmovah;
  InstructionTable[$B5] := Tmovch;
  InstructionTable[$B6] := Tmovdh;
  InstructionTable[$B7] := Tmovbh;
  InstructionTable[$B8] := Tmoveax;
  InstructionTable[$B9] := Tmovecx;
  InstructionTable[$BA] := Tmovedx;
  InstructionTable[$BB] := Tmovebx;
  InstructionTable[$BC] := Tmovesp;
  InstructionTable[$BD] := Tmovebp;
  InstructionTable[$BE] := Tmovesi;
  InstructionTable[$BF] := Tmovedi;

  InstructionTable[$C0] := TC0;
  InstructionTable[$C1] := TC1;
  InstructionTable[$C2] := Tretw;
  InstructionTable[$C3] := Tret;
  InstructionTable[$C4] := Tles;
  InstructionTable[$C5] := Tlds;
  InstructionTable[$C6] := Tmov7;
  InstructionTable[$C7] := Tmov8;
  InstructionTable[$C8] := Tenter;
  InstructionTable[$C9] := Tleave;
  InstructionTable[$CA] := Tretw2;
  InstructionTable[$CB] := Tret2;
  InstructionTable[$CC] := Tbp;
  InstructionTable[$CD] := Tint;
  InstructionTable[$CE] := Tinto;
  InstructionTable[$CF] := Tiret;

  InstructionTable[$D0] := Td0;
  InstructionTable[$D1] := Td1;
  InstructionTable[$D2] := Td2;
  InstructionTable[$D3] := Td3;
  InstructionTable[$D4] := Taam;
  InstructionTable[$D5] := Taad;
  InstructionTable[$D6] := Tdbd6;
  InstructionTable[$D7] := Txlat;
  InstructionTable[$D8] := Td8;
  InstructionTable[$D9] := Td9;
  InstructionTable[$DA] := Tda;
  InstructionTable[$DB] := Tdb;
  InstructionTable[$DC] := Tdc;
  InstructionTable[$DD] := tdd;
  InstructionTable[$DE] := tde;
  InstructionTable[$DF] := tdf;

  InstructionTable[$E0] := Tloopne;
  InstructionTable[$E1] := Tloope;
  InstructionTable[$E2] := Tloop;
  InstructionTable[$E3] := Tjcxz;
  InstructionTable[$E4] := Tinal;
  InstructionTable[$E5] := Tineax;
  InstructionTable[$E6] := Toutal;
  InstructionTable[$E7] := Touteax;
  InstructionTable[$E8] := Tcall;
  InstructionTable[$E9] := Tjmp;
  InstructionTable[$EA] := Tjpwdw;
  InstructionTable[$EB] := Tjmpshotz;
  InstructionTable[$EC] := Tinaldx;
  InstructionTable[$ED] := Tineaxdx;
  InstructionTable[$EE] := Toutdxal;
  InstructionTable[$EF] := Toutdxeax;

  InstructionTable[$F0] := Tlock;
  InstructionTable[$F1] := Tdbf1;
  InstructionTable[$F2] := Trepnz;
  InstructionTable[$F3] := Trep;
  InstructionTable[$F4] := Thlt;
  InstructionTable[$F5] := Tcmc;
  InstructionTable[$F6] := TF6;
  InstructionTable[$F7] := TF7;
  InstructionTable[$F8] := Tclc;
  InstructionTable[$F9] := Tstc;
  InstructionTable[$FA] := Tcli;
  InstructionTable[$FB] := Tsti;
  InstructionTable[$FC] := Tcld;
  InstructionTable[$FD] := Tstd;
  InstructionTable[$FE] := Tdbfe;
  InstructionTable[$FF] := Tff;

  Table0F[$00] := T0f00;
  Table0F[$01] := TUndefined;
  Table0F[$02] := TUndefined;
  Table0F[$03] := TUndefined;
  Table0F[$04] := Tdb;
  Table0F[$05] := Tdb;
  Table0F[$06] := Tclts;
  Table0F[$07] := Tdb;
  Table0F[$08] := Tinvd;
  Table0F[$09] := Twbinvd;
  Table0F[$0A] := Tdb;
  Table0F[$0B] := Tuds;
  Table0F[$0C] := Tdb;
  Table0F[$0D] := Tfemms;
  Table0F[$0E] := TUndefined;
  Table0F[$0F] := TUndefined;
  Table0F[$10] := TUndefined;
  Table0F[$11] := TUndefined;
  Table0F[$12] := TUndefined;
  Table0F[$13] := TUndefined;
  Table0F[$14] := TUndefined;
  Table0F[$15] := TUndefined;
  Table0F[$16] := TUndefined;
  Table0F[$17] := TUndefined;
  Table0F[$18] := TUndefined;
  Table0F[$19] := Tdb;
  Table0F[$1A] := Tdb;
  Table0F[$1B] := Tdb;
  Table0F[$1C] := Tdb;
  Table0F[$1D] := Tdb;
  Table0F[$1E] := Tdb;
  Table0F[$1F] := Tdb;
  Table0F[$20] := TUndefined;
  Table0F[$21] := TUndefined;
  Table0F[$22] := TUndefined;
  Table0F[$23] := TUndefined;
  Table0F[$24] := TUndefined;
  Table0F[$25] := TUndefined;
  Table0F[$26] := TUndefined;
  Table0F[$27] := TUndefined;
  Table0F[$28] := TUndefined;
  Table0F[$29] := TUndefined;
  Table0F[$2A] := TUndefined;
  Table0F[$2B] := TUndefined;
  Table0F[$2C] := TUndefined;
  Table0F[$2D] := TUndefined;
  Table0F[$2E] := TUndefined;
  Table0F[$2F] := TUndefined;
  Table0F[$30] := TUndefined;
  Table0F[$31] := TUndefined;
  Table0F[$32] := TUndefined;
  Table0F[$33] := TUndefined;
  Table0F[$34] := TUndefined;
  Table0F[$35] := TUndefined;
  Table0F[$36] := TUndefined;
  Table0F[$37] := TUndefined;
  Table0F[$38] := TUndefined;
  Table0F[$39] := TUndefined;
  Table0F[$3A] := TUndefined;
  Table0F[$3B] := TUndefined;
  Table0F[$3C] := TUndefined;
  Table0F[$3D] := TUndefined;
  Table0F[$3E] := TUndefined;
  Table0F[$3F] := TUndefined;
  Table0F[$40] := TUndefined;
  Table0F[$41] := TUndefined;
  Table0F[$42] := TUndefined;
  Table0F[$43] := TUndefined;
  Table0F[$44] := TUndefined;
  Table0F[$45] := TUndefined;
  Table0F[$46] := TUndefined;
  Table0F[$47] := TUndefined;
  Table0F[$48] := TUndefined;
  Table0F[$49] := TUndefined;
  Table0F[$4A] := TUndefined;
  Table0F[$4B] := TUndefined;
  Table0F[$4C] := TUndefined;
  Table0F[$4D] := TUndefined;
  Table0F[$4E] := TUndefined;
  Table0F[$4F] := TUndefined;
  Table0F[$50] := TUndefined;
  Table0F[$51] := TUndefined;
  Table0F[$52] := TUndefined;
  Table0F[$53] := TUndefined;
  Table0F[$54] := TUndefined;
  Table0F[$55] := TUndefined;
  Table0F[$56] := TUndefined;
  Table0F[$57] := TUndefined;
  Table0F[$58] := TUndefined;
  Table0F[$59] := TUndefined;
  Table0F[$5A] := TUndefined;
  Table0F[$5B] := TUndefined;
  Table0F[$5C] := TUndefined;
  Table0F[$5D] := TUndefined;
  Table0F[$5E] := TUndefined;
  Table0F[$5F] := TUndefined;
  Table0F[$60] := TUndefined;
  Table0F[$61] := TUndefined;
  Table0F[$62] := TUndefined;
  Table0F[$63] := TUndefined;
  Table0F[$64] := TUndefined;
  Table0F[$65] := TUndefined;
  Table0F[$66] := TUndefined;
  Table0F[$67] := TUndefined;
  Table0F[$68] := TUndefined;
  Table0F[$69] := TUndefined;
  Table0F[$6A] := TUndefined;
  Table0F[$6B] := TUndefined;
  Table0F[$6C] := TUndefined;
  Table0F[$6D] := TUndefined;
  Table0F[$6E] := TUndefined;
  Table0F[$6F] := TUndefined;
  Table0F[$70] := TUndefined;
  Table0F[$71] := TUndefined;
  Table0F[$72] := TUndefined;
  Table0F[$73] := TUndefined;
  Table0F[$74] := TUndefined;
  Table0F[$75] := TUndefined;
  Table0F[$76] := TUndefined;
  Table0F[$77] := TUndefined;
  Table0F[$78] := TUndefined;
  Table0F[$79] := TUndefined;
  Table0F[$7A] := TUndefined;
  Table0F[$7B] := TUndefined;
  Table0F[$7C] := TUndefined;
  Table0F[$7D] := TUndefined;
  Table0F[$7E] := TUndefined;
  Table0F[$7F] := TUndefined;
  Table0F[$80] := Tjo2;
  Table0F[$81] := Tjno2;
  Table0F[$82] := Tjb2;
  Table0F[$83] := Tjnb2;
  Table0F[$84] := Tje2;
  Table0F[$85] := Tjne2;
  Table0F[$86] := Tjbe2;
  Table0F[$87] := Tjnbe2;
  Table0F[$88] := Tjs2;
  Table0F[$89] := Tjns2;
  Table0F[$8A] := Tjp2;
  Table0F[$8B] := Tjnp2;
  Table0F[$8C] := Tjl2;
  Table0F[$8D] := Tjnl2;
  Table0F[$8E] := Tjle2;
  Table0F[$8F] := Tjnle2;
  Table0F[$90] := TUndefined;
  Table0F[$91] := TUndefined;
  Table0F[$92] := TUndefined;
  Table0F[$93] := TUndefined;
  Table0F[$94] := TUndefined;
  Table0F[$95] := TUndefined;
  Table0F[$96] := TUndefined;
  Table0F[$97] := TUndefined;
  Table0F[$98] := TUndefined;
  Table0F[$99] := TUndefined;
  Table0F[$9A] := TUndefined;
  Table0F[$9B] := TUndefined;
  Table0F[$9C] := TUndefined;
  Table0F[$9D] := TUndefined;
  Table0F[$9E] := TUndefined;
  Table0F[$9F] := TUndefined;
  Table0F[$A0] := Tpushfs;
  Table0F[$A1] := Tpopfs;
  Table0F[$A2] := Tcpuid;
  Table0F[$A3] := TUndefined;
  Table0F[$A4] := TUndefined;
  Table0F[$A5] := TUndefined;
  Table0F[$A6] := TUndefined;
  Table0F[$A7] := TUndefined;
  Table0F[$A8] := Tpushgs;
  Table0F[$A9] := Tpushgs;
  Table0F[$AA] := Trsm;
  Table0F[$AB] := TUndefined;
  Table0F[$AC] := TUndefined;
  Table0F[$AD] := TUndefined;
  Table0F[$AE] := TUndefined;
  Table0F[$AF] := TUndefined;
  Table0F[$B0] := TUndefined;
  Table0F[$B1] := TUndefined;
  Table0F[$B2] := TUndefined;
  Table0F[$B3] := TUndefined;
  Table0F[$B4] := TUndefined;
  Table0F[$B5] := TUndefined;
  Table0F[$B6] := TUndefined;
  Table0F[$B7] := TUndefined;
  Table0F[$B8] := TUndefined;
  Table0F[$B9] := TUndefined;
  Table0F[$BA] := TUndefined;
  Table0F[$BB] := TUndefined;
  Table0F[$BC] := TUndefined;
  Table0F[$BD] := TUndefined;
  Table0F[$BE] := TUndefined;
  Table0F[$BF] := TUndefined;
  Table0F[$C0] := TUndefined;
  Table0F[$C1] := TUndefined;
  Table0F[$C2] := TUndefined;
  Table0F[$C3] := TUndefined;
  Table0F[$C4] := TUndefined;
  Table0F[$C5] := TUndefined;
  Table0F[$C6] := TUndefined;
  Table0F[$C7] := TUndefined;
  Table0F[$C8] := TUndefined;
  Table0F[$C9] := TUndefined;
  Table0F[$CA] := TUndefined;
  Table0F[$CB] := TUndefined;
  Table0F[$CC] := TUndefined;
  Table0F[$CD] := TUndefined;
  Table0F[$CE] := TUndefined;
  Table0F[$CF] := TUndefined;
  Table0F[$D0] := TUndefined;
  Table0F[$D1] := TUndefined;
  Table0F[$D2] := TUndefined;
  Table0F[$D3] := TUndefined;
  Table0F[$D4] := TUndefined;
  Table0F[$D5] := TUndefined;
  Table0F[$D6] := TUndefined;
  Table0F[$D7] := TUndefined;
  Table0F[$D8] := TUndefined;
  Table0F[$D9] := TUndefined;
  Table0F[$DA] := TUndefined;
  Table0F[$DB] := TUndefined;
  Table0F[$DC] := TUndefined;
  Table0F[$DD] := TUndefined;
  Table0F[$DE] := TUndefined;
  Table0F[$DF] := TUndefined;
  Table0F[$E0] := TUndefined;
  Table0F[$E1] := TUndefined;
  Table0F[$E2] := TUndefined;
  Table0F[$E3] := TUndefined;
  Table0F[$E4] := TUndefined;
  Table0F[$E5] := TUndefined;
  Table0F[$E6] := TUndefined;
  Table0F[$E7] := TUndefined;
  Table0F[$E8] := TUndefined;
  Table0F[$E9] := TUndefined;
  Table0F[$EA] := TUndefined;
  Table0F[$EB] := TUndefined;
  Table0F[$EC] := TUndefined;
  Table0F[$ED] := TUndefined;
  Table0F[$EE] := TUndefined;
  Table0F[$EF] := TUndefined;
  Table0F[$F0] := Tdb;
  Table0F[$F1] := TUndefined;
  Table0F[$F2] := TUndefined;
  Table0F[$F3] := TUndefined;
  Table0F[$F4] := TUndefined;
  Table0F[$F5] := TUndefined;
  Table0F[$F6] := TUndefined;
  Table0F[$F7] := TUndefined;
  Table0F[$F8] := TUndefined;
  Table0F[$F9] := TUndefined;
  Table0F[$FA] := TUndefined;
  Table0F[$FB] := TUndefined;
  Table0F[$FC] := TUndefined;
  Table0F[$FD] := TUndefined;
  Table0F[$FE] := TUndefined;
  Table0F[$FF] := Tdb;
end;

function InstructionInfo(pAddr: Pointer; var sInstructionName: String; var dwSize: DWord): boolean; stdcall;
begin
  if (not Initialized) then
    Init;
  px := nil;
  result := InstructionInfoX(pAddr,sInstructionName,dwSize,true);
end;



end.
