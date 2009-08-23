// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Library Include Submodule
//
// This file defines the general options that define the environment that
// the library is compiled with. For changes to the configuration of the
// library look into Omorphia.config.inc.
//
// Please note that changes in this file are global to the entire library.
//
// This file is based on the jedi.inc, but modified to fit the needs of the
// Omorphia project.
//
// *****************************************************************************
// To Do:
//  TODO -oBenBE, Neo -cSource, Style : Vergabe von Aliasnamen für Überladene Routinen (SUPPORTS_ALIASES)
//  TODO -oBenBE, Neo -cSource, Style : Nutzung von Inlining (SUPPORTS_INLINING & SUPPORTS_INLINING_ASM)
//  TODO -oBenBE, Neo -cSource, Style : Schaffung überladener Operatoren (SUPPORTS_OVERLOADING_OPERATORS)
//
// *****************************************************************************
// News:
//  - Limited support for FPC (Preparational Steps)
//
// *****************************************************************************
// Bugs:
//
// *****************************************************************************
// Info:
//
// *****************************************************************************

{

- Development environment directives

  This file defines two directives to indicate which development environment the
  library is being compiled with.

  Directive         Description
  ------------------------------------------------------------------------------
  DELPHI            Compiling with Delphi
  BCB               Compiling with C++ Builder
  FPC               Compiling with FreePascal
  KYLIX             Compiling with Kylix

- Compiler Versions

  The following groups directives are direct mappings from the VERXXX directives
  to a friendly name of the associated compiler. These directives are only
  defined in within their groups if the associated compiler e.g. DELPHI is used.

- General Compiler Versions

  Directive         Description
  ------------------------------------------------------------------------------
  COMPILER1         Compiling with Delphi 1
  COMPILER2         Compiling with Delphi 2 or C++ Builder 1
  COMPILER3         Compiling with Delphi 3
  COMPILER35        Compiling with C++ Builder 3
  COMPILER4         Compiling with Delphi 4 or C++ Builder 4
  COMPILER5         Compiling with Delphi 5 or C++ Builder 5
  COMPILER6         Compiling with Delphi 6 or C++ Builder 6
  COMPILER7         Compiling with Delphi 7 or C++ Builder 7
  COMPILER8         Compiling with Delphi 8
  COMPILER9         Compiling with Delphi 2005

  COMPILER1_DOWN    Compiling with Delphi 1 or lower
  COMPILER2_DOWN    Compiling with Delphi 2 or C++ Builder 1 or lower
  COMPILER3_DOWN    Compiling with Delphi 3 or lower
  COMPILER35DOWN    Compiling with C++ Builder 3 or lower
  COMPILER4_DOWN    Compiling with Delphi 4 or C++ Builder 4 or lower
  COMPILER5_DOWN    Compiling with Delphi 5 or C++ Builder 5 or lower
  COMPILER6_DOWN    Compiling with Delphi 6 or C++ Builder 6 or lower
  COMPILER7_DOWN    Compiling with Delphi 7 or C++ Builder 7 or lower
  COMPILER8_DOWN    Compiling with Delphi 8 or lower
  COMPILER9_DOWN    Compiling with Delphi 2005 or lower

  COMPILER1_UP      Compiling with Delphi 1 or higher
  COMPILER2_UP      Compiling with Delphi 2 or C++ Builder 1 or higher
  COMPILER3_UP      Compiling with Delphi 3 or higher
  COMPILER35UP      Compiling with C++ Builder 3 or higher
  COMPILER4_UP      Compiling with Delphi 4 or C++ Builder 4 or higher
  COMPILER5_UP      Compiling with Delphi 5 or C++ Builder 5 or higher
  COMPILER6_UP      Compiling with Delphi 6 or C++ Builder 6 or higher
  COMPILER7_UP      Compiling with Delphi 7 or C++ Builder 7 or higher
  COMPILER8_UP      Compiling with Delphi 8 or higher
  COMPILER9_UP      Compiling with Delphi 2005 or higher

- C++ Builder Versions

  Directive         Description
  ------------------------------------------------------------------------------
  BCB1              Compiling with C++ Builder 1
  BCB3              Compiling with C++ Builder 3
  BCB4              Compiling with C++ Builder 4
  BCB5              Compiling with C++ Builder 5
  BCB6              Compiling with C++ Builder 6
  BCB7              Compiling with C++ Builder 7

  BCB1_DOWN         Compiling with C++ Builder 1 or lower
  BCB3_DOWN         Compiling with C++ Builder 3 or lower
  BCB4_DOWN         Compiling with C++ Builder 4 or lower
  BCB5_DOWN         Compiling with C++ Builder 5 or lower
  BCB6_DOWN         Compiling with C++ Builder 6 or lower
  BCB7_DOWN         Compiling with C++ Builder 7 or lower

  BCB1_UP           Compiling with C++ Builder 1 or higher
  BCB3_UP           Compiling with C++ Builder 3 or higher
  BCB4_UP           Compiling with C++ Builder 4 or higher
  BCB5_UP           Compiling with C++ Builder 5 or higher
  BCB6_UP           Compiling with C++ Builder 6 or higher
  BCB7_UP           Compiling with C++ Builder 7 or higher

- Delphi Versions

  Directive         Description
  ------------------------------------------------------------------------------
  DELPHI1           Compiling with Delphi 1
  DELPHI2           Compiling with Delphi 2
  DELPHI3           Compiling with Delphi 3
  DELPHI4           Compiling with Delphi 4
  DELPHI5           Compiling with Delphi 5
  DELPHI6           Compiling with Delphi 6
  DELPHI7           Compiling with Delphi 7
  DELPHI8           Compiling with Delphi 8
  DELPHI9           Compiling with Delphi 9

  DELPHI1_DOWN      Compiling with Delphi 1 or lower
  DELPHI2_DOWN      Compiling with Delphi 2 or lower
  DELPHI3_DOWN      Compiling with Delphi 3 or lower
  DELPHI4_DOWN      Compiling with Delphi 4 or lower
  DELPHI5_DOWN      Compiling with Delphi 5 or lower
  DELPHI6_DOWN      Compiling with Delphi 6 or lower
  DELPHI7_DOWN      Compiling with Delphi 7 or lower
  DELPHI8_DOWN      Compiling with Delphi 8 or lower
  DELPHI9_DOWN      Compiling with Delphi 9 or lower

  DELPHI1_UP        Compiling with Delphi 1 or higher
  DELPHI2_UP        Compiling with Delphi 2 or higher
  DELPHI3_UP        Compiling with Delphi 3 or higher
  DELPHI4_UP        Compiling with Delphi 4 or higher
  DELPHI5_UP        Compiling with Delphi 5 or higher
  DELPHI6_UP        Compiling with Delphi 6 or higher
  DELPHI7_UP        Compiling with Delphi 7 or higher
  DELPHI8_UP        Compiling with Delphi 8 or higher
  DELPHI9_UP        Compiling with Delphi 9 or higher

- FreePascal Versions

  Directive         Description
  ------------------------------------------------------------------------------
  FPC0X             Compiling with FreePascal 0.x
  FPC1X             Compiling with FreePascal 1.x
  FPC2X             Compiling with FreePascal 2.x

  FPC0X_DOWN        Compiling with FreePascal 0.x or lower
  FPC1X_DOWN        Compiling with FreePascal 1.x or lower
  FPC2X_DOWN        Compiling with FreePascal 2.x or lower

  FPC0X_UP          Compiling with FreePascal 0.x or higher
  FPC1X_UP          Compiling with FreePascal 1.x or higher
  FPC2X_UP          Compiling with FreePascal 2.x or higher

  FPC01             Compiling with FreePascal 0.1
  FPC02             Compiling with FreePascal 0.2
  FPC03             Compiling with FreePascal 0.3
  FPC04             Compiling with FreePascal 0.4
  FPC05             Compiling with FreePascal 0.5
  FPC06             Compiling with FreePascal 0.6
  FPC07             Compiling with FreePascal 0.7
  FPC08             Compiling with FreePascal 0.8
  FPC09             Compiling with FreePascal 0.9
  FPC10             Compiling with FreePascal 1.0
  FPC11             Compiling with FreePascal 1.1
  FPC12             Compiling with FreePascal 1.2
  FPC13             Compiling with FreePascal 1.3
  FPC14             Compiling with FreePascal 1.4
  FPC15             Compiling with FreePascal 1.5
  FPC16             Compiling with FreePascal 1.6
  FPC17             Compiling with FreePascal 1.7
  FPC18             Compiling with FreePascal 1.8
  FPC19             Compiling with FreePascal 1.9
  FPC20             Compiling with FreePascal 2.0

  FPC01_DOWN        Compiling with FreePascal 0.1 or lower
  FPC02_DOWN        Compiling with FreePascal 0.2 or lower
  FPC03_DOWN        Compiling with FreePascal 0.3 or lower
  FPC04_DOWN        Compiling with FreePascal 0.4 or lower
  FPC05_DOWN        Compiling with FreePascal 0.5 or lower
  FPC06_DOWN        Compiling with FreePascal 0.6 or lower
  FPC07_DOWN        Compiling with FreePascal 0.7 or lower
  FPC08_DOWN        Compiling with FreePascal 0.8 or lower
  FPC09_DOWN        Compiling with FreePascal 0.9 or lower
  FPC10_DOWN        Compiling with FreePascal 1.0 or lower
  FPC11_DOWN        Compiling with FreePascal 1.1 or lower
  FPC12_DOWN        Compiling with FreePascal 1.2 or lower
  FPC13_DOWN        Compiling with FreePascal 1.3 or lower
  FPC14_DOWN        Compiling with FreePascal 1.4 or lower
  FPC15_DOWN        Compiling with FreePascal 1.5 or lower
  FPC16_DOWN        Compiling with FreePascal 1.6 or lower
  FPC17_DOWN        Compiling with FreePascal 1.7 or lower
  FPC18_DOWN        Compiling with FreePascal 1.8 or lower
  FPC19_DOWN        Compiling with FreePascal 1.9 or lower
  FPC20_DOWN        Compiling with FreePascal 2.0 or lower
 
  FPC01_UP          Compiling with FreePascal 0.1 or higher
  FPC02_UP          Compiling with FreePascal 0.2 or higher
  FPC03_UP          Compiling with FreePascal 0.3 or higher
  FPC04_UP          Compiling with FreePascal 0.4 or higher
  FPC05_UP          Compiling with FreePascal 0.5 or higher
  FPC06_UP          Compiling with FreePascal 0.6 or higher
  FPC07_UP          Compiling with FreePascal 0.7 or higher
  FPC08_UP          Compiling with FreePascal 0.8 or higher
  FPC09_UP          Compiling with FreePascal 0.9 or higher
  FPC10_UP          Compiling with FreePascal 1.0 or higher
  FPC11_UP          Compiling with FreePascal 1.1 or higher
  FPC12_UP          Compiling with FreePascal 1.2 or higher
  FPC13_UP          Compiling with FreePascal 1.3 or higher
  FPC14_UP          Compiling with FreePascal 1.4 or higher
  FPC15_UP          Compiling with FreePascal 1.5 or higher
  FPC16_UP          Compiling with FreePascal 1.6 or higher
  FPC17_UP          Compiling with FreePascal 1.7 or higher
  FPC18_UP          Compiling with FreePascal 1.8 or higher
  FPC19_UP          Compiling with FreePascal 1.9 or higher
  FPC20_UP          Compiling with FreePascal 2.0 or higher

- Kylix Versions

  Directive         Description
  ------------------------------------------------------------------------------
  KYLIX1            Compiling with Kylix 1
  KYLIX2            Compiling with Kylix 2
  KYLIX3            Compiling with Kylix 3

  KYLIX1_DOWN       Compiling with Kylix 1 or lower
  KYLIX2_DOWN       Compiling with Kylix 2 or lower
  KYLIX3_DOWN       Compiling with Kylix 3 or lower

  KYLIX1_UP         Compiling with Kylix 1 or higher
  KYLIX2_UP         Compiling with Kylix 2 or higher
  KYLIX3_UP         Compiling with Kylix 3 or higher

- Platform Directives

  Directive         Description
  ------------------------------------------------------------------------------
  MSWINDOWS         Defined when target platform is 32 bit Windows
  LINUX             Defined when target platform is Linux
  UNIX              Defined when target platform is Unix or Linux
  WIN32             Defined when target platform is 32 bit Windows

- Target CPU Platform Directives

  Directive         Description
  ------------------------------------------------------------------------------
  I386              Defined when target CPU is Intel 386 or compatible
  ALPHA             Defined when target CPU is Alpha or compatible
  
- Feature Directives

  The features directives are used to test if the compiler supports specific
  features, such as method overloading, and adjust the sources accordingly. Use
  of these directives is preferred over the use of the DELPHI and COMPILER
  directives.

  Directive                     Description
  ------------------------------------------------------------------------------
  SUPPORTS_ALIASES              Compiler supports alias names for routines (FPC)
  SUPPORTS_WIDESTRING           Compiler supports the WideString type (D3)
  SUPPORTS_INTERFACE            Compiler supports interfaces (D3)
  SUPPORTS_EXTSYM               Compiler supports the $EXTERNALSYM directive (D4)
  SUPPORTS_NODEFINE             Compiler supports the $NODEFINE directive (D4)
  SUPPORTS_INT64                Compiler supports the Int64 type (D4)
  SUPPORTS_DYNAMICARRAYS        Compiler supports dynamic arrays (D4)
  SUPPORTS_DEFAULTPARAMS        Compiler supports default parameters (D4)
  SUPPORTS_OVERLOAD_METHODS     Compiler supports overloading procs&funcs (D4)
  SUPPORTS_OVERLOAD_OPERATORS   Compiler supports overloading operators (FPC)
  SUPPORTS_DEPRECATED           Compiler supports the deprecated directive (D6)
  SUPPORTS_LIBRARY              Compiler supports the library directive (D6)
  SUPPORTS_PLATFORM             Compiler supports the platform directive (D6)
  SUPPORTS_CUSTOMVARIANTS       Compiler supports custom types for variants (D6)
  SUPPORTS_INLINING             Compiler supports inlining of Procedures (D9)
  HAS_UNIT_RTLCONSTS            RTL contains unit RtlConsts (D6)
  HAS_UNIT_STRUTILS             RTL contains unit StrUtils (D6)
  HAS_UNIT_TYPES                RTL contains unit Types (D6)
  HAS_UNIT_VARIANTS             RTL contains unit Variants (D6)
 
- Compiler Settings

  The compiler settings directives indicate whether a specific compiler setting
  is in effect. This facilitates changing compiler settings locally in a more
  compact and readible manner. The defines listed below use the OPTION_ prefix.

  Directive              Description
  ------------------------------------------------------------------------------
  ALIGN_ON               Compiling in the A+ state (no alignment)
  BOOLEVAL_ON            Compiling in the B+ state (complete boolean evaluation)
  ASSERTIONS_ON          Compiling in the C+ state (assertions on)
  DEBUGINFO_ON           Compiling in the D+ state (debug info generation on)
  IMPORTEDDATA_ON        Compiling in the G+ state (creation of imported data references)
  LONGSTRINGS_ON         Compiling in the H+ state (string defined as AnsiString)
  IOCHECKS_ON            Compiling in the I+ state (I/O checking enabled)
  WRITEABLECONST_ON      Compiling in the J+ state (typed constants can be modified)
  LOCALSYMBOLS           Compiling in the L+ state (local symbol generation)
  TYPEINFO_ON            Compiling in the M+ state (RTTI generation on)
  OPTIMIZATION_ON        Compiling in the O+ state (code optimization on)
  OPENSTRINGS_ON         Compiling in the P+ state (variable string parameters are openstrings)
  OVERFLOWCHECKS_ON      Compiling in the Q+ state (overflow checing on)
  RANGECHECKS_ON         Compiling in the R+ state (range checking on)
  TYPEDADDRESS_ON        Compiling in the T+ state (pointers obtained using the @ operator are typed)
  SAFEDIVIDE_ON          Compiling in the U+ state (save FDIV instruction through RTL emulation)
  VARSTRINGCHECKS_ON     Compiling in the V+ state (type checking of shortstrings)
  STACKFRAMES_ON         Compiling in the W+ state (generation of stack frames)
  EXTENDEDSYNTAX_ON      Compiling in the X+ state (Delphi extended syntax enabled)

}

