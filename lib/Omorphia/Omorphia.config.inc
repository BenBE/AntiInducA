// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Library Include Submodule
//
// This file defines the general options and features that the library is
// compiled with.
//
// Please note that changes in this file are global to the entire library.
//
// *****************************************************************************
// To Do:
//
// *****************************************************************************
// News:
//
// *****************************************************************************
// Bugs:
//
// *****************************************************************************
// Info:
//
// *****************************************************************************

//------------------------------------------------------------------------------
// Target Class Library Defines
//------------------------------------------------------------------------------

//Using of Omorphia without the VCL isn't possible at the moment. Support
//for this will be added later.
{.$DEFINE OMORPHIA_USELIB_CLX}          //requires Delphi 7+ or Kylix
{.$DEFINE OMORPHIA_USELIB_FCL}          //requires FreePascal
{.$DEFINE OMORPHIA_USELIB_JEDI}         //requires Delphi + JVCL 3 or Jedi.NET
{.$DEFINE OMORPHIA_USELIB_KOL}          //requires KOL
{$DEFINE OMORPHIA_USELIB_VCL}           //requires Delphi

//To enforce the use of VCL or VisualCLX in case of depth you can set at most
//ONE following defines. For compilers they aren't supported on, they are
//automatically removed. Please note that this overrides the target of an
//project as this defines are named the same as the values Delphi and BCB use.
{.$DEFINE VCL}
{.$DEFINE VisualCLX}

//------------------------------------------------------------------------------
// Language Options
//------------------------------------------------------------------------------

//Please select ONLY one of the following languages:
//In case of doubt, the library will default to english!
{$DEFINE OMORPHIA_USELANG_ENGLISH}
{.$DEFINE OMORPHIA_USELANG_GERMAN}

//------------------------------------------------------------------------------
// Using of Assembler Code
//------------------------------------------------------------------------------

//Enabling this define will allow the import of ASM optimized sources
//where applicable by the target platform\processor.
{$DEFINE OMORPHIA_FEATURES_ALLOWASM}
{$DEFINE OMORPHIA_FEATURES_ALLOWINLINE}

//------------------------------------------------------------------------------
// Display of compier messages
//------------------------------------------------------------------------------

//Please select the desired kind of build you want to create (defaults to debug):
{$DEFINE OMORPHIA_BUILD_DEBUG}
{.$DEFINE OMORPHIA_BUILD_FINAL}

//Disables warnings about unsafe types, pointers and type casts as well as
//depriciated yxmbolds and platform dependent units and identifiers.
{$DEFINE OMORPHIA_DISABLE_UNSAFE}

//------------------------------------------------------------------------------
// Logging of debugger messages
//------------------------------------------------------------------------------

//Please select the desired of the following defines:
{$DEFINE OMORPHIA_USEDBG_WARNINGS}
{$DEFINE OMORPHIA_USEDBG_ERRORS}

//------------------------------------------------------------------------------
// Check the previously made settings
//------------------------------------------------------------------------------

// Include the Compiler Version and Options Settings
{$I 'Omorphia.user.inc'}
{$I 'Omorphia.version.inc'}
{$I 'Omorphia.verify.inc'}
