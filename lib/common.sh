#!/usr/bin/env bash
# RestockR Common Library
# Shared utilities for all RestockR scripts

# Prevent multiple sourcing
if [[ -n "${RESTOCKR_COMMON_LOADED:-}" ]]; then
  return 0
fi
RESTOCKR_COMMON_LOADED=true

# Source visual enhancements library
COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "${COMMON_DIR}/visual.sh" ]]; then
  source "${COMMON_DIR}/visual.sh"
fi

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

APP_NAME="RestockR"
MIN_FLUTTER_VERSION="3.29.2"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEVKIT_MARKER="${PROJECT_ROOT}/.restockr_devkit"

# Color and formatting codes (only set if not already defined by visual.sh)
if [[ -t 1 ]]; then
  BOLD="${BOLD:-$(tput bold)}"
  DIM="${DIM:-$(tput dim)}"
  RESET="${RESET:-$(tput sgr0)}"
  # Use themed colors from visual.sh if available, otherwise fallback to basic colors
  GREEN="${GREEN:-$(tput setaf 2)}"
  RED="${RED:-$(tput setaf 1)}"
  BLUE="${BLUE:-$(tput setaf 4)}"
  YELLOW="${YELLOW:-$(tput setaf 3)}"
else
  BOLD="${BOLD:-}"
  DIM="${DIM:-}"
  GREEN="${GREEN:-}"
  RED="${RED:-}"
  BLUE="${BLUE:-}"
  YELLOW="${YELLOW:-}"
  RESET="${RESET:-}"
fi

# Logging configuration
LOG_TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
LOG_DIR="${PROJECT_ROOT}/.restockr_logs"
LOG_FILE="${LOG_DIR}/session_${LOG_TIMESTAMP}.log"
mkdir -p "${LOG_DIR}"

# Log rotation: Keep only the last 50 log files
MAX_LOG_FILES=50
MAX_UNCOMPRESSED_LOGS=10  # Keep last 10 logs uncompressed
ENABLE_LOG_COMPRESSION="${RESTOCKR_COMPRESS_LOGS:-true}"

compress_old_logs() {
  # Only compress if gzip is available and feature is enabled
  if [[ "${ENABLE_LOG_COMPRESSION}" != "true" ]] || ! command -v gzip >/dev/null 2>&1; then
    return 0
  fi

  local uncompressed_count
  uncompressed_count=$(find "${LOG_DIR}" -type f -name "session_*.log" ! -name "*.gz" 2>/dev/null | wc -l | tr -d ' ')

  if (( uncompressed_count > MAX_UNCOMPRESSED_LOGS )); then
    local compress_count=$((uncompressed_count - MAX_UNCOMPRESSED_LOGS))
    # Compress oldest uncompressed logs
    find "${LOG_DIR}" -type f -name "session_*.log" ! -name "*.gz" -print0 2>/dev/null | \
      xargs -0 ls -t | \
      tail -n "${compress_count}" | \
      xargs -I {} gzip -f {} 2>/dev/null || true
  fi
}

rotate_logs() {
  local log_count
  # Count both compressed and uncompressed logs
  log_count=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | wc -l | tr -d ' ')

  if (( log_count > MAX_LOG_FILES )); then
    local files_to_delete=$((log_count - MAX_LOG_FILES))
    # Delete oldest log files (compressed or uncompressed)
    find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) -print0 2>/dev/null | \
      xargs -0 ls -t | \
      tail -n "${files_to_delete}" | \
      xargs rm -f 2>/dev/null || true

    if [[ -f "${LOG_FILE}" ]]; then
      printf "[INFO] Rotated logs: removed %d old file(s), keeping last %d\n" "${files_to_delete}" "${MAX_LOG_FILES}" >> "${LOG_FILE}"
    fi
  fi

  # Compress old logs after rotation
  compress_old_logs
}

# Run log rotation before creating new log file
rotate_logs

: > "${LOG_FILE}"

