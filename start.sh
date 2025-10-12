#!/usr/bin/env bash

set -euo pipefail

APP_NAME="RestockR"
MIN_FLUTTER_VERSION="3.29.2"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVKIT_MARKER="${PROJECT_ROOT}/.restockr_devkit"

if [[ -t 1 ]]; then
  BOLD="$(tput bold)"
  DIM="$(tput dim)"
  GREEN="$(tput setaf 2)"
  RED="$(tput setaf 1)"
  BLUE="$(tput setaf 4)"
  YELLOW="$(tput setaf 3)"
  RESET="$(tput sgr0)"
else
  BOLD=""
  DIM=""
  GREEN=""
  RED=""
  BLUE=""
  YELLOW=""
  RESET=""
fi

TERM_COLS=80
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

info()  { printf "%b[INFO]%b %s\n" "${BLUE}${BOLD}" "${RESET}" "$1"; }
warn()  { printf "%b[WARN]%b %s\n" "${YELLOW}${BOLD}" "${RESET}" "$1"; }
error() { printf "%b[ERROR]%b %s\n" "${RED}${BOLD}" "${RESET}" "$1"; }
ok()    { printf "%b[OK]%b %s\n" "${GREEN}${BOLD}" "${RESET}" "$1"; }

cleanup() {
  printf "\n${DIM}Closing ${APP_NAME} starter.${RESET}\n"
}
trap cleanup EXIT

version_ge() {
  local have="$1"
  local want="$2"
  if [[ "$(printf '%s\n' "${want}" "${have}" | sort -V | head -n1)" == "${want}" ]]; then
    return 0
  fi
  return 1
}

ensure_structure() {
  info "Validating project structure"
  local required_items missing
  required_items=("pubspec.yaml" "lib" "assets" "android" "ios" "web" "analysis_options.yaml")
  missing=()
  local item
  for item in "${required_items[@]}"; do
    if [[ ! -e "${PROJECT_ROOT}/${item}" ]]; then
      missing+=("${item}")
    fi
  done
  if (( ${#missing[@]} > 0 )); then
    error "Missing required project items:"
    for item in "${missing[@]}"; do
      printf "  - %s\n" "${item}"
    done
    printf "Please re-extract the RestockR archive and retry.\n"
    exit 1
  fi
  ok "Project structure looks good"
}

ensure_env_file() {
  info "Ensuring env.json exists"
  local env_file="${PROJECT_ROOT}/env.json"
  if [[ -f "${env_file}" ]]; then
    ok "env.json present"
    return
  fi
  warn "env.json missing; creating placeholder."
  cat > "${env_file}" <<'JSON'
{
  "SUPABASE_URL": "https://update-me.supabase.co",
  "SUPABASE_ANON_KEY": "replace-me",
  "OPENAI_API_KEY": "replace-me",
  "GEMINI_API_KEY": "replace-me",
  "ANTHROPIC_API_KEY": "replace-me",
  "PERPLEXITY_API_KEY": "replace-me"
}
JSON
  ok "Created env.json placeholder with dummy keys."
}

attempt_install_flutter() {
  local os resp
  os="$(uname -s)"
  case "${os}" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        warn "Flutter not detected. Attempt installation via Homebrew?"
        read -r -p "Run 'brew install --cask flutter'? [y/N] " resp || true
        resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
        if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
          if brew list --cask flutter >/dev/null 2>&1; then
            ok "Flutter already managed by Homebrew."
          else
            warn "Installing Flutter (this may take a moment)."
            if brew install --cask flutter; then
              ok "Homebrew installation complete."
            else
              warn "Homebrew installation failed. Install manually: https://docs.flutter.dev/get-started/install/macos"
            fi
          fi
        fi
      else
        warn "Homebrew not detected. Install Flutter manually: https://docs.flutter.dev/get-started/install/macos"
      fi
      ;;
    Linux)
      if command -v snap >/dev/null 2>&1; then
        warn "Flutter not detected. Attempt installation via snap?"
        read -r -p "Run 'sudo snap install flutter --classic'? [y/N] " resp || true
        resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
        if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
          if sudo snap install flutter --classic; then
            ok "Snap installation complete."
          else
            warn "Snap installation failed. Install manually: https://docs.flutter.dev/get-started/install/linux"
          fi
        fi
      else
        warn "Automatic install unavailable. Follow Flutter setup guide for Linux."
      fi
      ;;
    *)
      warn "Automatic Flutter installation not supported on ${os}. Install manually via https://docs.flutter.dev/get-started/install"
      ;;
  esac
}

attempt_install_git() {
  local os resp
  os="$(uname -s)"
  case "${os}" in
    Darwin)
      if command -v brew >/dev/null 2>&1; then
        warn "Git not detected. Attempt installation via Homebrew?"
        read -r -p "Run 'brew install git'? [y/N] " resp || true
        resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
        if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
          if brew install git; then
            ok "Installed git via Homebrew."
          else
            warn "Homebrew git installation failed."
          fi
        fi
      else
        warn "Install Xcode Command Line Tools (xcode-select --install) to get git."
      fi
      ;;
    Linux)
      if command -v apt-get >/dev/null 2>&1; then
        warn "Git not detected. Attempt installation via apt?"
        read -r -p "Run 'sudo apt-get update && sudo apt-get install git'? [y/N] " resp || true
        resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
        if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
          if sudo apt-get update && sudo apt-get install -y git; then
            ok "Installed git via apt."
          else
            warn "apt git installation failed."
          fi
        fi
      elif command -v dnf >/dev/null 2>&1; then
        warn "Git not detected. Attempt installation via dnf?"
        read -r -p "Run 'sudo dnf install git'? [y/N] " resp || true
        resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
        if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
          if sudo dnf install -y git; then
            ok "Installed git via dnf."
          else
            warn "dnf git installation failed."
          fi
        fi
      else
        warn "Install git using your distribution package manager."
      fi
      ;;
    *)
      warn "Install git manually from https://git-scm.com/downloads"
      ;;
  esac
}

