#!/bin/bash
# ========================================
# Global Variables
# ========================================
scriptName="$(basename -- $0)"

# Color variables.
colBlack="\033[0;30m"
colRed="\033[0;31m"
colGreen="\033[0;32m"
colBlue="\033[0;34m"
colYellow="\033[0;33m"
colMagenta="\033[0;35m"
colCyan="\033[0;36m"

bgBlack="\033[0;40m"
bgRed="\033[0;41m"
bgGreen="\033[0;42m"
bgYellow="\033[0;43m"
bgBlue="\033[0;44m"
bgMagenta="\033[0;45m"
bgCyan="\033[0;46m"

# Clear the color after that.
colClear="\033[0m"




# ========================================
# Functions
# ========================================
# Display help.
function Help() {
    echo -e "\033[4mScreen Capture with FFMPEG.\033[m"
    echo "Platform: $(uname) - ${OSTYPE}"
    echo
    echo "Options:"
    echo "  -o={value}      (*) Output file."
    echo "  --output=*"
    echo "  -h                  Print this Help."
    echo "  --help."
    echo "  -s={value}      (*) Screen ID."
    echo "  --screen=*"
    if [ "$(uname)" = "Darwin" ]; then
        echo "                      ID: 0 => May be the webcam."
        echo "                      ID: 1 => May be the screen."
    fi
    echo "  -r={value}          Resolution."
    echo "  --resolution=*"
    echo
    echo "* Required argument."
    echo
    echo "Example:"
    echo "Capture with specific resolution."
    if [ "$(uname)" = "Darwin" ]; then
        echo "${scriptName} -s 1 -o OutputFile.mp4 -r 640x480"
    else
        echo "${scriptName} -s 0.0 -o OutputFile.mp4 -r 640x480"
    fi
    echo
}

# Exit with error.
function ExitAbnormal() {
    Help
    exit 1
}


# Run FFMPEG.
function RunFFMPEG() {
    # Setup parameters.
    input=""
    if [ "$(uname)" = "Darwin" ]; then
        input="avfoundation -i ${screen}"
    else
        input="x11grab -i :${screen}"
    fi

    params="-f ${input} -r 25 -pix_fmt yuv420p -c:v libx264 -preset ultrafast"

    if [ ! "${resolution}" = "" ]; then
        params="${params} -s ${resolution}"
    fi

    params="${params} ${outputFile}"

    PrintInfo "- Run ----------------"
    PrintInfo "ffmepg ${params}"
    PrintInfo "----------------------"

    # Run.
    ffmpeg ${params}
}

# Prints.
# Colour formatting:
#   Start sequence: \033[Color1;Color2m
#   Stop sequence:  \033[0m
function PrintMsg() {
    echo -e "${1}${2}${colClear}"
}

function PrintInfo() {
    echo -e "${colCyan}[INFO]${colClear} ${1}"
}

function PrintError() {
    echo -e "${colRed}[ERROR]${colClear} ${1}"
}

function PrintWarning() {
    echo -e "${colRed}[WARNING]${colClear} ${1}"
}

function PrintSuccess() {
    echo -e "${colGreen}${1}${colClear}"
}




# ========================================
# Main
# ========================================
echo "=================="
echo "= Screen Capture ="
echo "=================="


# Working variables.
outputFile=""
resolution=""
screen=""


# Parsing arguments.
if [ "$1" = "" ] || [ "$1" = "?" ]; then
    Help
    exit
fi

for i in "$@"
do
    case ${i} in
        # Display help.
        -h|--help)
            Help
            exit
        ;;
        # Output file.
        -o=*|--output=*)
            outputFile="${i#*=}"
            shift
        ;;
        # Resolution.
        -r=*|--resolution=*)
            resolution="${i#*=}"
            shift
        ;;
        # Screen ID.
        -s=*|--screen=*)
            screen="${i#*=}"
            shift
        ;;
        # Unknown option.
        *)
            PrintError "Invalid option: ${i}\n\n" >&2; ExitAbnormal
        ;;
    esac
done

#while getopts ":ho:r:s:" flag
#do
#    case "${flag}" in
#        h)  # Display help.
#            Help
#            exit;;
#        o)  # Output [file].
#            outputFile=${OPTARG};;
#        r)  # Resolution.
#            resolution=${OPTARG};;
#        s)  # Screen.
#            screen=${OPTARG};;
#        :)  PrintError "Missing argument: -${OPTARG}\n\n" >&2; ExitAbnormal;;
#        \?) PrintError "Unknown option: -${OPTARG}\n\n" >&2; ExitAbnormal;;
#    esac
#done

# Require arguments.
error="0"
if [ "$outputFile" = "" ]; then
    PrintError "(-o) Missing output file."
    error="1"
fi

if [ "$screen" = "" ]; then
    PrintError "(-s) Missing screen ID."
    error="1"
fi

# Exit if error ocurred.
if [ "${error}" = "1" ]; then
    echo -e "\n"
    Help
    exit
fi

# Run.
PrintInfo "-------------------------------------"
PrintInfo "Press CTRL + C to stop the recording."
PrintInfo "-------------------------------------"
RunFFMPEG
