#!/usr/bin/env bash
# RestockR Environment Setup & Validation
# Checks and configures development environment

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup_envsetup() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]] && [[ ${exit_code} -ne 130 ]]; then
    error "Environment setup interrupted (exit code: ${exit_code})"
  fi
  log_plain "[INFO] envsetup.sh exiting"
}

# Register cleanup trap (only if running as main script, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  trap cleanup_envsetup EXIT INT TERM
fi

# ============================================================================
# ENVIRONMENT STATE VARIABLES
# ============================================================================

IOS_TOOLS_AVAILABLE=false
IOS_TOOLS_CHECKED=false
COCOAPODS_AVAILABLE=false
COCOAPODS_CHECKED=false

# ============================================================================
# XCODE TOOLCHAIN FUNCTIONS
# ============================================================================

check_xcode_toolchain() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    debug "Non-macOS host; skipping Xcode toolchain check"
    return 0
  fi

  debug "Checking Xcode toolchain availability"
  local xcode_path
  xcode_path="$(xcode-select -p 2>/dev/null || true)"
  if [[ -z "${xcode_path}" ]]; then
    warn "Xcode Command Line Tools not detected. Install Xcode or run 'xcode-select --install'."
    log_plain "[ACTION] Install Xcode from the App Store or run 'xcode-select --install' to enable iOS simulators."
    if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
      read -r -p "Set developer directory to /Applications/Xcode.app/Contents/Developer now? [y/N] " resp || true
      resp="${resp,,}"
      if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
        info "Switching developer directory to Xcode.app"
        if sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer; then
          ok "Developer directory updated."
          xcode_path="/Applications/Xcode.app/Contents/Developer"
        else
          warn "Unable to switch developer directory automatically."
        fi
      fi
    else
      read -r -p "Open App Store to install Xcode? [y/N] " resp || true
      resp="${resp,,}"
      if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
        open "macappstore://apps.apple.com/app/xcode/id497799835" >/dev/null 2>&1 || warn "Unable to open App Store automatically."
      fi
    fi
  fi

  if [[ -z "${xcode_path}" ]]; then
    debug "check_xcode_toolchain: developer path unresolved"
    return 1
  fi

  debug "xcode-select path: ${xcode_path}"

  local simctl_check
  if ! simctl_check="$(xcrun simctl help 2>&1)"; then
    warn "xcrun simctl not available. Install full Xcode or point xcode-select to it."
    debug "xcrun simctl help output: ${simctl_check}"
    if [[ -d "/Applications/Xcode.app/Contents/Developer" && "${xcode_path}" != "/Applications/Xcode.app/Contents/Developer" ]]; then
      read -r -p "Switch developer directory to /Applications/Xcode.app/Contents/Developer now? [y/N] " resp || true
      resp="${resp,,}"
      if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
        info "Switching developer directory to Xcode.app"
        if sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer; then
          ok "Developer directory updated."
          if xcrun simctl help >/dev/null 2>&1; then
            debug "simctl available after switch"
            return 0
          fi
        else
          warn "Unable to switch developer directory automatically."
        fi
      fi
    else
      read -r -p "Open documentation on installing Xcode Command Line Tools? [y/N] " resp || true
      resp="${resp,,}"
      if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
        open "https://developer.apple.com/xcode/resources/" >/dev/null 2>&1 || true
      fi
    fi
    return 1
  fi

  debug "xcrun simctl is available"
  return 0
}

ensure_ios_toolchain_status() {
  if [[ "${IOS_TOOLS_CHECKED}" == true ]]; then
    debug "iOS toolchain status already checked: ${IOS_TOOLS_AVAILABLE}"
    if [[ "${IOS_TOOLS_AVAILABLE}" == true ]]; then
      return 0
    fi
    return 1
  fi

  if check_xcode_toolchain; then
    IOS_TOOLS_AVAILABLE=true
    IOS_TOOLS_CHECKED=true
    debug "iOS toolchain confirmed available"
    return 0
  fi

  IOS_TOOLS_AVAILABLE=false
  IOS_TOOLS_CHECKED=true
  debug "iOS toolchain not available"
  return 1
}

# ============================================================================
# PROJECT STRUCTURE VALIDATION
# ============================================================================

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
    return 1
  fi
  ok "Project structure looks good"
}