ensure_command() {
  local cmd="$1"
  local attempt_func="$2"
  local instructions="$3"

  if command -v "${cmd}" >/dev/null 2>&1; then
    ok "Found ${cmd}"
    return 0
  fi

  warn "Missing required command: ${cmd}"
  if [[ -n "${attempt_func}" ]]; then
    "${attempt_func}"
  fi

  if command -v "${cmd}" >/dev/null 2>&1; then
    ok "${cmd} available after repair"
    return 0
  fi

  error "${cmd} is still missing. ${instructions}"
  return 1
}

diagnose_dependencies() {
  info "Checking required tooling"
  local success=0

  ensure_command "git" "attempt_install_git" "Install git and re-run this script." || success=1
  ensure_command "flutter" "attempt_install_flutter" "Install Flutter ${MIN_FLUTTER_VERSION}+ and re-run this script." || success=1

  if (( success != 0 )); then
    error "Dependency check failed. Address the issues above and restart."
    exit 1
  fi

  # Verify dart is available
  if ! command -v dart >/dev/null 2>&1; then
    warn "Dart not found; it should be bundled with Flutter. Checking installation..."
    # Refresh shell environment
    if [[ -f "${HOME}/.zshrc" ]]; then
      source "${HOME}/.zshrc" 2>/dev/null || true
    elif [[ -f "${HOME}/.bashrc" ]]; then
      source "${HOME}/.bashrc" 2>/dev/null || true
    fi

    if ! command -v dart >/dev/null 2>&1; then
      error "Dart still not found. Flutter may not be properly installed."
      error "Try closing and reopening your terminal, then run this script again."
      exit 1
    fi
  fi
  ok "Found dart"

  # Verify Flutter version
  info "Verifying Flutter installation"
  local version
  version="$(flutter --version 2>/dev/null | head -n1 | awk '{print $2}')"
  if [[ -n "${version}" ]]; then
    if version_ge "${version}" "${MIN_FLUTTER_VERSION}"; then
      ok "Flutter ${version} (meets minimum ${MIN_FLUTTER_VERSION})"
    else
      warn "Flutter ${version} detected; ${APP_NAME} recommends ${MIN_FLUTTER_VERSION}+"
    fi
  else
    error "Unable to determine Flutter version."
    error "Flutter may not be properly installed. Try: flutter doctor"
    exit 1
  fi

  # Quick Flutter doctor check
  info "Running Flutter self-check (flutter doctor --android-licenses skipped)"
  if flutter doctor 2>&1 | grep -q "Doctor found issues"; then
    warn "Flutter doctor found some issues. You may need to run 'flutter doctor' manually."
  else
    ok "Flutter self-check passed"
  fi
}

run_flutter_command() {
  local description="$1"
  shift
  if ! command -v flutter >/dev/null 2>&1; then
    error "Flutter is required to ${description}. Skipping."
    return 1
  fi
  info "${description}"
  if (cd "${PROJECT_ROOT}" && "$@"); then
    ok "${description} completed"
  else
    error "${description} failed"
    return 1
  fi
}

run_flutter_clean() {
  run_flutter_command "Cleaning Flutter build artifacts" flutter clean
}

run_pub_get() {
  run_flutter_command "Installing Flutter dependencies (flutter pub get)" flutter pub get
}

run_flutter_devices() {
  run_flutter_command "Listing connected devices" flutter devices
}

run_flutter_doctor() {
  run_flutter_command "Running flutter doctor" flutter doctor
}

run_flutter_run() {
  run_flutter_command "Launching ${APP_NAME}" flutter run "$@"
}

run_flutter_test() {
  run_flutter_command "Running flutter test" flutter test
}

