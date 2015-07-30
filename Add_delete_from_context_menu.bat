@echo off

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


choice /c:ad /n /m "Do you want to [a]dd or [d]elete the context menu entry [a,d]?"
echo.
if %errorlevel%==2 goto:delete

:add
REM For files.
reg add "HKCR\*\shell\Convert FLAC to MP3" /f
reg add "HKCR\*\shell\Convert FLAC to MP3" /ve /d "Convert FLAC to MP&3" /f
reg add "HKEY_CLASSES_ROOT\*\shell\Convert FLAC to MP3\command" /f
reg add "HKEY_CLASSES_ROOT\*\shell\Convert FLAC to MP3\command" /ve /d "%~dp0flac-to-mp3.bat \"%%1\"" /f

REM For folders.
reg add "HKCR\Directory\shell\Convert FLAC to MP3" /f
reg add "HKCR\Directory\shell\Convert FLAC to MP3" /ve /d "Convert FLAC to MP&3" /f
reg add "HKEY_CLASSES_ROOT\Directory\shell\Convert FLAC to MP3\command" /f
reg add "HKEY_CLASSES_ROOT\Directory\shell\Convert FLAC to MP3\command" /ve /d "%~dp0flac-to-mp3.bat \"%%1\"" /f

if %errorlevel% neq 0 goto:error

goto:end

:delete
reg delete "HKCR\*\shell\Convert FLAC to MP3" /f
reg delete "HKCR\Directory\shell\Convert FLAC to MP3" /f

if %errorlevel% neq 0 goto:error

goto:end

:error
echo.
echo There was an error.
echo PS. This script must be "Run as administrator".
echo.

pause

goto:end

:end
