@echo off

title FLAC to MP3

REM ------ Userdefined variables ------
REM -----------------------------------
REM Paths to executables.
set lameexe="C:\PortableApps\lame\lame.exe"
set metaflacexe="C:\PortableApps\flac\bin\metaflac.exe"
set imagemagickpath="C:\PortableApps\ImageMagick\"

REM Paths to suggest when choosing destination.
REM "suggestrelativeoutputdirectory1" will be assigned later on.
REM #0 should not be used, as the later use of CHOICE starts counting at 1.
set suggestrelativeoutputdirectory1=
set suggestrelativeoutputdirectory2="%UserProfile%\Music"
set suggestrelativeoutputdirectory3="D:\Audio\Music\Album"


REM ------------ Copyright ------------
REM -----------------------------------
REM Copyright (C) 2011-toyear  aude
REM
REM This program is free software: you can redistribute it and/or modify
REM it under the terms of the GNU General Public License as published by
REM the Free Software Foundation, either version 3 of the License, or
REM (at your option) any later version.
REM
REM This program is distributed in the hope that it will be useful,
REM but WITHOUT ANY WARRANTY; without even the implied warranty of
REM MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
REM GNU General Public License for more details.
REM
REM You should have received a copy of the GNU General Public License
REM along with this program.  If not, see <http://www.gnu.org/licenses/>.


REM --------- Other variables ---------
REM -----------------------------------

REM Disposable variables.
set disposablevariable=
set disposablevariable1=

REM Hold relative output directory.
set relativeoutputdirectory=

REM Hold temporary lower directory of currently processing file or directory.
set tmplowerdirectory=

REM Hold temporary output directory.
set tmpoutputdirectory=

REM Hold a list of choices for the CHOICE command.
set tmpchoicelist=

REM Paths of temporary cover art file, format and extension.
set tmpcoverart=
set tmpcoverartformat=
set tmpcoverartextension=

REM String of tags to include in the MP3.
set tmptagstring=

REM Store input. Trim quotation enclosure.
set input=%*
REM Unescape spaces escaped as question marks ("?").
set input=%input:?= %

REM Hold incremention of "rootx" variables.
set /a i=0


REM ------------ Execution ------------
REM -----------------------------------

REM Display information.
echo ----------
echo -- INFO --
echo ----------
echo This batch will convert FLAC files to MP3 files
echo encoded in LAME 320bps CBR using lame 3.99.5,
echo and migrates the metadata to Id3v1 and Id3v2.3
echo tags in the MP3 using metaflac and lame.
echo.
echo This batch is a creation by Asbjoern Apeland.
echo ----------
echo -- INFO --
echo ----------
echo.
echo.

REM Initiate.
call :initiate

REM Process variables.
REM Assure trailing space for each value of the input paths in the "input" variable.
REM Temporarily remove quotes.
for %%a in (%input%) do (
	REM Process in subroutine to avoid using delayed variable expansion.
	call :setrootvariables %%a
)

REM Process paths.
for /f "tokens=1-2 delims==" %%a in ('set root') do (
	REM If the path is to a file, it does not need processing.
	
	REM Logics:
		REM Is dir if has: attributes = d-------- or (nothing)
		REM Is file if: has attributes = anything but d-------- or (nothing).
		REM Dir:
			REM if %%~ab equ d-------- <or> if not defined %%~ab
		REM File:
			REM if defined %%~ab <and> if %%~ab neq d--------
	
	
	REM If the path is not to a file with extension ...
	if "%%~xb" equ "" (
		REM ... it has attributes ...
		REM (Can only be if it has attributes, but are not of those which are to a directory ["d--------"].)
		if "%%~ab" neq "" (
			REM ... and it is to a file without extension ...
			if %%~ab neq d-------- (
				REM ... it is to a pre-existent file.
				REM Check if it exists.
				if not exist %%b (
					REM The file does not exist.
					echo -------- WARNING! --------
					echo %%b has been classified a path to a file, but it does not exist.
					echo -------- WARNING! --------
					echo.
					echo Thus, it does not make sense to process it, and the path will be skipped.
					echo.
					REM Erase the value of the currently processing variable, and thus it will be skipped in later processing.
					set %%a=
				)
			) else (
				REM ... and it is not to a file without extension ...
				REM ... it is to a pre-existent directory.
				REM Assure a trailing backslash.
				REM This is done in a subroutine, to circumvent the need of delayed environment variable expansion.
				call :assurebackslash %%a %%b
			)
		) else (
			REM (If it is not to a pre-existent directory or file without extension.)
			REM ... it is assumed to be to a directory.
			REM Assure a trailing backslash.
			REM This is done in a subroutine, to circumvent the need of delayed environment variable expansion.
			call :assurebackslash %%a %%b
		)
	) else (
		REM If the path has an extension, it is to a file.
		REM Thus, check if it exists.
		if not exist %%b (
			REM The file does not exist.
			echo -------- WARNING! --------
			echo %%b has been classified a path to a file, but it does not exist.
			echo -------- WARNING! --------
			echo.
			echo Thus, it does not make sense to process it, and the path will be skipped.
			echo.
			REM Erase the value of the currently processing variable, and thus it will be skipped in later processing.
			set %%a=
		)
	)
)

