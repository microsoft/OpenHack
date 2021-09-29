#!/bin/sh

# POSIX SH portable semver 2.0 comparition tool.

# This bash script compares pre-releases alphabetically as well (number < lowerCaseLetter < upperCaseLetter)
#
# returns 1 when A greater than B
# returns 0 when A equals B
# returns -1 when A lower than B
#
# Usage
# chmod +x semver.sh
# ./semver.sh 1.0.0-rc.0.a+metadata v1.0.0-rc.0+metadata
# --> 1
#

# This software was built with the help of the following sources:
# https://stackoverflow.com/a/58067270
# https://www.unix.com/man-page/posix/1posix/cut/
# https://stackoverflow.com/questions/51052475/how-to-iterate-over-the-characters-of-a-string-in-a-posix-shell-script

set -eu

debug() {
  if [ "$debug" = "debug" ]; then printf "DEBUG: %s$1 \n"; fi
}

# params char
# returns Integer
ord() {
  printf '%d' "'$1"
}


isNumber() {
  string=$1
  char=""
  while true; do
    substract="${string#?}"    # All but the first character of the string
    char="${string%"$substract"}"    # Remove $rest, and you're left with the first character
    string="$substract"
    # no more chars to compare then success
    if [ -z "$char" ]; then
      printf "true"
      return 1
    fi
    # break if some of the chars is not a number
    if [ "$(ord "$char")" -lt 48 ] || [ "$(ord "$char")" -gt 57 ]; then
      printf "false"
      return 0
    fi
  done
}

# params string {String}, Index {Number}
# returns char
getChar() {
  string=$1
  index=$2
  cursor=-1
  char=""
  while [ "$cursor" != "$index" ]; do
    substract="${string#?}"    # All but the first character of the string
    char="${string%"$substract"}"    # Remove $rest, and you're left with the first character
    string="$substract"
    cursor=$((cursor + 1))
  done
  printf "%s$char"
}

outcome() {
  result=$1
  printf "%s$result\n"
}


compareNumber() {
  if [ -z "$1" ] && [ -z "$2" ]; then
    printf "%s" "0"
    return
  fi

  [ $(($2 - $1)) -gt 0 ] && printf "%s" "-1"
  [ $(($2 - $1)) -lt 0 ] && printf "1"
  [ $(($2 - $1)) = 0 ] && printf "0"
}

compareString() {
  result=false
  index=0
  while true
  do
    a=$(getChar "$1" $index)
    b=$(getChar "$2" $index)

    if [ -z "$a" ] && [ -z "$b" ]
    then
      printf "0"
      return
    fi

    ord_a=$(ord "$a")
    ord_b=$(ord "$b")

    if [ "$(compareNumber "$ord_a" "$ord_b")" != "0" ]; then
      printf "%s" "$(compareNumber "$ord_a" "$ord_b")"
      return
    fi

    index=$((index + 1))
  done
}

includesString() {
  string="$1"
  substring="$2"
  if [ "${string#*$substring}" != "$string" ]
  then
    printf "1"
    return 1    # $substring is in $string
  fi
  printf "0"
  return 0    # $substring is not in $string
}

removeLeadingV() {
  printf "%s${1#v}"
}

# https://github.com/Ariel-Rodriguez/sh-semversion-2/pull/2
# Spec #2 https://semver.org/#spec-item-2
# MUST NOT contain leading zeroes
normalizeZero() {
  next=$(printf %s "${1#0}")
  if [ -z "$next" ]; then
    printf %s "$1"
  fi
  printf %s "$next"
}