ensure_env_file() {
  info "Ensuring env.json exists"
  local env_file="${PROJECT_ROOT}/env.json"
  if [[ -f "${env_file}" ]]; then
    # Check and fix permissions on existing env.json
    local current_perms
    current_perms="$(stat -f "%Lp" "${env_file}" 2>/dev/null || stat -c "%a" "${env_file}" 2>/dev/null || echo "unknown")"
    if [[ "${current_perms}" != "600" ]] && [[ "${current_perms}" != "unknown" ]]; then
      warn "env.json has permissive permissions (${current_perms}), securing to 600"
      chmod 600 "${env_file}" || warn "Failed to set permissions on env.json"
    fi
    ok "env.json present"
    return
  fi
  warn "env.json missing; creating placeholder."
  cat > "${env_file}" <<'JSON'
{
  "RESTOCKR_ENV": "development",
  "RESTOCKR_API_BASE": "https://api.local.restockr.dev",
  "RESTOCKR_WS_URL": "wss://ws.local.restockr.dev/restocks",
  "SUPABASE_URL": "https://update-me.supabase.co",
  "SUPABASE_ANON_KEY": "replace-me",
  "AUTH_PROVIDER": "supabase",
  "AUTH_STORAGE_DRIVER": "secure_storage",
  "AUTH_REFRESH_INTERVAL_MIN": 45,
  "RESTOCKR_MONITOR_PAGE_SIZE": 25,
  "WATCHLIST_DEFAULT_SORT": "recent_activity",
  "WATCHLIST_MAX_ENTRIES": 100,
  "HISTORY_WINDOW_DAYS": 14,
  "HISTORY_PAGE_SIZE": 50,
  "FILTER_DEFAULTS_PROFILE": "standard",
  "NOTIFICATION_PROVIDER": "fcm",
  "PUSH_PUBLIC_KEY": "",
  "ANALYTICS_WRITE_KEY": "",
  "LOG_LEVEL": "info",
  "TRACE_SAMPLING_RATE": 0.1,
  "OPENAI_API_KEY": "replace-me",
  "GEMINI_API_KEY": "replace-me",
  "ANTHROPIC_API_KEY": "replace-me",
  "PERPLEXITY_API_KEY": "replace-me"
}
JSON

  # Set restrictive permissions (owner read/write only)
  chmod 600 "${env_file}" || warn "Failed to set permissions on env.json"
  ok "Created env.json with secure permissions (600)"
  warn "⚠️  SECURITY: Never commit env.json or share it publicly"
}

# ============================================================================
# DEPENDENCY INSTALLATION HELPERS
# ============================================================================

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

# ============================================================================
# COCOAPODS MANAGEMENT
# ============================================================================

detect_ruby_version() {
  if ! command -v ruby >/dev/null 2>&1; then
    return 1
  fi
  local raw
  raw="$(ruby --version 2>/dev/null | awk '{print $2}' || true)"
  if [[ -z "${raw}" ]]; then
    return 1
  fi
  raw="${raw%%p*}"
  printf "%s" "${raw}"
  return 0
}

refresh_cocoapods_status() {
  if command -v pod >/dev/null 2>&1; then
    local pod_version
    pod_version="$(pod --version 2>/dev/null || true)"
    COCOAPODS_AVAILABLE=true
    if [[ -n "${pod_version}" ]]; then
      debug "CocoaPods version ${pod_version} detected"
      log_plain "[OK] CocoaPods ${pod_version} detected"
    else
      debug "CocoaPods detected (version unavailable)"
      log_plain "[OK] CocoaPods detected"
    fi
    return 0
  fi
  COCOAPODS_AVAILABLE=false
  return 1
}

install_cocoapods_with_brew() {
  if ! command -v brew >/dev/null 2>&1; then
    return 1
  fi

  info "Attempting CocoaPods install via Homebrew (brew install cocoapods). This may take a few minutes."
  log_plain "[ACTION] brew install cocoapods"

  if brew list cocoapods >/dev/null 2>&1; then
    ok "CocoaPods already installed via Homebrew."
    return 0
  fi

  if brew install cocoapods; then
    ok "CocoaPods installed via Homebrew."
    return 0
  fi

  warn "Homebrew installation failed. Trying RubyGems next."
  return 1
}