REM Suggest parent directory of first listed root.
for /f "tokens=1-2 delims==" %%a in ('set root0') do (
	REM If it is directory (if it does not have a file name).
	if "%%~nb" equ "" (
		REM Pass the directory, as parent directory will be extracted in the subroutine.
		call :setrelativeoutputpathsuggestion1 %%b
	) else (
		REM Else, pass path (parent directory), as parent directory of it will be extracted in the subroutine.
		call :setrelativeoutputpathsuggestion1 "%%~dpb"
	)
)

REM Assure backslashes.
for /f "tokens=1-2 delims==" %%a in ('set suggestrelativeoutputdirectory') do (
	call :assurebackslash %%a %%b
)

REM Set relative output path before encoding.
echo Where do you want to save the encoded file[s]?
echo.

REM Suggest preset paths (set above and in userdefined variables).
REM Set iterator. Starting at 1 as CHOICE does.
set i=1
for /f "tokens=1-2 delims==" %%a in ('set suggestrelativeoutputdirectory') do (
	call :presentrelativeoutputoptions %%a %%b
)

REM Present choice to specify custom path.
echo %i%: *Specify custom path*
REM Also, add this option to the choice list.
set tmpchoicelist=%tmpchoicelist%%i%
echo.

choice /c %tmpchoicelist%
echo.
echo %relativeoutputdirectory%
REM Workaround to set relative output directory to the chosen variable (to be able to include the number in the variable name).
for /f "delims=" %%a in ('echo %%suggestrelativeoutputdirectory%errorlevel%%%') do (
	set relativeoutputdirectory=%%a
)
echo %relativeoutputdirectory%

:setcustomrelativeoutputdirectory
REM If the "relativeoutputdirectory" variable is not valid (if it does not contain a ":", like it must do to be a valid path), prompt user for path.
if "%relativeoutputdirectory::=%" equ "%relativeoutputdirectory%" (
	echo Please input desired relative output path ^(or q to quit^):
	echo Eg. "E:\Music", not "E:\Music\".
	set /p relativeoutputdirectory=
	echo.
)
REM If quit is desired.
if %relativeoutputdirectory% equ q (
	REM Clean and exit.
	call :clean
	goto endmessage
)
REM Check if valid.
if not exist %relativeoutputdirectory% (
	echo Error: Your input %relativeoutputdirectory% is invalid.
	echo.
	goto setcustomrelativeoutputdirectory
)

REM Assure backslash of the set relative output directory.
call :assurebackslash relativeoutputdirectory %relativeoutputdirectory%

REM Inform.
echo The encoded file[s] will be saved relative to %relativeoutputdirectory%.
echo.

call :echoheadline Encode
REM Loop through root paths, and encode appropriate entries.
for /f "tokens=1-2 delims==" %%a in ('set root') do (
	REM If it is directory (if it does not have a file name).
	if "%%~nb" equ "" (
		call :encodedirectory %%b
	) else (
		REM If it is a file.
		REM Check if it exists.
		if exist %%b (
			REM Check if it is a FLAC file.
			if %%~xb equ .flac (
				call :encodefile %%b
			) else (
				call :echoheadline WARNING!
				echo %%b has not been classified as a FLAC file, due to it's "%%~xb" extension.
				echo Thus, it will not be encoded.
				call :echoheadline WARNING!
			)
		) else (
			call :echoheadline WARNING!
			echo %%b does not exist.
			echo Thus, it can not be encoded, and will be skipped.
			call :echoheadline WARNING!
		)
	)
)
call :echoheadline Encode