DEBUG_MODE="${RESTOCKR_DEBUG:-false}"
LOG_LEVEL="${RESTOCKR_LOG_LEVEL:-INFO}"  # DEBUG, INFO, WARN, ERROR

# Terminal width for centering
TERM_COLS=80

# ============================================================================
# LOG UTILITIES
# ============================================================================

should_log() {
  local level="$1"
  case "${LOG_LEVEL}" in
    DEBUG) return 0 ;;
    INFO) [[ "${level}" != "DEBUG" ]] && return 0 || return 1 ;;
    WARN) [[ "${level}" =~ ^(WARN|ERROR)$ ]] && return 0 || return 1 ;;
    ERROR) [[ "${level}" == "ERROR" ]] && return 0 || return 1 ;;
    *) return 0 ;;
  esac
}

export_logs() {
  local pattern="${1:-}"
  local output_file="${2:-restockr_logs_export.txt}"

  info "Exporting logs matching pattern: ${pattern:-*}"

  local temp_file="$(mktemp)"
  local log_files

  if [[ -n "${pattern}" ]]; then
    log_files=$(find "${LOG_DIR}" -type f \( -name "session_*${pattern}*.log" -o -name "session_*${pattern}*.log.gz" \) 2>/dev/null | sort -r)
  else
    log_files=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | sort -r)
  fi

  if [[ -z "${log_files}" ]]; then
    warn "No logs found matching pattern: ${pattern:-*}"
    rm -f "${temp_file}"
    return 1
  fi

  printf "RestockR Log Export\n" > "${temp_file}"
  printf "Generated: %s\n" "$(date)" >> "${temp_file}"
  printf "Pattern: %s\n" "${pattern:-*}" >> "${temp_file}"
  printf "%s\n\n" "$(printf '=%.0s' {1..80})" >> "${temp_file}"

  local file_count=0
  while IFS= read -r log_file; do
    ((file_count++))
    printf "\n### Log File %d: %s\n" "${file_count}" "$(basename "${log_file}")" >> "${temp_file}"
    printf "%s\n\n" "$(printf '-%.0s' {1..80})" >> "${temp_file}"

    if [[ "${log_file}" == *.gz ]]; then
      gunzip -c "${log_file}" 2>/dev/null >> "${temp_file}" || \
        printf "[ERROR] Failed to decompress %s\n" "${log_file}" >> "${temp_file}"
    else
      cat "${log_file}" >> "${temp_file}"
    fi
    printf "\n" >> "${temp_file}"
  done <<< "${log_files}"

  mv "${temp_file}" "${output_file}"
  ok "Exported ${file_count} log file(s) to: ${output_file}"
  return 0
}

view_log() {
  local log_identifier="${1:-latest}"
  local log_file=""

  if [[ "${log_identifier}" == "latest" ]]; then
    log_file=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | sort -r | head -n1)
  else
    log_file=$(find "${LOG_DIR}" -type f \( -name "*${log_identifier}*.log" -o -name "*${log_identifier}*.log.gz" \) 2>/dev/null | sort -r | head -n1)
  fi

  if [[ -z "${log_file}" ]]; then
    error "No log found matching: ${log_identifier}"
    return 1
  fi

  info "Viewing log: $(basename "${log_file}")"

  if [[ "${log_file}" == *.gz ]]; then
    if command -v less >/dev/null 2>&1; then
      gunzip -c "${log_file}" | less
    else
      gunzip -c "${log_file}"
    fi
  else
    if command -v less >/dev/null 2>&1; then
      less "${log_file}"
    else
      cat "${log_file}"
    fi
  fi
}