run_flutter_analyze() {
  run_flutter_command "Running flutter analyze" flutter analyze
}

reset_workspace() {
  warn "Resetting workspace (flutter clean, deleting artifacts)"
  if command -v flutter >/dev/null 2>&1; then
    run_flutter_clean || true
  fi
  rm -rf "${PROJECT_ROOT}/.dart_tool" "${PROJECT_ROOT}/build"
  rm -f "${PROJECT_ROOT}/pubspec.lock"
  ok "Workspace reset complete"
}

mark_install() {
  printf "installed_at=%s\n" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")" > "${DEVKIT_MARKER}"
}

check_install_status() {
  if [[ ! -f "${DEVKIT_MARKER}" ]]; then
    return 1
  fi

  # Check if pubspec.lock exists (indicates deps are installed)
  if [[ ! -f "${PROJECT_ROOT}/pubspec.lock" ]]; then
    return 1
  fi

  return 0
}

list_emulators() {
  info "Detecting available emulators"

  local ios_sims android_emus chrome_available
  ios_sims=()
  android_emus=()
  chrome_available=false

  # Check for iOS simulators (macOS only)
  if [[ "$(uname -s)" == "Darwin" ]] && command -v xcrun >/dev/null 2>&1; then
    while IFS= read -r line; do
      ios_sims+=("$line")
    done < <(xcrun simctl list devices available 2>/dev/null | grep -E "iPhone|iPad" | grep -v "unavailable" | sed 's/^[[:space:]]*//' || true)
  fi

  # Check for Android emulators
  local emulator_cmd
  if command -v flutter >/dev/null 2>&1; then
    emulator_cmd="$(flutter sdk-path 2>/dev/null)/../../bin/avdmanager" || emulator_cmd=""
  fi

  if [[ -n "${emulator_cmd}" ]] && [[ -f "${emulator_cmd}" ]]; then
    while IFS= read -r line; do
      android_emus+=("$line")
    done < <("${emulator_cmd}" list avd 2>/dev/null | grep "Name:" | sed 's/Name: //' || true)
  elif command -v avdmanager >/dev/null 2>&1; then
    while IFS= read -r line; do
      android_emus+=("$line")
    done < <(avdmanager list avd 2>/dev/null | grep "Name:" | sed 's/Name: //' || true)
  fi

  # Check for Chrome
  if command -v google-chrome >/dev/null 2>&1 || command -v chrome >/dev/null 2>&1 || [[ -d "/Applications/Google Chrome.app" ]]; then
    chrome_available=true
  fi

  # Display results
  local total_count=0
  printf "\n${BOLD}Available Emulators & Devices:${RESET}\n\n"

  if (( ${#ios_sims[@]} > 0 )); then
    printf "${GREEN}iOS Simulators:${RESET}\n"
    for sim in "${ios_sims[@]}"; do
      printf "  • %s\n" "$sim"
      ((total_count++))
    done
    printf "\n"
  fi

  if (( ${#android_emus[@]} > 0 )); then
    printf "${GREEN}Android Emulators:${RESET}\n"
    for emu in "${android_emus[@]}"; do
      printf "  • %s\n" "$emu"
      ((total_count++))
    done
    printf "\n"
  fi

  if $chrome_available; then
    printf "${GREEN}Web:${RESET}\n"
    printf "  • Chrome (Web)\n\n"
    ((total_count++))
  fi

  if (( total_count == 0 )); then
    warn "No emulators detected."
    printf "\n${DIM}To create emulators:${RESET}\n"
    printf "  • Android: Use Android Studio AVD Manager\n"
    printf "  • iOS: Use Xcode (macOS only)\n"
    printf "  • Run 'flutter doctor' for more info\n\n"
    return 1
  fi

  ok "Found ${total_count} emulator(s)"
  return 0
}

setup_xcode() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    error "Xcode is only available on macOS"
    return 1
  fi

  printf "\n${BOLD}${BLUE}Xcode Setup Wizard${RESET}\n\n"

  # Check if Xcode is installed
  if ! command -v xcodebuild >/dev/null 2>&1; then
    warn "Xcode is not installed"
    printf "\n${BOLD}Installation Options:${RESET}\n"
    printf "  1. Install via App Store (Recommended)\n"
    printf "  2. Download from Apple Developer\n\n"

    read -r -p "Open App Store to install Xcode? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      open "macappstore://apps.apple.com/app/xcode/id497799835"
      info "App Store opened. Install Xcode, then run this script again."
      return 1
    fi
    return 1
  fi

  # Xcode is installed, check if command line tools are configured
  if ! xcode-select -p >/dev/null 2>&1; then
    warn "Xcode command line tools not configured"
    read -r -p "Configure Xcode command line tools? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      info "Running: sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer"
      if sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer; then
        ok "Xcode command line tools configured"
      else
        error "Failed to configure Xcode"
        return 1
      fi
    fi
  fi

  # Accept Xcode license
  if ! xcodebuild -license check >/dev/null 2>&1; then
    warn "Xcode license not accepted"
    read -r -p "Accept Xcode license? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      sudo xcodebuild -license accept
      ok "Xcode license accepted"
    fi
  fi

  # Run first launch
  info "Running Xcode first-launch setup (this may take a moment)"
  if sudo xcodebuild -runFirstLaunch 2>/dev/null; then
    ok "Xcode first-launch complete"
  fi

  # Check for CocoaPods
  if ! command -v pod >/dev/null 2>&1; then
    warn "CocoaPods not installed (required for iOS development)"
    read -r -p "Install CocoaPods? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      info "Installing CocoaPods via gem"
      if sudo gem install cocoapods; then
        ok "CocoaPods installed successfully"
      else
        warn "CocoaPods installation failed. Try manually: sudo gem install cocoapods"
      fi
    fi
  fi

  ok "Xcode setup complete!"
  return 0
}

setup_android_studio() {
  printf "\n${BOLD}${BLUE}Android Studio Setup Wizard${RESET}\n\n"

  # Check if Android Studio is installed
  local android_studio_path=""
  if [[ -d "/Applications/Android Studio.app" ]]; then
    android_studio_path="/Applications/Android Studio.app"
  fi

  if [[ -z "${android_studio_path}" ]]; then
    warn "Android Studio is not installed"
    printf "\n${BOLD}To install Android Studio:${RESET}\n"
    printf "  1. Visit: ${BLUE}https://developer.android.com/studio${RESET}\n"
    printf "  2. Download and install Android Studio\n"
    printf "  3. Run Android Studio and complete the setup wizard\n"
    printf "  4. Install Android SDK and create an AVD (virtual device)\n\n"

    read -r -p "Open Android Studio download page? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      open "https://developer.android.com/studio"
      info "Download page opened. Install Android Studio, then run this script again."
    fi
    return 1
  fi

  ok "Android Studio found at: ${android_studio_path}"

  # Check if Android SDK is configured
  local android_home="${ANDROID_HOME:-${HOME}/Library/Android/sdk}"
  if [[ ! -d "${android_home}" ]]; then
    warn "Android SDK not found at: ${android_home}"
    info "Please run Android Studio and complete the setup wizard to install the SDK."
    read -r -p "Open Android Studio now? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      open -a "Android Studio"
      info "Android Studio opened. Complete setup, then run this script again."
    fi
    return 1
  fi

  ok "Android SDK found at: ${android_home}"

  # Offer to accept licenses
  if [[ -x "${android_home}/cmdline-tools/latest/bin/sdkmanager" ]]; then
    read -r -p "Accept Android SDK licenses? [y/N] " resp || true
    resp="$(printf '%s' "${resp}" | tr '[:upper:]' '[:lower:]')"
    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      info "Accepting Android SDK licenses"
      yes | "${android_home}/cmdline-tools/latest/bin/sdkmanager" --licenses 2>/dev/null || true
      ok "Android SDK licenses accepted"
    fi
  fi

  ok "Android Studio setup complete!"
  return 0
}

summarize_devices() {
  if ! command -v flutter >/dev/null 2>&1; then
    warn "Flutter is not installed yet. Install dependencies from the main menu."
    return
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    warn "Python 3 not available; showing raw flutter devices output."
    flutter devices 2>/dev/null || true
    return
  fi

  local json
  if ! json="$(flutter devices --machine 2>/dev/null)"; then
    warn "Unable to query connected devices."
    return
  fi

  if [[ -z "${json}" ]]; then
    warn "No devices detected."
    return
  fi

  RESTOCKR_JSON="${json}" python3 - <<'PY'
import json, os

payload = os.environ.get("RESTOCKR_JSON", "").strip()
if not payload:
    print("No devices detected.")
    raise SystemExit

try:
    data = json.loads(payload)
except Exception:
    print("Unable to parse device list.")
    raise SystemExit

connected = [d for d in data if d.get("ephemeral")]
others = [d for d in data if not d.get("ephemeral")]

if connected:
    print("Connected devices:")
    for d in connected:
        print(f"  • {d.get('name')} ({d.get('id')}) – {d.get('platform')}")
else:
    print("No active devices detected.")

if others:
    print("\nAvailable (not running):")
    for d in others:
        print(f"  • {d.get('name')} ({d.get('id')}) – {d.get('platform')}")
PY
}

list_emulators_json() {
  if ! command -v flutter >/dev/null 2>&1; then
    warn "Flutter is not installed yet."
    return 1
  fi
  flutter emulators --machine 2>/dev/null || return 1
}

list_emulators() {
  local json
  if ! json="$(list_emulators_json)"; then
    warn "Unable to query Flutter emulators."
    return 1
  fi

  if ! command -v python3 >/dev/null 2>&1; then
    printf "%s\n" "${json}"
    return 0
  fi

  RESTOCKR_JSON="${json}" python3 - <<'PY'
import json, os

payload = os.environ.get("RESTOCKR_JSON", "").strip()
if not payload:
    print("No emulators available.")
    raise SystemExit

try:
    data = json.loads(payload)
except Exception:
    print("Unable to parse emulator list.")
    raise SystemExit

if not data:
    print("No emulators have been created yet.")
    raise SystemExit

print("Available emulators:")
for emulator in data:
    print(f"  • {emulator.get('name')} ({emulator.get('id')}) – {emulator.get('platform')}")
PY
}

open_simulator_app() {
  if ! command -v open >/dev/null 2>&1; then
    error "'open' command not found. Launch Simulator manually from Xcode."
    return 1
  fi

  # Try default Application bundle resolution first
  if open -a Simulator >/dev/null 2>&1; then
    ok "Simulator app launching..."
    return 0
  fi

  # Derive Simulator path from active Xcode
  if command -v xcode-select >/dev/null 2>&1; then
    local dev_dir
    dev_dir="$(xcode-select -p 2>/dev/null || true)"
    if [[ -n "${dev_dir}" ]]; then
      local sim_app="${dev_dir}/Applications/Simulator.app"
      if [[ -d "${sim_app}" ]]; then
        if open "${sim_app}" >/dev/null 2>&1; then
          ok "Simulator app launching..."
          return 0
        fi
      fi
    fi
  fi

  # Fallback to global Applications path
  local fallback="/Applications/Xcode.app/Contents/Developer/Applications/Simulator.app"
  if [[ -d "${fallback}" ]]; then
    if open "${fallback}" >/dev/null 2>&1; then
      ok "Simulator app launching..."
      return 0
    fi
  fi

  error "Unable to open Simulator automatically. Launch it via Xcode: Xcode ▸ Open Developer Tool ▸ Simulator."
  return 1
}

create_ios_simulator() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi
  if ! command -v xcrun >/dev/null 2>&1; then
    warn "xcrun not available; cannot create iOS simulator automatically."
    return 1
  fi

  local runtime_id device_id
  runtime_id="$(xcrun simctl list runtimes 2>/dev/null | sed -n 's/.* - \(com\.apple\.CoreSimulator\.SimRuntime\.iOS-[^ ]*\) (.*/\1/p' | head -n1)"
  device_id="$(xcrun simctl list devicetypes 2>/dev/null | sed -n 's/.*(\(com\.apple\.CoreSimulator\.SimDeviceType\.iPhone[^)]*\)).*/\1/p' | head -n1)"

  if [[ -z "${runtime_id}" ]]; then
    runtime_id="com.apple.CoreSimulator.SimRuntime.iOS-18-0"
  fi
  if [[ -z "${device_id}" ]]; then
    device_id="com.apple.CoreSimulator.SimDeviceType.iPhone-15"
  fi

  if [[ -z "${runtime_id}" || -z "${device_id}" ]]; then
    warn "Unable to determine iOS runtime or device type for simulator creation."
    return 1
  fi

  local sim_name="RestockR iPhone $(date +%H%M%S)"
  info "Creating iOS simulator '${sim_name}'"
  if xcrun simctl create "${sim_name}" "${device_id}" "${runtime_id}" >/dev/null 2>&1; then
    ok "Created simulator '${sim_name}'."
    return 0
  fi

  warn "Failed to create iOS simulator automatically."
  return 1
}

ensure_ios_simulator() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi
  if ! command -v xcrun >/dev/null 2>&1; then
    return 1
  fi

  local existing
  existing="$(xcrun simctl list devices available 2>/dev/null | grep -i 'iPhone' || true)"
  if [[ -n "${existing}" ]]; then
    return 0
  fi

  create_ios_simulator
}

create_android_emulator() {
  if ! command -v flutter >/dev/null 2>&1; then
    return 1
  fi

  local existing
  existing="$(flutter emulators 2>/dev/null | grep -i 'android' || true)"
  if [[ -n "${existing}" ]]; then
    return 0
  fi

  local name="restockr_avd"
  info "Creating Android emulator '${name}'"
  if flutter emulators --create --name "${name}" --device pixel >/dev/null 2>&1; then
    ok "Created Android emulator '${name}'."
    return 0
  fi

  warn "Failed to auto-create Android emulator."
  return 1
}

get_device_id_by_platform() {
  local platform="$1"
  local json

  json="$(flutter devices --machine 2>/dev/null || echo "[]")"

  if command -v python3 >/dev/null 2>&1; then
    local device_id
    device_id="$(RESTOCKR_JSON="${json}" TARGET_PLATFORM="${platform}" python3 -c 'import json, os; payload=os.environ.get("RESTOCKR_JSON","[]"); target=os.environ.get("TARGET_PLATFORM","").lower();
try:
    devices=json.loads(payload)
except Exception:
    devices=[]
for device in devices:
    if not device.get("ephemeral"):
        continue
    plat=(device.get("platform") or "").lower()
    tar=(device.get("targetPlatform") or "").lower()
    if not target or target in plat or target in tar:
        dev_id=(device.get("id") or "").strip()
        if dev_id:
            print(dev_id, end="")
            break' 2>/dev/null)"
    if [[ -n "${device_id}" ]]; then
      echo "${device_id}"
      return 0
    fi
  fi

  local text
  text="$(flutter devices 2>/dev/null || true)"
  if [[ -n "${text}" ]]; then
    local id
    case "${platform}" in
      ios)
        id="$(echo "${text}" | awk -F '•' '/iOS/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')"
        ;;
      android)
        id="$(echo "${text}" | awk -F '•' '/android/i {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')"
        ;;
      *)
        id="$(echo "${text}" | awk -F '•' 'NR==1 {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2; exit}')"
        ;;
    esac
    if [[ -n "${id}" ]]; then
      echo "${id}"
      return 0
    fi
  fi

  return 1
}