//------------------------------------------------------------------------------
// Compiler settings
//------------------------------------------------------------------------------

{$IFOPT A+}{$DEFINE OPTION_ALIGN_ON}{$ENDIF}
{$IFOPT B+}{$DEFINE OPTION_BOOLEVAL_ON}{$ENDIF}
{$IFOPT C+}{$DEFINE OPTION_ASSERTIONS_ON}{$ENDIF}
{$IFOPT D+}{$DEFINE OPTION_DEBUGINFO_ON}{$ENDIF}
{$IFOPT G+}{$DEFINE OPTION_IMPORTEDDATA_ON}{$ENDIF}
{$IFOPT H+}{$DEFINE OPTION_LONGSTRINGS_ON}{$ENDIF}
//HINTS
{$IFOPT I+}{$DEFINE OPTION_IOCHECKS_ON}{$ENDIF}
{$IFOPT J+}{$DEFINE OPTION_WRITEABLECONST_ON}{$ENDIF}
{$IFOPT L+}{$DEFINE OPTION_LOCALSYMBOLS}{$ENDIF}
{$IFOPT M+}{$DEFINE OPTION_TYPEINFO_ON}{$ENDIF}
{$IFOPT O+}{$DEFINE OPTION_OPTIMIZATION_ON}{$ENDIF}
{$IFOPT P+}{$DEFINE OPTION_OPENSTRINGS_ON}{$ENDIF}
{$IFOPT Q+}{$DEFINE OPTION_OVERFLOWCHECKS_ON}{$ENDIF}
{$IFOPT R+}{$DEFINE OPTION_RANGECHECKS_ON}{$ENDIF}
//REALCOMPATIBILITY
{$IFOPT T+}{$DEFINE OPTION_TYPEDADDRESS_ON}{$ENDIF}
{$IFOPT U+}{$DEFINE OPTION_SAFEDIVIDE_ON}{$ENDIF}
{$IFOPT V+}{$DEFINE OPTION_VARSTRINGCHECKS_ON}{$ENDIF}
{$IFOPT W+}{$DEFINE OPTION_STACKFRAMES_ON}{$ENDIF}
//WARNINGS
{$IFOPT X+}{$DEFINE OPTION_EXTENDEDSYNTAX_ON}{$ENDIF}