search_logs() {
  local search_term="$1"

  if [[ -z "${search_term}" ]]; then
    error "Search term required"
    printf "Usage: search_logs <term>\n"
    return 1
  fi

  info "Searching logs for: ${search_term}"

  local found=false
  local log_files
  log_files=$(find "${LOG_DIR}" -type f \( -name "session_*.log" -o -name "session_*.log.gz" \) 2>/dev/null | sort -r)

  while IFS= read -r log_file; do
    local matches=""
    if [[ "${log_file}" == *.gz ]]; then
      matches=$(gunzip -c "${log_file}" 2>/dev/null | grep -i "${search_term}" || true)
    else
      matches=$(grep -i "${search_term}" "${log_file}" 2>/dev/null || true)
    fi

    if [[ -n "${matches}" ]]; then
      found=true
      printf "\n${BOLD}%s:${RESET}\n" "$(basename "${log_file}")"
      echo "${matches}"
    fi
  done <<< "${log_files}"

  if [[ "${found}" == false ]]; then
    warn "No matches found for: ${search_term}"
    return 1
  fi

  return 0
}

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

log_plain() {
  printf "%s\n" "$1" >> "${LOG_FILE}"
}

debug() {
  if [[ "${DEBUG_MODE}" == true ]] && should_log "DEBUG"; then
    printf "%b[DEBUG]%b %s\n" "${DIM}${BLUE}" "${RESET}" "$1" >&2
  fi
  if should_log "DEBUG"; then
    log_plain "[DEBUG] $1"
  fi
}

info() {
  if should_log "INFO"; then
    printf "%b[INFO]%b %s\n" "${BLUE}${BOLD}" "${RESET}" "$1"
    log_plain "[INFO] $1"
  fi
}

warn() {
  if should_log "WARN"; then
    printf "%b[WARN]%b %s\n" "${YELLOW}${BOLD}" "${RESET}" "$1"
    log_plain "[WARN] $1"
  fi
}

error() {
  if should_log "ERROR"; then
    printf "%b[ERROR]%b %s\n" "${RED}${BOLD}" "${RESET}" "$1"
    log_plain "[ERROR] $1"
  fi
}

ok() {
  printf "%b[OK]%b %s\n" "${GREEN}${BOLD}" "${RESET}" "$1"
  log_plain "[OK] $1"
}

# Enhanced error logging with stderr capture
log_command() {
  local description="$1"
  shift
  local temp_stdout temp_stderr
  temp_stdout="$(mktemp)"
  temp_stderr="$(mktemp)"

  debug "Executing: $*"

  if "$@" >"${temp_stdout}" 2>"${temp_stderr}"; then
    local exit_code=0
    # Success - log stdout if not empty
    if [[ -s "${temp_stdout}" ]]; then
      cat "${temp_stdout}" >> "${LOG_FILE}"
    fi
    rm -f "${temp_stdout}" "${temp_stderr}"
    return ${exit_code}
  else
    local exit_code=$?
    # Failure - log both stdout and stderr
    log_plain "[ERROR] ${description} failed (exit code: ${exit_code})"
    if [[ -s "${temp_stdout}" ]]; then
      log_plain "[STDOUT]"
      cat "${temp_stdout}" >> "${LOG_FILE}"
    fi
    if [[ -s "${temp_stderr}" ]]; then
      log_plain "[STDERR]"
      cat "${temp_stderr}" >> "${LOG_FILE}"
      # Also show stderr to user
      cat "${temp_stderr}" >&2
    fi
    rm -f "${temp_stdout}" "${temp_stderr}"
    return ${exit_code}
  fi
}

# ============================================================================
# DISPLAY FUNCTIONS
# ============================================================================

update_term_cols() {
  local cols
  cols="$(tput cols 2>/dev/null || true)"
  if [[ -n "${cols}" ]]; then
    TERM_COLS="${cols}"
  elif [[ -n "${COLUMNS:-}" ]]; then
    TERM_COLS="${COLUMNS}"
  else
    TERM_COLS=80
  fi
}

center_line() {
  local line="$1"
  local visible_len pad
  # Strip ANSI escape codes to get actual visible length
  visible_len=$(printf "%s" "$line" | sed 's/\x1b\[[0-9;]*m//g' | wc -c | tr -d ' ')
  if (( visible_len >= TERM_COLS )); then
    printf "%s\n" "$line"
    return
  fi
  pad=$(( (TERM_COLS - visible_len) / 2 ))
  printf "%*s%s\n" "${pad}" "" "$line"
}