install_cocoapods_with_gem() {
  if ! command -v gem >/dev/null 2>&1; then
    warn "RubyGems not found; install Xcode Command Line Tools or Ruby and retry."
    return 1
  fi

  local ruby_version gem_args status gem_log
  ruby_version="$(detect_ruby_version || true)"
  gem_args=(--no-document)
  gem_log="${LOG_DIR}/cocoapods_gem_install_${LOG_TIMESTAMP}.log"

  if [[ -n "${ruby_version}" ]]; then
    if version_ge "${ruby_version}" "3.1.0"; then
      info "Installing CocoaPods via RubyGems (latest release). This can take several minutes."
    else
      info "Installing CocoaPods via RubyGems (compatibility release for Ruby ${ruby_version})."
      gem_args+=(-v "1.15.2")
    fi
  else
    info "Installing CocoaPods via RubyGems (version auto-selected)."
  fi

  log_plain "[ACTION] sudo gem install cocoapods ${gem_args[*]}"

  if sudo gem install cocoapods "${gem_args[@]}" 2>&1 | tee -a "${gem_log}"; then
    ok "CocoaPods installed via RubyGems."
    return 0
  fi

  status=$?
  warn "RubyGems installation failed (exit ${status}). Inspect ${gem_log} for details."

  if [[ -f "${gem_log}" ]] && grep -q "securerandom requires Ruby version >= 3.1.0" "${gem_log}"; then
    warn "Detected securerandom compatibility issue with the bundled Ruby."
    info "Installing securerandom 0.3.2 and retrying CocoaPods installation."
    log_plain "[ACTION] sudo gem install securerandom -v 0.3.2 --no-document"
    if sudo gem install securerandom -v 0.3.2 --no-document 2>&1 | tee -a "${gem_log}"; then
      if sudo gem install cocoapods "${gem_args[@]}" 2>&1 | tee -a "${gem_log}"; then
        ok "CocoaPods installed via RubyGems after securerandom patch."
        return 0
      fi
    fi
    warn "Retry after installing securerandom failed."
  fi

  return 1
}

ensure_cocoapods() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 0
  fi

  if [[ "${COCOAPODS_CHECKED}" == true ]]; then
    debug "CocoaPods already checked: available=${COCOAPODS_AVAILABLE}"
    if [[ "${COCOAPODS_AVAILABLE}" == true ]]; then
      return 0
    fi
    if refresh_cocoapods_status; then
      ok "CocoaPods ready."
      COCOAPODS_CHECKED=true
      return 0
    fi
    return 1
  fi

  if refresh_cocoapods_status; then
    ok "CocoaPods ready."
    COCOAPODS_CHECKED=true
    return 0
  fi

  COCOAPODS_CHECKED=true

  warn "CocoaPods not installed. iOS plugins require CocoaPods."
  log_plain "[ACTION] Install CocoaPods via 'sudo gem install cocoapods' or Homebrew 'brew install cocoapods'."
  read -r -p "Attempt automatic CocoaPods repair now? [Y/n] " resp || true
  resp="${resp,,}"
  if [[ -z "${resp}" || "${resp}" == "y" || "${resp}" == "yes" ]]; then
    local install_success=false

    if install_cocoapods_with_brew; then
      install_success=true
    fi

    if [[ "${install_success}" == false ]]; then
      if install_cocoapods_with_gem; then
        install_success=true
      fi
    fi

    hash -r
    if refresh_cocoapods_status; then
      ok "CocoaPods ready."
      return 0
    fi

    if [[ "${install_success}" == true ]]; then
      warn "Installation steps completed but CocoaPods command not found on PATH."
      warn "Check that /usr/local/bin or the Homebrew prefix is in your shell PATH."
    else
      suggest_cocoapods_failed 1
    fi
  fi

  warn "CocoaPods is required to build iOS. Install it and re-run the launcher."
  COCOAPODS_AVAILABLE=false
  return 1
}

# ============================================================================
# COMPREHENSIVE ENVIRONMENT DIAGNOSIS
# ============================================================================

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
      suggest_flutter_version_mismatch "${version}" "${MIN_FLUTTER_VERSION}"
    fi
  else
    suggest_flutter_not_found
    exit 1
  fi

  # Quick Flutter doctor check
  info "Running Flutter self-check (flutter doctor --android-licenses skipped)"
  if flutter doctor 2>&1 | grep -q "Doctor found issues"; then
    warn "Flutter doctor found some issues. You may need to run 'flutter doctor' manually."
  else
    ok "Flutter self-check passed"
  fi

  if ensure_ios_toolchain_status; then
    debug "iOS toolchain available: simctl ready"
    ensure_cocoapods || true
  else
    warn "iOS tooling unavailable; automatic iOS simulator launch will be skipped until installed."
  fi
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  print_header
  info "Environment Setup & Validation"
  info "Log file: ${LOG_FILE}"

  # Parse command line arguments
  local check_only=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --check)
        check_only=true
        shift
        ;;
      *)
        error "Unknown option: $1"
        exit 1
        ;;
    esac
  done

  # Run environment checks
  ensure_structure
  ensure_env_file
  diagnose_dependencies

  if [[ "${check_only}" == false ]]; then
    info "Environment validation complete!"
    info "You can now run install.sh or start.sh"
  fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