//------------------------------------------------------------------------------
// Undefine all possible predefined symbols
//------------------------------------------------------------------------------

{$UNDEF DELPHI}
{$UNDEF KYLIX}
//BCB mustn't be undefined as it is necessary for detection!!!
//FPC mustn't be undefined as it is necessary for detection!!!

{$UNDEF COMPILER1}  {$UNDEF COMPILER1_DOWN} {$UNDEF COMPILER1_UP}
{$UNDEF COMPILER2}  {$UNDEF COMPILER2_DOWN} {$UNDEF COMPILER2_UP}
{$UNDEF COMPILER3}  {$UNDEF COMPILER3_DOWN} {$UNDEF COMPILER3_UP}
{$UNDEF COMPILER35} {$UNDEF COMPILER35DOWN} {$UNDEF COMPILER35UP}
{$UNDEF COMPILER4}  {$UNDEF COMPILER4_DOWN} {$UNDEF COMPILER4_UP}
{$UNDEF COMPILER5}  {$UNDEF COMPILER5_DOWN} {$UNDEF COMPILER5_UP}
{$UNDEF COMPILER6}  {$UNDEF COMPILER6_DOWN} {$UNDEF COMPILER6_UP}
{$UNDEF COMPILER7}  {$UNDEF COMPILER7_DOWN} {$UNDEF COMPILER7_UP}
{$UNDEF COMPILER8}  {$UNDEF COMPILER8_DOWN} {$UNDEF COMPILER8_UP}
{$UNDEF COMPILER9}  {$UNDEF COMPILER9_DOWN} {$UNDEF COMPILER9_UP}