REM Open the directory after encoding to it.
echo Opening relative output directory ^(%relativeoutputdirectory%^) ...
explorer %relativeoutputdirectory%

REM Clean up.
call :clean
REM Exit.
goto endmessage


REM ----------- Subroutines -----------
REM -----------------------------------

:setvariable
REM Workaround to set variables, as delayed environment variable expansion is undesired to use.
set %1=%2

goto :eof

:echoheadline
echo -------- %~1 --------
echo.

goto :eof

:assurebackslash
REM Workaround to assure a trailing backslash from a passed string.
set disposablevariable=%~2
REM If the passed string does not have a trailing backslash.
if %disposablevariable:~-1% neq \ (
	REM Append one, and quote the string.
	set %1="%disposablevariable%\"
) else (
	REM If it does have already, just quote the string.
	set %1="%disposablevariable%"
)

goto :eof

:getlowerdirectory
set disposablevariable="%~p1"
REM Substitute backslashes with question marks, for easier processing.
set disposablevariable=%disposablevariable:\=?%

for /f "tokens=1-20 delims=?" %%c in (%disposablevariable%) do (
	REM Send all directories to subroutine.
	call :setlowerdirectory %%c %%d %%e %%f %%g %%h %%i %%j %%k %%l %%m %%n %%o %%p %%q %%r %%s %%t %%u %%v
)

goto :eof

:setlowerdirectory
REM If current parameter is empty, previous was the last directory, alias parent directory.
if "%1"=="" (
	set tmplowerdirectory=%disposablevariable1%
	goto :eof
)

set disposablevariable1=%1
REM Iterate parameter.
shift

REM Loop.
goto setlowerdirectory

:initiate

goto :eof

:setrootvariables
REM Workaround.
REM Set currently processing path to a "root" variable.
set root%i%=%1

REM Increment.
set /a i+=1

goto :eof

:setrelativeoutputpathsuggestion1
REM Workaround.
REM Only if it is already empty, it will be saved.
if "%suggestrelativeoutputdirectory1%" equ "" (
	REM Suggest full path of parent directory.
	for /f "delims=" %%a in ("%~1..") do (
		set suggestrelativeoutputdirectory1="%%~fa"
	)
)

goto :eof

:presentrelativeoutputoptions
REM Print alternative.
echo %i%: %2

REM Build choice list for the CHOICE command.
set tmpchoicelist=%tmpchoicelist%%i%

set /a i+=1

goto :eof

:setsinglefileoutputdirectory
REM Expected parameter: path to file to encode.

REM Generate output directory from relative.
REM call :getlowerdirectory %1
for /d %%a in ("%~1\..") do (
	set tmplowerdirectory=%%~nxa
)

REM Set current output directory to "chosen top output directory + name of the currently processing directory + ' (MP3)"
set tmpoutputdirectory="%relativeoutputdirectory:"=%%tmplowerdirectory% (MP3)"
call :assurebackslash tmpoutputdirectory %tmpoutputdirectory%

REM Create if not pre-existent.
if not exist %tmpoutputdirectory% (
	mkdir %tmpoutputdirectory%
)

REM Inform.
echo Will encode FLAC file %1 as MP3 file in %tmpoutputdirectory%.
echo.

goto :eof

:encodedirectory
REM Expected parameter: path to directory to encode.

REM Generate output directory from relative.
REM call :getlowerdirectory %1
for /d %%a in ("%~1\*\..") do (
	set tmplowerdirectory=%%~nxa
)
REM If the string is empty, it is the result of a bug which happens if the passed directory is empty.
REM Take advantage of this, as an empty directory have nothing to be encoded anyways.
if "%tmplowerdirectory%" equ "" (
	echo %1 is empty.
	echo Thus, no files are to be encoded, and the path will be skipped.
	echo.
	
	goto :eof
)

REM Set current output directory to "chosen top output directory + name of the currently processing directory + ' (MP3)"
set tmpoutputdirectory="%relativeoutputdirectory:"=%%tmplowerdirectory% (MP3)"
call :assurebackslash tmpoutputdirectory %tmpoutputdirectory%

REM Create if not pre-existent.
if not exist %tmpoutputdirectory% (
	mkdir %tmpoutputdirectory%
)