wait_for_device() {
  local platform="$1"
  local attempts="${2:-45}"
  local delay="${3:-2}"
  local device_id=""

  for ((i = 0; i < attempts; i++)); do
    if device_id="$(get_device_id_by_platform "${platform}")"; then
      if [[ -n "${device_id}" ]]; then
        echo "${device_id}"
        return 0
      fi
    fi
    sleep "${delay}"
  done
  return 1
}

launch_ios_environment() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi
  if ! command -v xcodebuild >/dev/null 2>&1; then
    return 1
  fi

  ensure_ios_simulator || true
  open_simulator_app || true

  info "Waiting for iOS simulator to boot..."
  local device_id
  if ! device_id="$(wait_for_device "ios" 60 2)"; then
    warn "No iOS simulator detected after waiting."
    return 1
  fi

  info "Launching ${APP_NAME} on iOS simulator (${device_id})"
  run_flutter_run -d "${device_id}"
  return 0
}

launch_android_environment() {
  local has_android=false
  if [[ -d "/Applications/Android Studio.app" ]] || [[ -n "${ANDROID_HOME:-}" ]]; then
    has_android=true
  fi
  if ! $has_android; then
    return 1
  fi

  create_android_emulator || true

  info "Starting Android emulator (restockr_avd)"
  flutter emulators --launch restockr_avd >/dev/null 2>&1 || true

  info "Waiting for Android emulator to boot..."
  local device_id
  if ! device_id="$(wait_for_device "android" 90 3)"; then
    warn "Android emulator not ready."
    return 1
  fi

  info "Launching ${APP_NAME} on Android emulator (${device_id})"
  run_flutter_run -d "${device_id}"
  return 0
}

