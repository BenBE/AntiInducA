Unit OLangGeneral;
// *****************************************************************************
// Omorphia Library V0.0 - Planning State
// Localization Submodule
//
// This unit defines constants for localization of various languages.
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

// Include the Compiler Version and Options Settings
{$I 'Omorphia.config.inc'}

Interface

{$IFDEF OMORPHIA_USELANG_ENGLISH}
{$I 'lang.en.fmt.inc'}
{$I 'lang.en.gfx.inc'}
{$I 'lang.en.math.inc'}
{$I 'lang.en.vfs.inc'}
{$ENDIF}

{$IFDEF OMORPHIA_USELANG_GERMAN}
{$I 'lang.de.fmt.inc'}
{$I 'lang.de.gfx.inc'}
{$I 'lang.de.math.inc'}
{$I 'lang.de.vfs.inc'}
{$ENDIF}

{(*}
Const
    DbgCompiler =
        {$IFDEF DELPHI}
        'Borland Delphi ' +
            {$IFDEF DELPHI1}
            '1';
            {$ELSE}
                {$IFDEF DELPHI2}
            '2';
                {$ELSE}
                    {$IFDEF DELPHI3}
            '3';
                    {$ELSE}
                        {$IFDEF DELPHI4}
            '4';
                        {$ELSE}
                            {$IFDEF DELPHI5}
            '5';
                            {$ELSE}
                                {$IFDEF DELPHI6}
            '6';
                                {$ELSE}
                                    {$IFDEF DELPHI7}
            '7';
                                    {$ELSE}
                                        {$IFDEF DELPHI8}
            '8';
                                        {$ELSE}
                                            {$IFDEF DELPHI9}
            '2005';
                                            {$ELSE}
            '(unknown)';
                                            {$ENDIF}
                                        {$ENDIF}
                                    {$ENDIF}
                                {$ENDIF}
                            {$ENDIF}
                        {$ENDIF}
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ELSE}
        {$IFDEF BCB}
        'Borland C++Builder ' +
            {$IFDEF BCB1}
            '1';
            {$ELSE}
                {$IFDEF BCB3}
            '3';
                {$ELSE}
                    {$IFDEF BCB4}
            '4';
                    {$ELSE}
                        {$IFDEF BCB5}
            '5';
                        {$ELSE}
                            {$IFDEF BCB6}
            '6';
                            {$ELSE}
                                {$IFDEF BCB7}
            '7';
                                {$ELSE}
            '(unknown)';
                                {$ENDIF}
                            {$ENDIF}
                        {$ENDIF}
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ELSE}
        {$IFDEF FPC}
        'FreePascal ' +
            {$IFDEF FPC1}
            '0';
            {$ELSE}
                {$IFDEF FPC1}
            '1';
                {$ELSE}
                    {$IFDEF FPC2}
            '2';
                    {$ELSE}
            '(unknown)';
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ELSE}
        {$IFDEF KYLIX}
        'Borland Kylix ' +
            {$IFDEF KYLIX1}
            '1';
            {$ELSE}
                {$IFDEF KYLIX2}
            '2';
                {$ELSE}
                    {$IFDEF KYLIX3}
            '3';
                    {$ELSE}
            '(unknown)';
                    {$ENDIF}
                {$ENDIF}
            {$ENDIF}
        {$ELSE}
        'Unknown Compiler';
        {$ENDIF}
        {$ENDIF}
        {$ENDIF}
        {$ENDIF}

    DbgPlatform =
        {$IFDEF MSWINDOWS}
        'Microsoft Windows';
        {$ELSE}
            {$IFDEF LINUX}
        'Linux';
            {$ELSE}
        '(unknown)';
            {$ENDIF}
        {$ENDIF}

    DbgReleaseType =
        {$IFDEF OMORPHIA_BUILD_DEBUG}
        'Debug Release';
        {$ENDIF}

        {$IFDEF OMORPHIA_BUILD_FINAL}
        'Final Release';
        {$ENDIF}

{*)}

Implementation

End.