{$UNDEF BCB1}       {$UNDEF BCB1_DOWN}      {$UNDEF BCB1_UP}
{$UNDEF BCB2}       {$UNDEF BCB2_DOWN}      {$UNDEF BCB2_UP}
{$UNDEF BCB3}       {$UNDEF BCB3_DOWN}      {$UNDEF BCB3_UP}
{$UNDEF BCB4}       {$UNDEF BCB4_DOWN}      {$UNDEF BCB4_UP}
{$UNDEF BCB5}       {$UNDEF BCB5_DOWN}      {$UNDEF BCB5_UP}
{$UNDEF BCB6}       {$UNDEF BCB6_DOWN}      {$UNDEF BCB6_UP}
{$UNDEF BCB7}       {$UNDEF BCB7_DOWN}      {$UNDEF BCB7_UP}

{$UNDEF DELPHI1}    {$UNDEF DELPHI1_DOWN}   {$UNDEF DELPHI1_UP}
{$UNDEF DELPHI2}    {$UNDEF DELPHI2_DOWN}   {$UNDEF DELPHI2_UP}
{$UNDEF DELPHI3}    {$UNDEF DELPHI3_DOWN}   {$UNDEF DELPHI3_UP}
{$UNDEF DELPHI4}    {$UNDEF DELPHI4_DOWN}   {$UNDEF DELPHI4_UP}
{$UNDEF DELPHI5}    {$UNDEF DELPHI5_DOWN}   {$UNDEF DELPHI5_UP}
{$UNDEF DELPHI6}    {$UNDEF DELPHI6_DOWN}   {$UNDEF DELPHI6_UP}
{$UNDEF DELPHI7}    {$UNDEF DELPHI7_DOWN}   {$UNDEF DELPHI7_UP}
{$UNDEF DELPHI8}    {$UNDEF DELPHI8_DOWN}   {$UNDEF DELPHI8_UP}
{$UNDEF DELPHI9}    {$UNDEF DELPHI9_DOWN}   {$UNDEF DELPHI9_UP}

{$UNDEF FPC0X}      {$UNDEF FPC0X_DOWN}     {$UNDEF FPC0X_UP}
{$UNDEF FPC1X}      {$UNDEF FPC1X_DOWN}     {$UNDEF FPC1X_UP}
{$UNDEF FPC2X}      {$UNDEF FPC2X_DOWN}     {$UNDEF FPC2X_UP}

{$UNDEF FPC01}      {$UNDEF FPC01_DOWN}     {$UNDEF FPC01_UP}
{$UNDEF FPC02}      {$UNDEF FPC02_DOWN}     {$UNDEF FPC02_UP}
{$UNDEF FPC03}      {$UNDEF FPC03_DOWN}     {$UNDEF FPC03_UP}
{$UNDEF FPC04}      {$UNDEF FPC04_DOWN}     {$UNDEF FPC04_UP}
{$UNDEF FPC05}      {$UNDEF FPC05_DOWN}     {$UNDEF FPC05_UP}
{$UNDEF FPC06}      {$UNDEF FPC06_DOWN}     {$UNDEF FPC06_UP}
{$UNDEF FPC07}      {$UNDEF FPC07_DOWN}     {$UNDEF FPC07_UP}
{$UNDEF FPC08}      {$UNDEF FPC08_DOWN}     {$UNDEF FPC08_UP}
{$UNDEF FPC09}      {$UNDEF FPC09_DOWN}     {$UNDEF FPC09_UP}
{$UNDEF FPC10}      {$UNDEF FPC10_DOWN}     {$UNDEF FPC10_UP}
{$UNDEF FPC11}      {$UNDEF FPC11_DOWN}     {$UNDEF FPC11_UP}
{$UNDEF FPC12}      {$UNDEF FPC12_DOWN}     {$UNDEF FPC12_UP}
{$UNDEF FPC13}      {$UNDEF FPC13_DOWN}     {$UNDEF FPC13_UP}
{$UNDEF FPC14}      {$UNDEF FPC14_DOWN}     {$UNDEF FPC14_UP}
{$UNDEF FPC15}      {$UNDEF FPC15_DOWN}     {$UNDEF FPC15_UP}
{$UNDEF FPC16}      {$UNDEF FPC16_DOWN}     {$UNDEF FPC16_UP}
{$UNDEF FPC17}      {$UNDEF FPC17_DOWN}     {$UNDEF FPC17_UP}
{$UNDEF FPC18}      {$UNDEF FPC18_DOWN}     {$UNDEF FPC18_UP}
{$UNDEF FPC19}      {$UNDEF FPC19_DOWN}     {$UNDEF FPC19_UP}
{$UNDEF FPC20}      {$UNDEF FPC20_DOWN}     {$UNDEF FPC20_UP}

{$UNDEF KYLIX1}     {$UNDEF KYLIX1_DOWN}    {$UNDEF KYLIX1_UP}
{$UNDEF KYLIX2}     {$UNDEF KYLIX2_DOWN}    {$UNDEF KYLIX2_UP}
{$UNDEF KYLIX3}     {$UNDEF KYLIX3_DOWN}    {$UNDEF KYLIX3_UP}

//------------------------------------------------------------------------------
// Cross-platform related defines
//------------------------------------------------------------------------------

{$IFDEF WIN32}
    {$DEFINE MSWINDOWS}
{$ENDIF}

{$IFDEF MSWINDOWS}
    {$DEFINE WIN32}
{$ENDIF}

{$IFDEF LINUX}
    {$IFNDEF FPC}
        {$DEFINE UNIX}
        {$DEFINE KYLIX}
        {$DEFINE VisualCLX}
        {$UNDEF VCL}
    {$ENDIF}
{$ENDIF}

//------------------------------------------------------------------------------
// VERXXX to COMPILERX, DELPHIX and BCBX mappings
//------------------------------------------------------------------------------