auto_launch_default_environment() {
  info "Preparing development environment (autostart)"

  if launch_ios_environment; then
    return 0
  fi

  if launch_android_environment; then
    return 0
  fi

  warn "Falling back to Chrome (web)"
  run_flutter_run -d chrome
}

launch_emulator_menu() {
  printf "\n${BOLD}${BLUE}Emulator Launcher${RESET}\n"

  while true; do
    printf "\n${BOLD}Connected devices:${RESET}\n"
    summarize_devices

    local has_xcode=false has_android=false
    if [[ "$(uname -s)" == "Darwin" ]] && command -v xcodebuild >/dev/null 2>&1; then
      has_xcode=true
    fi
    if [[ -d "/Applications/Android Studio.app" ]] || [[ -n "${ANDROID_HOME:-}" ]]; then
      has_android=true
    fi

    printf "\n${BOLD}Emulator Options:${RESET}\n"
    printf "  ${GREEN}[1]${RESET} Launch in Chrome (Web)\n"
    printf "  ${GREEN}[2]${RESET} List all available emulators\n"
    if $has_xcode; then
      printf "  ${GREEN}[3]${RESET} Launch iOS Simulator\n"
    else
      printf "  ${DIM}[3]${RESET} Setup Xcode for iOS development\n"
    fi
    if $has_android; then
      printf "  ${GREEN}[4]${RESET} Launch Android Emulator\n"
      printf "  ${BLUE}[5]${RESET} Open Android Studio AVD Manager\n"
    else
      printf "  ${DIM}[4]${RESET} Setup Android Studio\n"
      printf "  ${DIM}[5]${RESET} Install Android Studio first\n"
    fi
    if [[ "$(uname -s)" == "Darwin" ]]; then
      if $has_xcode; then
        printf "  ${BLUE}[6]${RESET} Open Xcode Simulator\n"
      else
        printf "  ${DIM}[6]${RESET} Install Xcode first\n"
      fi
    fi
    printf "  ${DIM}[7]${RESET} Back to main menu\n\n"

    read -r -p "Select an option: " choice || true

    case "${choice}" in
      1)
        info "Launching ${APP_NAME} in Chrome"
        if (cd "${PROJECT_ROOT}" && flutter run -d chrome); then
          ok "Successfully launched in Chrome"
        else
          error "Failed to launch in Chrome"
        fi
        ;;
      2)
        list_emulators
        read -r -p "Press Enter to continue..." || true
        ;;
      3)
        if [[ "$(uname -s)" != "Darwin" ]]; then
          error "iOS Simulators are only available on macOS"
          continue
        fi
        if ! $has_xcode; then
          setup_xcode
          continue
        fi

        local sim_list=""
        local emu_json
        emu_json="$(flutter emulators --machine 2>/dev/null || echo "")"
        if command -v python3 >/dev/null 2>&1; then
          sim_list="$(RESTOCKR_JSON="${emu_json}" python3 - <<'PY'
