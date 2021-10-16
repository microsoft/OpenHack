# Logger Functions
# https://docs.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands?view=azure-devops&tabs=bash
_debug() {
    # Only print debug lines if debugging is turned on.
    if [ ${DEBUG_FLAG} == true ]; then
        _color="\e[35m" # magenta
        echo -e "${_color}##[debug] $@\n\e[0m" 2>&1
    fi
}

_debug_json() {
    if [ ${DEBUG_FLAG} == true ]; then
        echo "${@}" | jq
    fi
}

_error() {
    _color="\e[31m" # red
    echo -e "${_color}##[error] $@\n\e[0m" 2>&1
}

_warning() {
    _color="\e[33m" # yellow
    echo -e "${_color}##[warning] $@\n\e[0m" 2>&1
}

_information() {
    _color="\e[36m" # cyan
    echo -e "${_color}##[command] $@\n\e[0m" 2>&1
}

_success() {
    _color="\e[32m" # green
    echo -e "${_color}##[command] $@\n\e[0m" 2>&1
}

# SemVer checker
check_tool_semver() {
    local _tool_name="$1"
    local _tool_ver="$2"
    local _tool_min_ver="$3"

    _semver=$(./semver2.sh "${_tool_ver}" "${_tool_min_ver}")

    if [ "${_semver}" -lt 0 ]; then
        _error "${_tool_name} version ${_tool_ver} is lower then required! Expected minimum ${_tool_min_ver}"
        exit 1
    fi
}