{$IFDEF VER170} {$DEFINE COMPILER9} {$DEFINE DELPHI9}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER160} {$DEFINE COMPILER8} {$DEFINE DELPHI8}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF BCB}
{$IFDEF VER150} {$DEFINE COMPILER7} {$DEFINE BCB7}      {$DEFINE BCB}   {$ENDIF}
{$IFDEF VER140} {$DEFINE COMPILER6} {$DEFINE BCB6}      {$DEFINE BCB}   {$ENDIF}
{$IFDEF VER130} {$DEFINE COMPILER5} {$DEFINE BCB5}      {$DEFINE BCB}   {$ENDIF}
{$ELSE}
{$IFDEF VER150} {$DEFINE COMPILER7} {$DEFINE DELPHI7}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER140} {$DEFINE COMPILER6} {$DEFINE DELPHI6}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER130} {$DEFINE COMPILER5} {$DEFINE DELPHI5}   {$DEFINE DELPHI}{$ENDIF}
{$ENDIF}
{$IFDEF VER125} {$DEFINE COMPILER4} {$DEFINE BCB4}      {$DEFINE BCB}   {$ENDIF}
{$IFDEF VER120} {$DEFINE COMPILER4} {$DEFINE DELPHI4}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER110} {$DEFINE COMPILER35}{$DEFINE BCB35}     {$DEFINE BCB}   {$ENDIF}
{$IFDEF VER100} {$DEFINE COMPILER3} {$DEFINE DELPHI3}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER93}  {$DEFINE COMPILER2} {$DEFINE BCB1}      {$DEFINE BCB}   {$ENDIF}
{$IFDEF VER90}  {$DEFINE COMPILER2} {$DEFINE DELPHI2}   {$DEFINE DELPHI}{$ENDIF}
{$IFDEF VER80}  {$DEFINE COMPILER1} {$DEFINE DELPHI1}   {$DEFINE DELPHI}{$ENDIF}

{$IFDEF FPC}
{$IFDEF VER0}   {$DEFINE FPC0X}     {$ENDIF}
{$IFDEF VER1}   {$DEFINE FPC1X}     {$ENDIF}
{$IFDEF VER2}   {$DEFINE FPC2X}     {$ENDIF}

{$IFDEF VER0_1} {$DEFINE FPC01}     {$ENDIF}
{$IFDEF VER0_2} {$DEFINE FPC02}     {$ENDIF}
{$IFDEF VER0_3} {$DEFINE FPC03}     {$ENDIF}
{$IFDEF VER0_4} {$DEFINE FPC04}     {$ENDIF}
{$IFDEF VER0_5} {$DEFINE FPC05}     {$ENDIF}
{$IFDEF VER0_6} {$DEFINE FPC06}     {$ENDIF}
{$IFDEF VER0_7} {$DEFINE FPC07}     {$ENDIF}
{$IFDEF VER0_8} {$DEFINE FPC08}     {$ENDIF}
{$IFDEF VER0_9} {$DEFINE FPC09}     {$ENDIF}
{$IFDEF VER1_0} {$DEFINE FPC10}     {$ENDIF}
{$IFDEF VER1_1} {$DEFINE FPC11}     {$ENDIF}
{$IFDEF VER1_2} {$DEFINE FPC12}     {$ENDIF}
{$IFDEF VER1_3} {$DEFINE FPC13}     {$ENDIF}
{$IFDEF VER1_4} {$DEFINE FPC14}     {$ENDIF}
{$IFDEF VER1_5} {$DEFINE FPC15}     {$ENDIF}
{$IFDEF VER1_6} {$DEFINE FPC16}     {$ENDIF}
{$IFDEF VER1_7} {$DEFINE FPC17}     {$ENDIF}
{$IFDEF VER1_8} {$DEFINE FPC18}     {$ENDIF}
{$IFDEF VER1_9} {$DEFINE FPC19}     {$ENDIF}
{$IFDEF VER2_0} {$DEFINE FPC20}     {$ENDIF}
{$ENDIF}

//------------------------------------------------------------------------------
// BCBX_UP and BCBX_DOWN from BCBX mappings
//------------------------------------------------------------------------------

{$IFDEF BCB1}       {$DEFINE BCB1_UP}       {$DEFINE BCB1_DOWN}     {$ENDIF}
{$IFDEF BCB2}       {$DEFINE BCB2_UP}       {$DEFINE BCB2_DOWN}     {$ENDIF}
{$IFDEF BCB3}       {$DEFINE BCB3_UP}       {$DEFINE BCB3_DOWN}     {$ENDIF}
{$IFDEF BCB4}       {$DEFINE BCB4_UP}       {$DEFINE BCB4_DOWN}     {$ENDIF}
{$IFDEF BCB5}       {$DEFINE BCB5_UP}       {$DEFINE BCB5_DOWN}     {$ENDIF}
{$IFDEF BCB6}       {$DEFINE BCB6_UP}       {$DEFINE BCB6_DOWN}     {$ENDIF}
{$IFDEF BCB7}       {$DEFINE BCB7_UP}       {$DEFINE BCB7_DOWN}     {$ENDIF}

{$IFDEF BCB7_UP}    {$DEFINE BCB6_UP}       {$ENDIF}
{$IFDEF BCB6_UP}    {$DEFINE BCB5_UP}       {$ENDIF}
{$IFDEF BCB5_UP}    {$DEFINE BCB4_UP}       {$ENDIF}
{$IFDEF BCB4_UP}    {$DEFINE BCB3_UP}       {$ENDIF}
{$IFDEF BCB3_UP}    {$DEFINE BCB2_UP}       {$ENDIF}
{$IFDEF BCB2_UP}    {$DEFINE BCB1_UP}       {$ENDIF}

{$IFDEF BCB1_DOWN}  {$DEFINE BCB2_DOWN}     {$ENDIF}
{$IFDEF BCB2_DOWN}  {$DEFINE BCB3_DOWN}     {$ENDIF}
{$IFDEF BCB3_DOWN}  {$DEFINE BCB4_DOWN}     {$ENDIF}
{$IFDEF BCB4_DOWN}  {$DEFINE BCB5_DOWN}     {$ENDIF}
{$IFDEF BCB5_DOWN}  {$DEFINE BCB6_DOWN}     {$ENDIF}
{$IFDEF BCB6_DOWN}  {$DEFINE BCB7_DOWN}     {$ENDIF}

//------------------------------------------------------------------------------
// DELPHIX_UP and DELPHIX_DOWN from DELPHIX mappings
//------------------------------------------------------------------------------