semver_compare() {
  firstParam=$1 #1.2.4-alpha.beta+METADATA
  secondParam=$2 #1.2.4-alpha.beta.2+METADATA
  debug=${3:-1}
  verbose=${4:-1}

  [ "$verbose" = "verbose" ] && set -x

  version_a=$(printf %s "$firstParam" | cut -d'+' -f 1)
  version_a=$(removeLeadingV "$version_a")
  version_b=$(printf %s "$secondParam" | cut -d'+' -f 1)
  version_b=$(removeLeadingV "$version_b")

  a_major=$(printf %s "$version_a" | cut -d'.' -f 1)
  a_minor=$(printf %s "$version_a" | cut -d'.' -f 2)
  a_patch=$(printf %s "$version_a" | cut -d'.' -f 3 | cut -d'-' -f 1)
  a_pre=""
  if [ "$(includesString "$version_a" -)" = 1 ]; then
    a_pre=$(printf %s"${version_a#$a_major.$a_minor.$a_patch-}")
  fi

  b_major=$(printf %s "$version_b" | cut -d'.' -f 1)
  b_minor=$(printf %s "$version_b" | cut -d'.' -f 2)
  b_patch=$(printf %s "$version_b" | cut -d'.' -f 3 | cut -d'-' -f 1)
  b_pre=""
  if [ "$(includesString "$version_b" -)" = 1 ]; then
    b_pre=$(printf %s"${version_b#$b_major.$b_minor.$b_patch-}")
  fi

  a_major=$(normalizeZero "$a_major")
  a_minor=$(normalizeZero "$a_minor")
  a_patch=$(normalizeZero "$a_patch")
  b_major=$(normalizeZero "$b_major")
  b_minor=$(normalizeZero "$b_minor")
  b_patch=$(normalizeZero "$b_patch")

  unit_types="MAJOR MINOR PATCH"
  a_normalized="$a_major $a_minor $a_patch"
  b_normalized="$b_major $b_minor $b_patch"

  debug "Detected: $a_major $a_minor $a_patch identifiers: $a_pre"
  debug "Detected: $b_major $b_minor $b_patch identifiers: $b_pre"

  #####
  #
  # Find difference between Major Minor or Patch
  #

  cursor=1
  while [ "$cursor" -lt 4 ]
  do
    a=$(printf %s "$a_normalized" | cut -d' ' -f $cursor)
    b=$(printf %s "$b_normalized" | cut -d' ' -f $cursor)
    if [ "$a" != "$b" ]
    then
      debug "$(printf %s "$unit_types" | cut -d' ' -f $cursor) is different"
      outcome "$(compareNumber "$a" "$b")"
      return
    fi;
    debug "$(printf "%s" "$unit_types" | cut -d' ' -f $cursor) are equal"
    cursor=$((cursor + 1))
  done

  #####
  #
  # Find difference between pre release identifiers
  #

  if [ -z "$a_pre" ] && [ -z "$b_pre" ]; then
    debug "Because both are equals"
    outcome "0"
    return
  fi

  # Spec 11.3 a pre-release version has lower precedence than a normal version:
  # Example: 1.0.0-alpha < 1.0.0.

  if [ -z "$a_pre" ]; then
    debug "Because a pre-release version has lower precedence than a normal version"
    outcome "1"
    return
  fi

  if [ -z "$b_pre" ]; then
    debug "Because a pre-release version has lower precedence than a normal version"
    outcome "-1"
    return
  fi


  isSingleIdentifier() {
    substract="${2#?}"
    if [ "${1%"$2"}" = "" ]; then
      printf "true"
      return 1;
    fi
    return 0
  }

  cursor=1
  while [ $cursor -lt 4 ]
  do
    a=$(printf %s "$a_pre" | cut -d'.' -f $cursor)
    b=$(printf %s "$b_pre" | cut -d'.' -f $cursor)

    debug "Comparing identifier $a with $b"

    # Exit when there is nothing else to compare.
    # Most likely because they are equals
    if [ -z "$a" ] && [ -z "$b" ]
    then
      debug "are equals"
      outcome "0"
      return
    fi;

    # Spec #11 https://semver.org/#spec-item-11
    # Precedence for two pre-release versions with the same major, minor, and patch version
    # MUST be determined by comparing each dot separated identifier from left to right until a difference is found

    # Spec 11.4.4: A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.
    if [ -n "$a" ] && [ -z "$b" ]; then
      # When A is larger than B
      debug "Because A has more pre-identifiers"
      outcome "1"
      return
    fi

    # When A is shorter than B
    if [ -z "$a" ] && [ -n "$b" ]; then
      debug "Because B has more pre-identifiers"
      outcome "-1"
      return
    fi

    # Spec #11.4.1
    # Identifiers consisting of only digits are compared numerically.
    if [ "$(isNumber "$a")" = "true" ] || [ "$(isNumber "$b")" = "true" ]; then

      # if both identifiers are numbers, then compare and proceed
      if [ "$(isNumber "$a")" = "true" ] && [ "$(isNumber "$b")" = "true" ]; then
        if [ "$(compareNumber "$a" "$b")" != "0" ]; then
          debug "Number is not equal $(compareNumber "$a" "$b")"
          outcome "$(compareNumber "$a" "$b")"
          return
        fi
      fi

      # Spec 11.4.3
      if [ "$(isNumber "$a")" = "false" ]; then
        debug "Because Numeric identifiers always have lower precedence than non-numeric identifiers."
        outcome "1"
        return
      fi

      if [ "$(isNumber "$b")" = "false" ]; then
        debug "Because Numeric identifiers always have lower precedence than non-numeric identifiers."
        outcome "-1"
        return
      fi
    else
      # Spec 11.4.2
      # Identifiers with letters or hyphens are compared lexically in ASCII sort order.
      if [ "$(compareString "$a" "$b")" != "0" ]; then
        debug "cardinal is not equal $(compareString a b)"
        outcome "$(compareString "$a" "$b")"
        return
      fi
    fi

    # Edge case when there is single identifier exaple: x.y.z-beta
    if [ "$cursor" = 1 ]; then

      # When both versions are single return equals
      if [ -n "$(isSingleIdentifier "$b_pre" "$b")" ] && [ -n "$(isSingleIdentifier "$a_pre" "$a")" ]; then
        debug "Because both have single identifier"
        outcome "0"
        return
      fi

      # Return greater when has more identifiers
      # Spec 11.4.4: A larger set of pre-release fields has a higher precedence than a smaller set, if all of the preceding identifiers are equal.

      # When A is larger than B
      if [ -n "$(isSingleIdentifier "$b_pre" "$b")" ] && [ -z "$(isSingleIdentifier "$a_pre" "$a")" ]; then
        debug "Because of single identifier, A has more pre-identifiers"
        outcome "1"
        return
      fi

      # When A is shorter than B
      if [ -z "$(isSingleIdentifier "$b_pre" "$b")" ] && [ -n "$(isSingleIdentifier "$a_pre" "$a")" ]; then
        debug "Because of single identifier, B has more pre-identifiers"
        outcome "-1"
        return
      fi
    fi

    # Proceed to the next identifier because previous comparition was equal.
    cursor=$((cursor + 1))
  done
}

printf "%s$(semver_compare "$@")\n"