print_ascii_art() {
  update_term_cols
  local art="$1"
  local max_width=0
  local line_width

  # Find the widest line in the ASCII art
  while IFS= read -r line; do
    line_width=${#line}
    if (( line_width > max_width )); then
      max_width=$line_width
    fi
  done <<EOF
$art
EOF

  # If terminal is too narrow, don't show the art
  if (( max_width > TERM_COLS )); then
    return 1
  fi

  # Calculate left padding to center the entire block
  local left_pad=$(( (TERM_COLS - max_width) / 2 ))

  # Print each line with consistent left padding
  while IFS= read -r line; do
    if [[ -n "$line" ]]; then
      printf "%*s%s\n" "${left_pad}" "" "$line"
    else
      printf "\n"
    fi
  done <<EOF
$art
EOF

  return 0
}

print_block() {
  update_term_cols
  local block="$1"
  while IFS= read -r line; do
    center_line "$line"
  done <<EOF
$block
EOF
}

print_header() {
  # Use enhanced header if visual.sh is loaded
  if type print_enhanced_header >/dev/null 2>&1; then
    print_enhanced_header
    return
  fi

  # Fallback to original header
  local title_block simple_title pokeball pokeball_compact
  update_term_cols

  read -r -d '' title_block <<'EOF' || true
+==========================================================+
|                    RESTOCKR MOBILE                       |
+----------------------------------------------------------+
|                    DEVELOPER RELEASE                     |
+----------------------------------------------------------+
|                         BY Q                             |
+==========================================================+
EOF

  read -r -d '' simple_title <<'EOF' || true
RESTOCKR MOBILE
DEVELOPER RELEASE
BY Q
EOF

  # Full Pokeball (69 chars wide at widest point)
  read -r -d '' pokeball <<'EOF' || true
                      .+###############+.
                  ###+++++++++++++++++++++###
              .#####++++++++++++++++++++++++++##.
            ##.      -+++++++++++++++++++++++++++##
          #.           ++++++++++++++++++++++++++++##
        #-             ++++++++++++++++++++++++++++++##
      .#.              ++++++++++++++++++++++++++++++++#.
     +#+              ++++++++++++++++++++++++++++++++++#+
    ##++             ++++++++++++++++++++++++++++++++++++##
   ##+++-         .++++++++++++++############+++++++++++++#+
  -#+++++#+-..--++++++++++++++#################++++++++++++#-
  #++++++++++++++++++++++++++######.      .######+++++++++++#
 ##+++++++++++++++++++###########. -     .- -####+++++++++++##
 #++++++++++++##################- .        . #######+++++++++#
 #++++++######################## .         .  ###########++++#.
-#+#############################-          - +################-
-################################  -      # .#################-
-################+           ######        ###################-
 #########-.                  .###############+      -########.
 ###+-------                     ###########-              ###
 #+----------                                               .#
  #----------.                                              #
  -+-----------                                            ++
   #+-----------                                          .#
    #+-----------.                                       .#
     ++------------.                                    ++
      .#-------------.                                -#.
        #+--------------.                         .--+#
          #+----------------..                .----+#
            ##-----------------------------------##
              .##-----------------------------##-
                 .###---------------------###.
                      .#####++--+++#####.
EOF

  # Compact Pokeball (35 chars wide)
  read -r -d '' pokeball_compact <<'EOF' || true
       .+###########+.
    ###++++++++++++++###
  ##+++++++++++++++++++++##
 #++++++++####+++++++++++++#
#+++++++###  ####++++++++++#
#+++############+++++++++++#
#####+      ######++++######
###--         ####       ###
#+---                     +#
 #----                   -#
  ##---                -##
    ####-----------####
       ###########
EOF

  printf "\n"

  if (( TERM_COLS >= 60 )); then
    print_block "$title_block"
  else
    print_block "$simple_title"
  fi
  printf "\n"

  # Try to show appropriate Pokeball based on terminal width
  if (( TERM_COLS >= 75 )); then
    if print_ascii_art "$pokeball"; then
      printf "\n"
      return
    fi
  fi

  if (( TERM_COLS >= 40 )); then
    if print_ascii_art "$pokeball_compact"; then
      printf "\n"
      return
    fi
  fi

  # Terminal too narrow for ASCII art
  center_line "${DIM}[ POKEBALL ]${RESET}"
  printf "\n"
}

# ============================================================================
# ERROR CONTEXT & RECOVERY SUGGESTIONS
# ============================================================================

suggest_flutter_not_found() {
  error "Flutter SDK not found in PATH"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Install Flutter: https://docs.flutter.dev/get-started/install\n"
  printf "  2. Or run: ./install.sh --force\n"
  printf "  3. Ensure Flutter is in your PATH (check ~/.zshrc or ~/.bashrc)\n\n"
}

suggest_flutter_version_mismatch() {
  local current="$1"
  local required="$2"
  error "Flutter version ${current} is too old (requires ${required}+)"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Upgrade Flutter: flutter upgrade\n"
  printf "  2. Or download latest: https://docs.flutter.dev/get-started/install\n"
  printf "  3. Verify version: flutter --version\n\n"
}

suggest_no_devices() {
  error "No Flutter devices available"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  ${BOLD}iOS:${RESET}\n"
  printf "    • Open Simulator app manually\n"
  printf "    • Or use: ./emulators.sh\n"
  printf "  ${BOLD}Android:${RESET}\n"
  printf "    • Create emulator: flutter emulators --create\n"
  printf "    • Or install Android Studio: https://developer.android.com/studio\n"
  printf "  ${BOLD}Check status:${RESET}\n"
  printf "    • List devices: flutter devices\n"
  printf "    • List emulators: flutter emulators\n\n"
}

suggest_pub_get_failed() {
  local exit_code="$1"
  error "flutter pub get failed (exit code: ${exit_code})"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Check your internet connection\n"
  printf "  2. Verify pubspec.yaml syntax is correct\n"
  printf "  3. Try: flutter pub cache repair\n"
  printf "  4. Check log file: ${LOG_FILE}\n\n"
}

suggest_build_failed() {
  local platform="$1"
  local exit_code="$2"
  error "${platform} build failed (exit code: ${exit_code})"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  if [[ "${platform}" == "iOS" ]]; then
    printf "  1. Check Xcode is installed: xcode-select -p\n"
    printf "  2. Accept Xcode license: sudo xcodebuild -license accept\n"
    printf "  3. Run CocoaPods: cd ios && pod install\n"
    printf "  4. Check log file: ${LOG_FILE}\n\n"
  elif [[ "${platform}" == "Android" ]]; then
    printf "  1. Check Android SDK is installed: flutter doctor\n"
    printf "  2. Accept Android licenses: flutter doctor --android-licenses\n"
    printf "  3. Ensure ANDROID_HOME is set\n"
    printf "  4. Check log file: ${LOG_FILE}\n\n"
  else
    printf "  1. Run: flutter doctor\n"
    printf "  2. Check log file: ${LOG_FILE}\n\n"
  fi
}

suggest_emulator_launch_failed() {
  local emulator_id="$1"
  error "Failed to launch emulator: ${emulator_id}"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. List available emulators: flutter emulators\n"
  printf "  2. Check emulator exists in Android Studio\n"
  printf "  3. Ensure emulator ID is correct (case-sensitive)\n"
  printf "  4. Try launching manually from Android Studio\n"
  printf "  5. Check system resources (emulators need RAM/CPU)\n\n"
}

suggest_simulator_not_found() {
  error "iOS Simulator not found"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Install Xcode from App Store\n"
  printf "  2. Install Xcode Command Line Tools: xcode-select --install\n"
  printf "  3. Open Xcode and install additional components\n"
  printf "  4. Verify installation: xcrun simctl list\n\n"
}

suggest_cocoapods_failed() {
  local exit_code="$1"
  error "CocoaPods installation failed (exit code: ${exit_code})"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Try with sudo: sudo gem install cocoapods\n"
  printf "  2. Or use Homebrew: brew install cocoapods\n"
  printf "  3. Check Ruby version: ruby --version (needs 2.6+)\n"
  printf "  4. Check log file: ${LOG_FILE}\n\n"
}

backend_config_summary() {
  local env_file="${PROJECT_ROOT}/env.json"

  if [[ ! -f "${env_file}" ]]; then
    return 1
  fi

  if command -v python3 >/dev/null 2>&1; then
    RESTOCKR_ENV_FILE="${env_file}" python3 - <<'PY'
import json, os, pathlib, sys

path = pathlib.Path(os.environ.get("RESTOCKR_ENV_FILE", "env.json"))
try:
    with path.open() as fp:
        data = json.load(fp)
except Exception:
    sys.exit(1)

env = data.get("RESTOCKR_ENV", "unknown")
api = data.get("RESTOCKR_API_BASE", "") or "API unset"
ws = data.get("RESTOCKR_WS_URL", "") or "ws disabled"
print(f"Env: {env} • API: {api} • WS: {ws}", end="")
PY
    return $?
  fi

  local env_value api_value ws_value
  env_value="$(grep -o '"RESTOCKR_ENV"[[:space:]]*:[[:space:]]*"[^"]*"' "${env_file}" 2>/dev/null | head -n1 | sed 's/.*:"\(.*\)"/\1/' || true)"
  api_value="$(grep -o '"RESTOCKR_API_BASE"[[:space:]]*:[[:space:]]*"[^"]*"' "${env_file}" 2>/dev/null | head -n1 | sed 's/.*:"\(.*\)"/\1/' || true)"
  ws_value="$(grep -o '"RESTOCKR_WS_URL"[[:space:]]*:[[:space:]]*"[^"]*"' "${env_file}" 2>/dev/null | head -n1 | sed 's/.*:"\(.*\)"/\1/' || true)"
  printf "Env: %s • API: %s • WS: %s" \
    "${env_value:-unknown}" \
    "${api_value:-API unset}" \
    "${ws_value:-ws disabled}"
}

suggest_env_json_missing() {
  warn "env.json not found or incomplete"
  printf "\n${YELLOW}${BOLD}What to do next:${RESET}\n"
  printf "  1. Run: ./envsetup.sh to create template\n"
  printf "  2. Edit env.json with your endpoints and keys\n"
  printf "  3. Required keys:\n"
  printf "     • RESTOCKR_API_BASE\n"
  printf "     • SUPABASE_URL\n"
  printf "     • SUPABASE_ANON_KEY\n"
  printf "  4. Ensure file permissions: chmod 600 env.json\n\n"
}

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

version_ge() {
  local have="$1"
  local want="$2"
  if [[ "$(printf '%s\n' "${want}" "${have}" | sort -V | head -n1)" == "${want}" ]]; then
    return 0
  fi
  return 1
}

# ============================================================================
# TIMING UTILITIES
# ============================================================================

# Start a timer - stores start time in a variable
timer_start() {
  local timer_name="$1"
  local varname="TIMER_${timer_name}_START"
  eval "${varname}=$(date +%s)"
  debug "Timer '${timer_name}' started"
}

# Get elapsed time in seconds
timer_elapsed() {
  local timer_name="$1"
  local varname="TIMER_${timer_name}_START"
  local start_time
  eval "start_time=\${${varname}:-0}"

  if [[ "${start_time}" == "0" ]]; then
    echo "0"
    return 1
  fi

  local current_time
  current_time=$(date +%s)
  local elapsed=$((current_time - start_time))
  echo "${elapsed}"
}

# Format elapsed time as human-readable string
format_elapsed() {
  local seconds="$1"

  if (( seconds < 60 )); then
    echo "${seconds}s"
  elif (( seconds < 3600 )); then
    local mins=$((seconds / 60))
    local secs=$((seconds % 60))
    echo "${mins}m ${secs}s"
  else
    local hours=$((seconds / 3600))
    local mins=$(( (seconds % 3600) / 60 ))
    local secs=$((seconds % 60))
    echo "${hours}h ${mins}m ${secs}s"
  fi
}

# Complete a timer and log the result
timer_end() {
  local timer_name="$1"
  local description="${2:-${timer_name}}"
  local elapsed

  elapsed=$(timer_elapsed "${timer_name}")
  local formatted
  formatted=$(format_elapsed "${elapsed}")

  info "${description} completed in ${formatted}"
  log_plain "[TIMING] ${description}: ${elapsed}s"
}

# ============================================================================
# SECURITY & INPUT VALIDATION
# ============================================================================

validate_device_id() {
  local id="$1"

  # Check if empty
  if [[ -z "${id}" ]]; then
    debug "validate_device_id: empty device ID"
    return 1
  fi

  # Device IDs should be alphanumeric, hyphens, underscores, and dots only
  # Examples: "emulator-5554", "00008020-001E55E83A80002E", "chrome", "macos"
  if [[ ! "${id}" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    warn "Invalid device ID format (contains special characters): ${id}"
    debug "Device ID validation failed for: ${id}"
    return 1
  fi

  # Additional length check (device IDs shouldn't be extremely long)
  if (( ${#id} > 128 )); then
    warn "Device ID exceeds maximum length: ${id}"
    return 1
  fi

  echo "${id}"
  return 0
}

sanitize_input() {
  local input="$1"

  # Remove shell metacharacters and potentially dangerous characters
  # Keep: alphanumeric, spaces, hyphens, underscores, dots, forward slashes
  input="${input//\`/}"  # Remove backticks
  input="${input//[;&|<>$(){}[\]*?!\\]/}"  # Remove other dangerous chars

  # Trim leading/trailing whitespace
  input="$(printf '%s' "${input}" | xargs)"

  # Limit length to prevent buffer issues
  if (( ${#input} > 256 )); then
    input="${input:0:256}"
  fi

  printf '%s' "${input}"
}

run_python3_with_timeout() {
  local timeout_seconds="${1:-10}"
  local script="$2"
  local env_vars="${3:-}"

  # Check if timeout command is available
  if command -v timeout >/dev/null 2>&1; then
    # Use GNU timeout if available
    if [[ -n "${env_vars}" ]]; then
      timeout "${timeout_seconds}s" env ${env_vars} python3 - <<EOF
${script}
EOF
    else
      timeout "${timeout_seconds}s" python3 - <<EOF
${script}
EOF
    fi
    return $?
  fi

  # Fallback: manual timeout using background process
  local temp_output
  temp_output="$(mktemp)"
  local python_pid

  # Run Python in background
  (
    if [[ -n "${env_vars}" ]]; then
      env ${env_vars} python3 - <<EOF >"${temp_output}" 2>&1
${script}
EOF
    else
      python3 - <<EOF >"${temp_output}" 2>&1
${script}
EOF
    fi
  ) &
  python_pid=$!

  # Wait with timeout
  local elapsed=0
  while kill -0 "${python_pid}" 2>/dev/null; do
    if (( elapsed >= timeout_seconds )); then
      kill -9 "${python_pid}" 2>/dev/null
      rm -f "${temp_output}"
      error "Python3 processing timed out after ${timeout_seconds}s"
      return 124  # Timeout exit code
    fi
    sleep 1
    ((elapsed++))
  done

  # Get result
  wait "${python_pid}"
  local exit_code=$?

  # Output result
  cat "${temp_output}"
  rm -f "${temp_output}"

  return ${exit_code}
}

cleanup() {
  printf "\n${DIM}Closing ${APP_NAME} utilities.${RESET}\n"
  log_plain "[INFO] Closing ${APP_NAME} utilities"
}

# Don't register trap in library - let calling scripts handle it

# Log initialization
log_plain "=== RestockR common library initialized ${LOG_TIMESTAMP} ==="