{$IFDEF DELPHI1}    {$DEFINE DELPHI1_UP}    {$DEFINE DELPHI1_DOWN}  {$ENDIF}
{$IFDEF DELPHI2}    {$DEFINE DELPHI2_UP}    {$DEFINE DELPHI2_DOWN}  {$ENDIF}
{$IFDEF DELPHI3}    {$DEFINE DELPHI3_UP}    {$DEFINE DELPHI3_DOWN}  {$ENDIF}
{$IFDEF DELPHI4}    {$DEFINE DELPHI4_UP}    {$DEFINE DELPHI4_DOWN}  {$ENDIF}
{$IFDEF DELPHI5}    {$DEFINE DELPHI5_UP}    {$DEFINE DELPHI5_DOWN}  {$ENDIF}
{$IFDEF DELPHI6}    {$DEFINE DELPHI6_UP}    {$DEFINE DELPHI6_DOWN}  {$ENDIF}
{$IFDEF DELPHI7}    {$DEFINE DELPHI7_UP}    {$DEFINE DELPHI7_DOWN}  {$ENDIF}
{$IFDEF DELPHI8}    {$DEFINE DELPHI8_UP}    {$DEFINE DELPHI8_DOWN}  {$ENDIF}
{$IFDEF DELPHI9}    {$DEFINE DELPHI9_UP}    {$DEFINE DELPHI9_DOWN}  {$ENDIF}

{$IFDEF DELPHI9_UP} {$DEFINE DELPHI8_UP}    {$ENDIF}
{$IFDEF DELPHI8_UP} {$DEFINE DELPHI7_UP}    {$ENDIF}
{$IFDEF DELPHI7_UP} {$DEFINE DELPHI6_UP}    {$ENDIF}
{$IFDEF DELPHI6_UP} {$DEFINE DELPHI5_UP}    {$ENDIF}
{$IFDEF DELPHI5_UP} {$DEFINE DELPHI4_UP}    {$ENDIF}
{$IFDEF DELPHI4_UP} {$DEFINE DELPHI3_UP}    {$ENDIF}
{$IFDEF DELPHI3_UP} {$DEFINE DELPHI2_UP}    {$ENDIF}
{$IFDEF DELPHI2_UP} {$DEFINE DELPHI1_UP}    {$ENDIF}

{$IFDEF DELPHI1_DOWN}{$DEFINE DELPHI2_DOWN} {$ENDIF}
{$IFDEF DELPHI2_DOWN}{$DEFINE DELPHI3_DOWN} {$ENDIF}
{$IFDEF DELPHI3_DOWN}{$DEFINE DELPHI4_DOWN} {$ENDIF}
{$IFDEF DELPHI4_DOWN}{$DEFINE DELPHI5_DOWN} {$ENDIF}
{$IFDEF DELPHI5_DOWN}{$DEFINE DELPHI6_DOWN} {$ENDIF}
{$IFDEF DELPHI6_DOWN}{$DEFINE DELPHI7_DOWN} {$ENDIF}
{$IFDEF DELPHI7_DOWN}{$DEFINE DELPHI8_DOWN} {$ENDIF}
{$IFDEF DELPHI8_DOWN}{$DEFINE DELPHI9_DOWN} {$ENDIF}

//------------------------------------------------------------------------------
// FPCX_UP and FPCX_DOWN from FPCX mappings
//------------------------------------------------------------------------------

{$IFDEF FPC0X}      {$DEFINE FPC0X_UP}      {$DEFINE FPC0X_DOWN}    {$ENDIF}
{$IFDEF FPC1X}      {$DEFINE FPC1X_UP}      {$DEFINE FPC1X_DOWN}    {$ENDIF}
{$IFDEF FPC2X}      {$DEFINE FPC2X_UP}      {$DEFINE FPC2X_DOWN}    {$ENDIF}

{$IFDEF FPC2X_UP}   {$DEFINE FPC1X_UP}      {$ENDIF}
{$IFDEF FPC1X_UP}   {$DEFINE FPC0X_UP}      {$ENDIF}

{$IFDEF FPC0X_DOWN} {$DEFINE FPC1X_DOWN}    {$ENDIF}
{$IFDEF FPC1X_DOWN} {$DEFINE FPC2X_DOWN}    {$ENDIF}

{$IFDEF FPC01}      {$DEFINE FPC01_UP}      {$DEFINE FPC01_DOWN}    {$ENDIF}
{$IFDEF FPC02}      {$DEFINE FPC02_UP}      {$DEFINE FPC02_DOWN}    {$ENDIF}
{$IFDEF FPC03}      {$DEFINE FPC03_UP}      {$DEFINE FPC03_DOWN}    {$ENDIF}
{$IFDEF FPC04}      {$DEFINE FPC04_UP}      {$DEFINE FPC04_DOWN}    {$ENDIF}
{$IFDEF FPC05}      {$DEFINE FPC05_UP}      {$DEFINE FPC05_DOWN}    {$ENDIF}
{$IFDEF FPC06}      {$DEFINE FPC06_UP}      {$DEFINE FPC06_DOWN}    {$ENDIF}
{$IFDEF FPC07}      {$DEFINE FPC07_UP}      {$DEFINE FPC07_DOWN}    {$ENDIF}
{$IFDEF FPC08}      {$DEFINE FPC08_UP}      {$DEFINE FPC08_DOWN}    {$ENDIF}
{$IFDEF FPC09}      {$DEFINE FPC09_UP}      {$DEFINE FPC09_DOWN}    {$ENDIF}
{$IFDEF FPC10}      {$DEFINE FPC10_UP}      {$DEFINE FPC10_DOWN}    {$ENDIF}
{$IFDEF FPC11}      {$DEFINE FPC11_UP}      {$DEFINE FPC11_DOWN}    {$ENDIF}
{$IFDEF FPC12}      {$DEFINE FPC12_UP}      {$DEFINE FPC12_DOWN}    {$ENDIF}
{$IFDEF FPC13}      {$DEFINE FPC13_UP}      {$DEFINE FPC13_DOWN}    {$ENDIF}
{$IFDEF FPC14}      {$DEFINE FPC14_UP}      {$DEFINE FPC14_DOWN}    {$ENDIF}
{$IFDEF FPC15}      {$DEFINE FPC15_UP}      {$DEFINE FPC15_DOWN}    {$ENDIF}
{$IFDEF FPC16}      {$DEFINE FPC16_UP}      {$DEFINE FPC16_DOWN}    {$ENDIF}
{$IFDEF FPC17}      {$DEFINE FPC17_UP}      {$DEFINE FPC17_DOWN}    {$ENDIF}
{$IFDEF FPC18}      {$DEFINE FPC18_UP}      {$DEFINE FPC18_DOWN}    {$ENDIF}
{$IFDEF FPC19}      {$DEFINE FPC19_UP}      {$DEFINE FPC19_DOWN}    {$ENDIF}
{$IFDEF FPC20}      {$DEFINE FPC20_UP}      {$DEFINE FPC20_DOWN}    {$ENDIF}