import json, os
payload = os.environ.get("RESTOCKR_JSON", "").strip()
try:
    data = json.loads(payload) if payload else []
except Exception:
    data = []
for emu in data:
    if emu.get("platform") == "ios":
        print(f"{emu.get('name')} ({emu.get('id')})")
PY
)"
        else
          sim_list="$(flutter emulators 2>/dev/null | grep -i 'ios' || true)"
        fi

        if [[ -z "${sim_list// /}" ]]; then
          warn "No iOS simulators found."
          if ensure_ios_simulator; then
            ok "Created a default iOS simulator. Opening Simulator..."
            open_simulator_app || true
            continue
          fi
          printf "\n${BOLD}Let's create one:${RESET}\n"
          printf "  1. Open Simulator app (auto-creates a default simulator)\n"
          printf "  2. Launch Xcode and create a simulator manually\n"
          printf "  3. Cancel\n\n"
          read -r -p "Select option: " setup_choice || true
          case "${setup_choice}" in
            1)
              if open_simulator_app; then
                printf "\n${DIM}Once Simulator finishes booting, return here to launch the app.${RESET}\n"
              fi
              ;;
            2)
              info "Opening Xcode. Use Xcode ▸ Window ▸ Devices and Simulators to add one."
              open -a Xcode >/dev/null 2>&1 || warn "Unable to open Xcode automatically."
              ;;
            *)
              ;;
          esac
        else
          printf "\n${BOLD}Available iOS Simulators:${RESET}\n%s\n\n" "${sim_list}"
          read -r -p "Enter simulator ID (leave blank to just open Simulator app): " sim_id || true
          if [[ -z "${sim_id}" ]]; then
            open_simulator_app || true
          else
            info "Launching iOS Simulator: ${sim_id}"
            if flutter emulators --launch "${sim_id}"; then
              ok "Simulator launched. Use Developer Menu option [1] to run ${APP_NAME}."
            else
              error "Failed to launch simulator."
            fi
          fi
        fi
        ;;
      4)
        if ! $has_android; then
          setup_android_studio
          continue
        fi
        info "Looking for Android emulators..."
        local android_list=""
        local android_json
        android_json="$(flutter emulators --machine 2>/dev/null || echo "")"
        if command -v python3 >/dev/null 2>&1; then
          android_list="$(RESTOCKR_JSON="${android_json}" python3 - <<'PY'