REM Inform.
echo Will encode FLAC files from %1 as MP3 files in %tmpoutputdirectory%.
echo.

REM Loop through .flac file[s] in passed directory, and encode each file individually.
for /f "tokens=*" %%a in ('dir /b "%~1*.flac"') do (
	call :encodefile "%~1%%a"
)

goto :eof

:encodefile
REM Expected parameter: path to file to encode.
REM Expected set variables: "tmpoutputdirectory".

REM If the "tmpoutputdirectory" variable is not previously set, set it for the currently processing file.
if not defined tmpoutputdirectory (
	call :setsinglefileoutputdirectory %1
)

REM Set initial path to temporary cover art file.
set tmpcoverart="%tmp%\coverart.tmp"
REM Store cover art temporarily in temporary directory.
%metaflacexe% --export-picture-to=%tmpcoverart% %1
REM Determine file type.
for /f "delims=" %%n in ('"%imagemagickpath:"=%identify.exe" -format %%m %tmpcoverart:"=%') do (
	set tmpcoverartformat=%%n
)
REM "Translate" formats to extensions.
if %tmpcoverartformat% equ JPEG (
	set tmpcoverartextension=jpg
)
if %tmpcoverartformat% equ JPG (
	set tmpcoverartextension=jpg
)
if %tmpcoverartformat% equ PNG (
	set tmpcoverartextension=png
)
if %tmpcoverartformat% equ GIF (
	set tmpcoverartextension=gif
)
REM Rename file with correct extension.
for %%a in (%tmpcoverart%) do (
	ren %tmpcoverart% %%~na.%tmpcoverartextension%
	REM Update path.
	set tmpcoverart="%%~dpna.%tmpcoverartextension%"
)
REM Resize to 256x256.
"%imagemagickpath:"=%convert.exe" %tmpcoverart% -resize 256x256!^> %tmpcoverart%

REM Extract FLAC tags.
for %%a in (TITLE ARTIST ALBUM DATE COMMENT TRACKNUMBER GENRE) do (
	for /f "tokens=1-2 delims==" %%c in ('%metaflacexe% --show-tag=%%a %~s1') do (
		REM Store the temporary tags in variables.
		set tmptag%%a=%%d
	)
)
REM Store temporary tags in a single string, defined by the LAME tool (execute "lame.exe --help id3" for help).
REM First, make sure it is empty before use.
REM If tag variable is not empty, use the set information for each tag.
set tmptagstring=
if "%tmptagTITLE%" neq "" (
	set tmptagstring=%tmptagstring%--tt "%tmptagTITLE%" 
)
if "%tmptagARTIST%" neq "" (
	set tmptagstring=%tmptagstring%--ta "%tmptagARTIST%" 
)
if "%tmptagALBUM%" neq "" (
	set tmptagstring=%tmptagstring%--tl "%tmptagALBUM%" 
)
if "%tmptagDATE%" neq "" (
	set tmptagstring=%tmptagstring%--ty "%tmptagDATE%" 
)
if "%tmptagCOMMENT%" neq "" (
	set tmptagstring=%tmptagstring%--tc "%tmptagCOMMENT%" 
)
if "%tmptagTRACKNUMBER%" neq "" (
	set tmptagstring=%tmptagstring%--tn "%tmptagTRACKNUMBER%" 
)
if "%tmptagGENRE%" neq "" (
	set tmptagstring=%tmptagstring%--tg "%tmptagGENRE%" 
)
REM Add path to cover art.
set tmptagstring=%tmptagstring%--ti %tmpcoverart%


REM Encode!
REM CBR, Higher quality, 320kbps, id3v1 and id3v2 tags
%lameexe% --cbr -h -b 320 --add-id3v2 %tmptagstring% %1 "%tmpoutputdirectory:"=%%~n1.mp3"

REM Create space.
echo.
echo.

REM Delete temporary cover art.
del %tmpcoverart%

REM Reset necessary variables.
set tmpoutputdirectory=

goto :eof

:clean
REM Inform.
call :echoheadline Clean
REM Make sure no cover art files are left behind in %tmp%.
for /f "tokens=*" %%a in ('dir /b "%tmp:"=%\*coverart*"') do (
	del "%tmp:"=%\%%a"
)

echo.

call :echoheadline Clean

goto :eof

:endmessage
call :echoheadline "End of batch"