{$IFDEF FPC20_UP}   {$DEFINE FPC19_UP}      {$ENDIF}
{$IFDEF FPC19_UP}   {$DEFINE FPC18_UP}      {$ENDIF}
{$IFDEF FPC18_UP}   {$DEFINE FPC17_UP}      {$ENDIF}
{$IFDEF FPC17_UP}   {$DEFINE FPC16_UP}      {$ENDIF}
{$IFDEF FPC16_UP}   {$DEFINE FPC15_UP}      {$ENDIF}
{$IFDEF FPC15_UP}   {$DEFINE FPC14_UP}      {$ENDIF}
{$IFDEF FPC14_UP}   {$DEFINE FPC13_UP}      {$ENDIF}
{$IFDEF FPC13_UP}   {$DEFINE FPC12_UP}      {$ENDIF}
{$IFDEF FPC12_UP}   {$DEFINE FPC11_UP}      {$ENDIF}
{$IFDEF FPC11_UP}   {$DEFINE FPC10_UP}      {$ENDIF}
{$IFDEF FPC10_UP}   {$DEFINE FPC09_UP}      {$ENDIF}
{$IFDEF FPC09_UP}   {$DEFINE FPC08_UP}      {$ENDIF}
{$IFDEF FPC08_UP}   {$DEFINE FPC07_UP}      {$ENDIF}
{$IFDEF FPC07_UP}   {$DEFINE FPC06_UP}      {$ENDIF}
{$IFDEF FPC06_UP}   {$DEFINE FPC05_UP}      {$ENDIF}
{$IFDEF FPC05_UP}   {$DEFINE FPC04_UP}      {$ENDIF}
{$IFDEF FPC04_UP}   {$DEFINE FPC03_UP}      {$ENDIF}
{$IFDEF FPC03_UP}   {$DEFINE FPC02_UP}      {$ENDIF}
{$IFDEF FPC02_UP}   {$DEFINE FPC01_UP}      {$ENDIF}

{$IFDEF FPC01_DOWN} {$DEFINE FPC02_DOWN}    {$ENDIF}
{$IFDEF FPC02_DOWN} {$DEFINE FPC03_DOWN}    {$ENDIF}
{$IFDEF FPC03_DOWN} {$DEFINE FPC04_DOWN}    {$ENDIF}
{$IFDEF FPC04_DOWN} {$DEFINE FPC05_DOWN}    {$ENDIF}
{$IFDEF FPC05_DOWN} {$DEFINE FPC06_DOWN}    {$ENDIF}
{$IFDEF FPC06_DOWN} {$DEFINE FPC07_DOWN}    {$ENDIF}
{$IFDEF FPC07_DOWN} {$DEFINE FPC08_DOWN}    {$ENDIF}
{$IFDEF FPC08_DOWN} {$DEFINE FPC09_DOWN}    {$ENDIF}
{$IFDEF FPC09_DOWN} {$DEFINE FPC10_DOWN}    {$ENDIF}
{$IFDEF FPC10_DOWN} {$DEFINE FPC11_DOWN}    {$ENDIF}
{$IFDEF FPC11_DOWN} {$DEFINE FPC12_DOWN}    {$ENDIF}
{$IFDEF FPC12_DOWN} {$DEFINE FPC13_DOWN}    {$ENDIF}
{$IFDEF FPC13_DOWN} {$DEFINE FPC14_DOWN}    {$ENDIF}
{$IFDEF FPC14_DOWN} {$DEFINE FPC15_DOWN}    {$ENDIF}
{$IFDEF FPC15_DOWN} {$DEFINE FPC16_DOWN}    {$ENDIF}
{$IFDEF FPC16_DOWN} {$DEFINE FPC17_DOWN}    {$ENDIF}
{$IFDEF FPC17_DOWN} {$DEFINE FPC18_DOWN}    {$ENDIF}
{$IFDEF FPC18_DOWN} {$DEFINE FPC19_DOWN}    {$ENDIF}
{$IFDEF FPC19_DOWN} {$DEFINE FPC20_DOWN}    {$ENDIF}

//------------------------------------------------------------------------------
// KYLIXX_UP and KYLIXX_DOWN from KYLIXX mappings
//------------------------------------------------------------------------------

{$IFDEF KYLIX1}     {$DEFINE KYLIX1_UP}     {$DEFINE KYLIX1_DOWN}   {$ENDIF}
{$IFDEF KYLIX2}     {$DEFINE KYLIX2_UP}     {$DEFINE KYLIX2_DOWN}   {$ENDIF}
{$IFDEF KYLIX3}     {$DEFINE KYLIX3_UP}     {$DEFINE KYLIX3_DOWN}   {$ENDIF}

{$IFDEF KYLIX3_UP}  {$DEFINE KYLIX2_UP}     {$ENDIF}
{$IFDEF KYLIX2_UP}  {$DEFINE KYLIX1_UP}     {$ENDIF}

{$IFDEF KYLIX1_DOWN}{$DEFINE KYLIX2_DOWN}   {$ENDIF}
{$IFDEF KYLIX2_DOWN}{$DEFINE KYLIX3_DOWN}   {$ENDIF}

//------------------------------------------------------------------------------
// COMPILERX_UP and COMPILERX_DOWN from COMPILERX mappings
//------------------------------------------------------------------------------

{$IFDEF COMPILER1}  {$DEFINE COMPILER1_UP}  {$DEFINE COMPILER1_DOWN}    {$ENDIF}
{$IFDEF COMPILER2}  {$DEFINE COMPILER2_UP}  {$DEFINE COMPILER2_DOWN}    {$ENDIF}
{$IFDEF COMPILER3}  {$DEFINE COMPILER3_UP}  {$DEFINE COMPILER3_DOWN}    {$ENDIF}
{$IFDEF COMPILER35} {$DEFINE COMPILER35UP}  {$DEFINE COMPILER35DOWN}    {$ENDIF}
{$IFDEF COMPILER4}  {$DEFINE COMPILER4_UP}  {$DEFINE COMPILER4_DOWN}    {$ENDIF}
{$IFDEF COMPILER5}  {$DEFINE COMPILER5_UP}  {$DEFINE COMPILER5_DOWN}    {$ENDIF}
{$IFDEF COMPILER6}  {$DEFINE COMPILER6_UP}  {$DEFINE COMPILER6_DOWN}    {$ENDIF}
{$IFDEF COMPILER7}  {$DEFINE COMPILER7_UP}  {$DEFINE COMPILER7_DOWN}    {$ENDIF}
{$IFDEF COMPILER8}  {$DEFINE COMPILER8_UP}  {$DEFINE COMPILER8_DOWN}    {$ENDIF}
{$IFDEF COMPILER9}  {$DEFINE COMPILER9_UP}  {$DEFINE COMPILER9_DOWN}    {$ENDIF}

