declare -r GITHUB_API_ENDPOINT="https://api.github.com"

# Call GitHub API helper
_gh_call_api() {
    local _api_request_type="$1"
    local _api_uri="$2"
    local _api_body="$3"
    local _api_preview="$4"

    # _debug "_api_request_type: ${_api_request_type}"
    # _debug "_api_uri: ${_api_uri}"
    # _debug "_api_body: ${_api_body}"
    # _debug_json "${_api_body}"
    # _debug "_api_preview: ${_api_preview}"

    if [ -n "${_api_preview}" ]; then
        _accept_header="application/vnd.github.${_api_preview}+json"
    else
        _accept_header="application/vnd.github.v3+json"
    fi

    if [ "${_api_request_type}" == "GET" ]; then
        _response=$(curl --silent --compressed --location --request "GET" \
            --header "Accept: ${_accept_header}" \
            --header 'Content-Type: application/json; charset=utf-8' \
            --header "Authorization: token ${GITHUB_TOKEN}" \
            "${_api_uri}")
    else
        _response=$(curl --silent --compressed --location --request "${_api_request_type}" \
            --header "Accept: ${_accept_header}" \
            --header 'Content-Type: application/json; charset=utf-8' \
            --header "Authorization: token ${GITHUB_TOKEN}" \
            "${_api_uri}" \
            --data-raw "${_api_body}")
    fi

    echo "${_response}"
}