import json, os
payload = os.environ.get("RESTOCKR_JSON", "").strip()
try:
    data = json.loads(payload) if payload else []
except Exception:
    data = []
for emu in data:
    if emu.get("platform") == "android":
        print(f"{emu.get('name')} ({emu.get('id')})")
PY
)"
        else
          android_list="$(flutter emulators 2>/dev/null | grep -i 'android' || true)"
        fi

        if [[ -z "${android_list// /}" ]]; then
          warn "No Android emulators found."
          if create_android_emulator; then
            continue
          fi
          printf "\n${BOLD}Create an Android Virtual Device (AVD):${RESET}\n"
          printf "  1. Open Android Studio Device Manager\n"
          printf "  2. Cancel\n\n"
          read -r -p "Choose: " android_choice || true
          if [[ "${android_choice}" == "1" ]]; then
            open -a "Android Studio" >/dev/null 2>&1 || warn "Unable to open Android Studio."
            info "In Android Studio: Tools ▸ Device Manager ▸ Create Device."
          fi
        else
          printf "\n${BOLD}Available Android Emulators:${RESET}\n%s\n\n" "${android_list}"
          read -r -p "Enter emulator ID to launch: " emu_id || true
          if [[ -n "${emu_id}" ]]; then
            info "Launching Android Emulator: ${emu_id}"
            if flutter emulators --launch "${emu_id}"; then
              ok "Emulator launched. Use Developer Menu option [1] to run ${APP_NAME}."
            else
              error "Failed to launch emulator."
            fi
          fi
        fi
        ;;
      5)
        if ! $has_android; then
          setup_android_studio
        else
          info "Opening Android Studio Device Manager"
          open -a "Android Studio" >/dev/null 2>&1 || warn "Unable to open Android Studio."
          printf "${DIM}Navigate to Tools ▸ Device Manager to manage virtual devices.${RESET}\n"
        fi
        ;;
      6)
        if [[ "$(uname -s)" != "Darwin" ]]; then
          error "Xcode is only available on macOS."
          continue
        fi
        if ! $has_xcode; then
          setup_xcode
          continue
        fi
        open_simulator_app || true
        ;;
      7|"")
        break
        ;;
      *)
        warn "Unknown option: ${choice}"
        ;;
    esac
  done
}

