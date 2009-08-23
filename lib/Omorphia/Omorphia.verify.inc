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
// Check the previously made settings
//------------------------------------------------------------------------------

{$IFDEF BCB}
    {$IFDEF BCB6_DOWN}
        {$UNDEF OMORPHIA_USELIB_CLX}
        {$IFDEF VisualCLX}
            {$DEFINE VCL}
            {$UNDEF VisualCLX}
        {$ENDIF}
    {$ENDIF}
    {$UNDEF OMORPHIA_USELIB_FCL}
    {$UNDEF OMORPHIA_USELIB_KOL}
    {$UNDEF OMORPHIA_USELIB_JEDI}
    {$IFDEF OMORPHIA_USELIB_CLX}
        {$IFDEF OMORPHIA_USELIB_VCL}
            //The rare chance that both VisualCLX and VCL should be used.
            //If we can determine which one is ment, we can fix this
            //problem automatically without user interaction.
            {$IFDEF VCL}
                {$IFDEF VisualCLX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Compiling this unit using VCL and VisualCLX together is impossible as those
//libraries are incompatible with each other!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
                {$ELSE}
                    {$UNDEF OMORPHIA_USELIB_CLX}
                    {$DEFINE OMORPHIA_USELIB_VCL}
                    {$DEFINE VCL}
                {$ENDIF}
            {$ELSE}
                {$DEFINE OMORPHIA_USELIB_CLX}
                {$UNDEF OMORPHIA_USELIB_VCL}
                {$DEFINE VisualCLX}
            {$ENDIF}
        {$ENDIF}
    {$ELSE}
        {$IFDEF OMORPHIA_USELIB_VCL}
            {$DEFINE VCL}
            {$UNDEF VisualCLX}
        {$ELSE}
            //The rare chance that both VisualCLX and VCL should be used.
            //If we can determine which one is ment, we can fix this
            //problem automatically without user interaction.
            {$IFDEF VCL}
                {$IFDEF VisualCLX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Compiling this unit using VCL and VisualCLX together is impossible as those
//libraries are incompatible with each other!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
                {$ELSE}
                    {$DEFINE OMORPHIA_USELIB_VCL}
                    {$DEFINE VCL}
                {$ENDIF}
            {$ELSE}
                {$IFDEF VisualCLX}
                    {$DEFINE OMORPHIA_USELIB_CLX}
                    {$DEFINE VisualCLX}
                {$ELSE}
                    {$DEFINE OMORPHIA_USELIB_VCL}
                    {$DEFINE VCL}
                {$ENDIF}
            {$ENDIF}
        {$ENDIF}
    {$ENDIF}
{$ENDIF}

{$IFDEF DELPHI}
    {$IFDEF DELPHI6_DOWN}
        {$UNDEF OMORPHIA_USELIB_CLX}
        {$IFDEF VisualCLX}
            {$DEFINE VCL}
            {$UNDEF VisualCLX}
        {$ENDIF}
    {$ENDIF}
    {$UNDEF OMORPHIA_USELIB_FCL}
    {$IFDEF OMORPHIA_USELIB_KOL}
        {$IFDEF OMORPHIA_USELIB_CLX}
            {$IFDEF VisualCLX}
                {$UNDEF OMORPHIA_USELIB_KOL}
            {$ELSE}
                {$UNDEF OMORPHIA_USELIB_CLX}
            {$ENDIF}
        {$ELSE}
            {$IFDEF OMORPHIA_USELIB_JEDI}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Compiling this unit using KOL and JCL\JVCL together is impossible as those
//libraries are incompatible with each other!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
            {$ELSE}
                {$IFDEF OMORPHIA_USELIB_VCL}
                    {$IFDEF VCL}
                        {$UNDEF OMORPHIA_USELIB_KOL}
                    {$ELSE}
                        {$UNDEF OMORPHIA_USELIB_VCL}
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ENDIF}
    {$ELSE}
        {$IFDEF OMORPHIA_USELIB_JEDI}
            {$IFDEF OMORPHIA_USELIB_CLX}
                {$IFDEF VisualCLX}
                    {$UNDEF OMORPHIA_USELIB_JEDI}
                {$ELSE}
                    {$UNDEF OMORPHIA_USELIB_CLX}
                {$ENDIF}
            {$ELSE}
                {$IFDEF OMORPHIA_USELIB_VCL}
                    {$IFDEF VCL}
                        {$UNDEF OMORPHIA_USELIB_JEDI}
                    {$ELSE}
                        {$UNDEF OMORPHIA_USELIB_VCL}
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ELSE}
            {$IFDEF OMORPHIA_USELIB_VCL}
                {$IFDEF OMORPHIA_USELIB_CLX}
                    {$IFDEF VCL}
                        {$IFDEF VisualCLX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Compiling this unit using VCL and VisualCLX together is impossible as those
//libraries are incompatible with each other!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
                        {$ELSE}
                            {$UNDEF OMORPHIA_USELIB_CLX}
                        {$ENDIF}
                    {$ELSE}
                        {$UNDEF OMORPHIA_USELIB_VCL}
                        {$DEFINE VisualCLX}
                    {$ENDIF}
                {$ELSE}
                    {$UNDEF VisualCLX}
                    {$DEFINE VCL}
                {$ENDIF}
            {$ELSE}
                {$IFDEF OMORPHIA_USELIB_CLX}
                    {$DEFINE VisualCLX}
                    {$UNDEF VCL}
                {$ELSE}
                    {$IFDEF VCL}
                        {$IFDEF VisualCLX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Compiling this unit using VCL and VisualCLX together is impossible as those
//libraries are incompatible with each other!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
                        {$ELSE}
                            {$DEFINE OMORPHIA_USELIB_VCL}
                        {$ENDIF}
                    {$ELSE}
                        {$IFDEF VisualCLX}
                            {$DEFINE OMORPHIA_USELIB_CLX}
                        {$ELSE}
                            {$DEFINE OMORPHIA_USELIB_VCL}
                            {$DEFINE VCL}
                        {$ENDIF}
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ENDIF}
    {$ENDIF}
{$ENDIF}

{$IFDEF FPC}
    {$UNDEF VCL}
    {$UNDEF VisualCLX}

    {$UNDEF OMORPHIA_USELIB_CLX}
    {$DEFINE OMORPHIA_USELIB_FCL}
    {$UNDEF OMORPHIA_USELIB_KOL}
    {$UNDEF OMORPHIA_USELIB_JEDI}
    {$UNDEF OMORPHIA_USELIB_VCL}
{$ENDIF}

{$IFDEF KYLIX}
    {$UNDEF VCL}
    {$DEFINE VisualCLX}

    {$DEFINE OMORPHIA_USELIB_CLX}
    {$UNDEF OMORPHIA_USELIB_FCL}
    {$UNDEF OMORPHIA_USELIB_KOL}
    {$UNDEF OMORPHIA_USELIB_JEDI}
    {$UNDEF OMORPHIA_USELIB_VCL}
{$ENDIF}

{$IFDEF WIN32}
    {$IFDEF LINUX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Please decide yourself for one platform you want to compile this unit with!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
    {$ENDIF}
    {$IFDEF UNIX}
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
//Please decide yourself for one platform you want to compile this unit with!
!!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!! !!!STOP!!!
    {$ENDIF}
{$ENDIF}

{$IFDEF OMORPHIA_USELANG_ENGLISH}
    {$IFDEF OMORPHIA_USELANG_GERMAN}
        {$UNDEFINE OMORPHIA_USELANG_GERMAN}
    {$ENDIF}
{$ENDIF}

{$IFNDEF OMORPHIA_USELANG_ENGLISH}
    {$IFNDEF OMORPHIA_USELANG_GERMAN}
        {$DEFINE OMORPHIA_USELANG_ENGLISH}
    {$ENDIF}
{$ENDIF}

{$UNDEF OMORPHIA_USEDBG_NEEDDEBUGGER}
{$IFDEF OMORPHIA_USEDBG_WARNINGS}
    {$DEFINE OMORPHIA_USEDBG_NEEDDEBUGGER}
{$ENDIF}
{$IFDEF OMORPHIA_USEDBG_ERRORS}
    {$DEFINE OMORPHIA_USEDBG_NEEDDEBUGGER}
{$ENDIF}

{$IFDEF OMORPHIA_DISABLE_UNSAFE}
    {$IFDEF DELPHI6_UP}
        {$WARN UNIT_PLATFORM OFF}       // Disable Unit Platform Warning Messages.
        {$WARN SYMBOL_PLATFORM OFF}     // Disable General Platform Warning Messages.

        {$WARN UNIT_DEPRECATED OFF}     // Disable Unit Deprecated Warning Messages.
        {$WARN SYMBOL_DEPRECATED OFF}   // Disable Symbol Deprecated Warning Messages.

        {$IFDEF DELPHI7_UP}
            {$WARN UNSAFE_CODE OFF}     // Disable Unsafe Code Warning Messages.
            {$WARN UNSAFE_TYPE OFF}     // Disable Unsafe Type Warning Messages.
            {$WARN UNSAFE_CAST OFF}     // Disable Unsafe TypeCast Warning Messages.
        {$ENDIF}
    {$ENDIF}
{$ENDIF}

{$IFNDEF OMORPHIA_BUILD_FINAL}
    {$IFNDEF OMORPHIA_BUILD_DEBUG}
        {$IFOPT D+}
            {$DEFINE OMORPHIA_BUILD_DEBUG}
        {$ELSE}
            {$DEFINE OMORPHIA_BUILD_FINAL}
        {$ENDIF}
    {$ENDIF}
{$ENDIF}

{$IFDEF OMORPHIA_BUILD_DEBUG}
    {$UNDEF OMORPHIA_BUILD_FINAL}
    {$DEBUGINFO ON}
    {$IFDEF DELPHI1_UP}
        {$IFDEF benbe}
            {$OPTIMIZATION ON}
        {$ELSE}
            {$OPTIMIZATION OFF}
        {$ENDIF}
    {$ENDIF}
    // Neo: need to be more, so i think
{$ENDIF}

{$IFDEF OMORPHIA_BUILD_FINAL}
    {$UNDEF OMORPHIA_BUILD_DEBUG}
    {$DEBUGINFO OFF}
    {$OPTIMIZATION ON}
    {$HINTS ON}
    {$WARNINGS ON}
    // Neo: need to be more, so i think
    // DONE -oBenBE -cInc, Compiler : Insert final compiler switches
{$ENDIF}

// BenBE: Important!!!
// BenBE: The following defines ARE NECESSARY due to many problems introduced by 
// Range and Overflow Checking 
{$Q-}   // Disable Overflow Checks
{$R-}   // Disable Range Checks
// BenBE: I really starta hate them!!!

{$IFDEF OMORPHIA_FEATURES_ALLOWASM}
    {$IFDEF I386}
        {$DEFINE OMORPHIA_FEATURES_USEASM}
    {$ENDIF}
    {$IFDEF CPU386}
        {$DEFINE OMORPHIA_FEATURES_USEASM}
    {$ENDIF}
{$ENDIF}

{$IFDEF OMORPHIA_FEATURES_ALLOWINLINE}
    {$IFDEF SUPPORTS_INLINING}
        {$DEFINE OMORPHIA_FEATURES_USEINLINE}
    {$ENDIF}
    {$IFDEF SUPPORTS_INLINING_ASM}
        {$DEFINE OMORPHIA_FEATURES_USEINLINE_ASM}
    {$ENDIF}

    {$UNDEF OMORPHIA_FEATURES_USEINLINE_PROCASM}
    {$IFDEF OMORPHIA_FEATURES_USEASM}
        {$IFDEF OMORPHIA_FEATURES_USEINLINE_ASM} 
            {$DEFINE OMORPHIA_FEATURES_USEINLINE_PROCASM}
        {$ENDIF} 
    {$ELSE}
        {$IFDEF OMORPHIA_FEATURES_USEINLINE} 
            {$DEFINE OMORPHIA_FEATURES_USEINLINE_PROCASM}
        {$ENDIF}
    {$ENDIF}    

    {$UNDEF OMORPHIA_FEATURES_USEINLINE_PROCPAS}
    {$IFDEF OMORPHIA_FEATURES_USEINLINE} 
        {$DEFINE OMORPHIA_FEATURES_USEINLINE_PROCPAS}
    {$ENDIF}
{$ENDIF}


