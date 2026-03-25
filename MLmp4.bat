@echo off
setlocal enabledelayedexpansion
REM ==============================================================================
REM https://github.com/cakebuildcom/MKmp4/new/main
REM cakebuildcom
REM WAV to MP4 Converter
REM Converts WAV files to MP4 using a static
REM image as video, preserves original file
REM dates, and moves processed files.
REM ==============================================================================

REM ------------------------------------------------------------------------------
REM Folder and file paths
REM ------------------------------------------------------------------------------

set SOURCE_DIR=.\source
set OUTPUT_DIR=.\output
set PROCESSED_DIR=.\processed

REM ------------------------------------------------------------------------------
REM Overlay text on the video
REM ------------------------------------------------------------------------------

set TITLE_TEXT=WAV TO MP4

REM ------------------------------------------------------------------------------
REM Create output and processed folders if they don't exist
REM ------------------------------------------------------------------------------

if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"
if not exist "%PROCESSED_DIR%" mkdir "%PROCESSED_DIR%"

REM ------------------------------------------------------------------------------
REM Loop through every WAV file in the source folder
REM ------------------------------------------------------------------------------


for %%f in ("%SOURCE_DIR%\*.wav" "%SOURCE_DIR%\*.mp3") do (
    echo Processing: %%~nf

    REM -----------------------------------------------------------------------------
    REM Set video/image title based on file type
    REM -----------------------------------------------------------------------------

    if /i "%%~xf"==".wav" set TITLE_TEXT=WAV TO MP4
    if /i "%%~xf"==".mp3" set TITLE_TEXT=MP3 TO MP4

    REM -----------------------------------------------------------------------------
    REM Get original file size in MB
    REM -----------------------------------------------------------------------------

    set /a FSIZE=%%~zf / 1024 / 1024

    REM -----------------------------------------------------------------------------
    REM Get modified date of the original file and current date
    REM -----------------------------------------------------------------------------

    set FDATE=%%~tf
    set FDATE=!FDATE::=\:!
    set FDATE=!FDATE:/=\/!
    set ENCODE_DATE=%date%
    set ENCODE_DATE=!ENCODE_DATE:/=\/!

    REM ------------------------------------------------------------------------------
    REM -vf drawtext         = overlay title, filename, and file size
    REM -c:v libx264         = encode video with H.264 codec
    REM -c:a libmp3lame      = encode audio as MP3
    REM -b:a 320k            = audio bitrate 320kbps
    REM -shortest            = stop when the audio ends
    REM -pix_fmt yuv420p     = ensure compatibility with most players
    REM -tune stillimage     = flag tells x264 a static white screen with text
    REM -y                   = overwrite output file without asking
    REM ------------------------------------------------------------------------------

ffmpeg -f lavfi -i color=c=white:s=1920x1080:r=25 -i "%%f" -vf "drawtext=text='!TITLE_TEXT!':fontfile='C\:/Windows/Fonts/arialbd.ttf':fontsize=200:fontcolor=black:x=(w-text_w)/2:y=(h-th)/2-80,drawtext=text='%%~nxf':fontfile='C\:/Windows/Fonts/arialbd.ttf':fontsize=40:fontcolor=black:x=(w-text_w)/2:y=h-th-250,drawtext=text='!FSIZE! MB':fontfile='C\:/Windows/Fonts/arial.ttf':fontsize=30:fontcolor=gray:x=(w-text_w)/2:y=h-th-200,drawtext=text='File Date\: !FDATE!':fontfile='C\:/Windows/Fonts/arial.ttf':fontsize=30:fontcolor=gray:x=(w-text_w)/2:y=h-th-150,drawtext=text='Encode Date\: !ENCODE_DATE!':fontfile='C\:/Windows/Fonts/arial.ttf':fontsize=30:fontcolor=gray:x=(w-text_w)/2:y=h-th-100" -c:v libx264 -tune stillimage -c:a libmp3lame -b:a 320k -shortest -pix_fmt yuv420p -y "%OUTPUT_DIR%\%%~nf.mp4"

REM Filename — 250px from bottom
REM File size — 200px from bottom
REM File Date: 06/15/2024 02:45 PM — 150px from bottom
REM Encode Date: 03/24/2026 — 100px from bottom



    REM ------------------------------------------------------------------------------
    REM Check if ffmpeg succeeded (errorlevel 0 = success)
    REM ------------------------------------------------------------------------------

    if !errorlevel! equ 0 (
        REM ------------------------------------------------------------------------------
        REM Copy original WAV dates to the new MP4 file
        REM ------------------------------------------------------------------------------

        powershell -command "$src = Get-Item '%%f'; $dst = Get-Item '%OUTPUT_DIR%\%%~nf.mp4'; $dst.CreationTime = $src.CreationTime; $dst.LastWriteTime = $src.LastWriteTime; $dst.LastAccessTime = $src.LastAccessTime"
        echo Dates copied for %%~nf

        REM ------------------------------------------------------------------------------
        REM Move the original WAV to the processed folder
        REM ------------------------------------------------------------------------------


        move "%%f" "%PROCESSED_DIR%\"




        echo Moved %%~nf.wav to processed folder
    ) else (


        REM ------------------------------------------------------------------------------
        REM If conversion failed, leave the WAV in source
        REM ------------------------------------------------------------------------------
        echo ERROR: Failed to convert %%~nf, file not moved
    )
)
echo Done! All files saved to %OUTPUT_DIR%
pause