post_install_menu() {
  printf "\n${GREEN}${BOLD}════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   Setup Complete! What's Next?${RESET}\n"
  printf "${GREEN}${BOLD}════════════════════════════════════════${RESET}\n\n"

  printf "${BOLD}Quick Start Guide:${RESET}\n"
  printf "  ${DIM}1.${RESET} Start an emulator with option [2] below\n"
  printf "  ${DIM}2.${RESET} Launch RestockR with option [1] below\n"
  printf "  ${DIM}3.${RESET} Configure API keys in ${BLUE}env.json${RESET} when ready\n\n"

  while true; do
    printf "${BOLD}Developer Menu:${RESET}\n"
    printf "  ${GREEN}[1]${RESET} Launch ${APP_NAME}\n"
    printf "  ${GREEN}[2]${RESET} Emulator Launcher\n"
    printf "  ${BLUE}[3]${RESET} Show Flutter devices\n"
    printf "  ${BLUE}[4]${RESET} Run flutter doctor\n"
    printf "  ${YELLOW}[5]${RESET} Run flutter test\n"
    printf "  ${YELLOW}[6]${RESET} Run flutter analyze\n"
    printf "  ${DIM}[7]${RESET} Exit\n\n"
    read -r -p "Select an option: " choice || true
    case "${choice}" in
      1) run_flutter_run ;;
      2) launch_emulator_menu ;;
      3) run_flutter_devices ;;
      4) run_flutter_doctor ;;
      5) run_flutter_test ;;
      6) run_flutter_analyze ;;
      7|"")
        printf "\n${DIM}Thanks for using ${APP_NAME}! Run ./start.sh anytime.${RESET}\n"
        break
        ;;
      *) warn "Unknown option: ${choice}" ;;
    esac
  done
}

perform_install() {
  local mode="$1"

  ensure_structure
  ensure_env_file
  diagnose_dependencies

  if [[ "${mode}" == "reinstall" ]]; then
    reset_workspace
  fi

  run_pub_get
  mark_install
  ok "${APP_NAME} Dev Kit ready."
  auto_launch_default_environment || true
  post_install_menu
}

show_main_menu() {
  local has_install
  has_install=false

  if check_install_status; then
    has_install=true
    ok "Valid installation detected"
  fi

  printf "\n${BOLD}RestockR Dev Kit Menu:${RESET}\n"

  if $has_install; then
    printf "  ${GREEN}[1]${RESET} Launch Developer Menu (Skip Install)\n"
    printf "  ${GREEN}[2]${RESET} Emulator Launcher\n"
    printf "  ${BLUE}[3]${RESET} Install/Update Dependencies\n"
    printf "  ${YELLOW}[4]${RESET} Re-install RestockR Dev Kit\n"
    printf "  ${DIM}[5]${RESET} Exit\n\n"
  else
    printf "  ${GREEN}[1]${RESET} Install RestockR Dev Kit\n"
    printf "  ${DIM}[2]${RESET} Exit\n\n"
  fi
}

main() {
  cd "${PROJECT_ROOT}"
  print_header

  local choice has_install auto_launch_done=false
  while true; do
    has_install=false
    if check_install_status; then
      has_install=true
    fi

    if $has_install && [[ "${auto_launch_done}" == false ]]; then
      auto_launch_default_environment || true
      auto_launch_done=true
    fi

    show_main_menu
    read -r -p "Select an option: " choice || true

    if $has_install; then
      case "${choice}" in
        1)
          post_install_menu
          ;;
        2)
          launch_emulator_menu
          ;;
        3)
          info "Updating dependencies"
          run_pub_get
          ok "Dependencies updated"
          ;;
        4)
          perform_install "reinstall"
          auto_launch_done=true
          ;;
        5|"")
          break
          ;;
        *)
          warn "Unknown option: ${choice}"
          ;;
      esac
    else
      case "${choice}" in
        1)
          perform_install "install"
          auto_launch_done=true
          ;;
        2|"")
          break
          ;;
        *)
          warn "Unknown option: ${choice}"
          ;;
      esac
    fi
  done
}

main "$@"