{$IFDEF COMPILER9_UP}{$DEFINE COMPILER8_UP}{$ENDIF}
{$IFDEF COMPILER8_UP}{$DEFINE COMPILER7_UP}{$ENDIF}
{$IFDEF COMPILER7_UP}{$DEFINE COMPILER6_UP}{$ENDIF}
{$IFDEF COMPILER6_UP}{$DEFINE COMPILER5_UP}{$ENDIF}
{$IFDEF COMPILER5_UP}{$DEFINE COMPILER4_UP}{$ENDIF}
{$IFDEF COMPILER4_UP}{$DEFINE COMPILER35UP}{$ENDIF}
{$IFDEF COMPILER35UP}{$DEFINE COMPILER3_UP}{$ENDIF}
{$IFDEF COMPILER3_UP}{$DEFINE COMPILER2_UP}{$ENDIF}
{$IFDEF COMPILER2_UP}{$DEFINE COMPILER1_UP}{$ENDIF}

{$IFDEF COMPILER1_DOWN}{$DEFINE COMPILER2_DOWN}{$ENDIF}
{$IFDEF COMPILER2_DOWN}{$DEFINE COMPILER3_DOWN}{$ENDIF}
{$IFDEF COMPILER3_DOWN}{$DEFINE COMPILER35DOWN}{$ENDIF}
{$IFDEF COMPILER35DOWN}{$DEFINE COMPILER4_DOWN}{$ENDIF}
{$IFDEF COMPILER4_DOWN}{$DEFINE COMPILER5_DOWN}{$ENDIF}
{$IFDEF COMPILER5_DOWN}{$DEFINE COMPILER6_DOWN}{$ENDIF}
{$IFDEF COMPILER6_DOWN}{$DEFINE COMPILER7_DOWN}{$ENDIF}
{$IFDEF COMPILER7_DOWN}{$DEFINE COMPILER8_DOWN}{$ENDIF}
{$IFDEF COMPILER8_DOWN}{$DEFINE COMPILER9_DOWN}{$ENDIF}

//------------------------------------------------------------------------------
// Map COMPILERX_UP to friendly feature names
//------------------------------------------------------------------------------

{$IFDEF COMPILER3_UP}
  {$DEFINE SUPPORTS_INTERFACE}
  {$DEFINE SUPPORTS_WIDESTRING}
{$ENDIF}

{$IFDEF COMPILER35UP}
  {$DEFINE SUPPORTS_EXTSYM}
  {$DEFINE SUPPORTS_NODEFINE}
{$ENDIF}

{$IFDEF COMPILER4_UP}
  {$DEFINE SUPPORTS_DEFAULTPARAMS}
  {$DEFINE SUPPORTS_DYNAMICARRAYS}
  {$DEFINE SUPPORTS_INT64}
  {$DEFINE SUPPORTS_OVERLOAD_METHODS}
{$ENDIF}

{$IFDEF COMPILER6_UP}
  {$DEFINE HAS_UNIT_RTLCONSTS}
  {$DEFINE HAS_UNIT_STRUTILS}
  {$DEFINE HAS_UNIT_TYPES}
  {$DEFINE HAS_UNIT_VARIANTS}

  {$DEFINE SUPPORTS_CUSTOMVARIANTS}
  {$DEFINE SUPPORTS_DEPRECATED}
  {$DEFINE SUPPORTS_LIBRARY}
  {$DEFINE SUPPORTS_PLATFORM}
{$ENDIF COMPILER6_UP}

{$IFDEF COMPILER9_UP}
  {$DEFINE SUPPORTS_INLINING}
{$ENDIF COMPILER9_UP}

{$IFDEF FPC}
  {$DEFINE SUPPORTS_ALIASES}
  {$DEFINE SUPPORTS_DEFAULTPARAMS}
  {$DEFINE SUPPORTS_DYNAMICARRAYS}
  {$DEFINE SUPPORTS_INLINING}
  {$DEFINE SUPPORTS_INT64}
  {$DEFINE SUPPORTS_INTERFACE}
  {$DEFINE SUPPORTS_OVERLOAD_METHODS}
  {$DEFINE SUPPORTS_OVERLOAD_OPERATORS}
  {$DEFINE SUPPORTS_WIDESTRING}
{$ENDIF FPC}

//------------------------------------------------------------------------------
// Complain about wrong platforms
//------------------------------------------------------------------------------

{$IFDEF BCB}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//  The Omorphia Library cannot be compiled with Borland C++ Builder.
//  If you are just kidding, forget about and restore the original
//  source situation. If this problem didn't appear due to some joke
//  try either to use another compiler or remove the BCB define out of
//  the project options.
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
{$ENDIF}

{$IFDEF FPC}
    {$MODE DELPHI}
    {$ASMMODE Intel}
    {$GOTO OFF}
    {$TYPEINFO ON}
    {$SMARTLINK ON}

    {$UNDEF ALLOW_FPC}
    {$IFDEF neo}    {$DEFINE ALLOW_FPC}{$ENDIF}
    {$IFDEF benbe}  {$DEFINE ALLOW_FPC}{$ENDIF}

    {$IFNDEF ALLOW_FPC}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//  The Omorphia Library cannot be compiled with FreePascal due to missing
//  Support for it at the moment. Later one there will probably be support
//  for it, but this release really doesn't support it. The current version
//  includes FPC detection only for test purposes and to port the Omorphia
//  Library to FPC, but there isn't any official support for FPC yet.
//
//  If you are just kidding, forget about and restore the original
//  source situation. If this problem didn't appear due to some joke
//  try either to use another compiler or remove the FPC define out of
//  the project options.
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
    {$ENDIF}

    {$UNDEF ALLOW_FPC}
{$ENDIF}

{$IFDEF KYLIX}
//Kylix Support
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//  The Omorphia Library cannot be compiled with Kylix due to missing
//  support for it at the moment. Later one there will probably be support
//  for it, but this release really doesn't support it.
//
//  If you are just kidding, forget about and restore the original
//  source situation. If this problem didn't appear due to some joke
//  try either to use another compiler or try compiling this files on
//  a Windows 32-bit plattform.
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
{$ENDIF}
