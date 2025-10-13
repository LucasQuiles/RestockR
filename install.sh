#!/usr/bin/env bash
# RestockR Installation Script
# Handles initial setup and dependency installation

set -euo pipefail

# Source common utilities and environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/envsetup.sh"

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup_install() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]] && [[ ${exit_code} -ne 130 ]]; then
    error "Installation interrupted (exit code: ${exit_code})"
    warn "You may need to run './install.sh --force' to retry"
  fi
  log_plain "[INFO] install.sh exiting"
}

# Register cleanup trap (only if running as main script, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  trap cleanup_install EXIT INT TERM
fi

# ============================================================================
# INSTALLATION STATE
# ============================================================================

IOS_PODS_READY=false

# ============================================================================
# FLUTTER COMMAND WRAPPERS
# ============================================================================

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
  if ! command -v flutter >/dev/null 2>&1; then
    suggest_flutter_not_found
    return 1
  fi
  info "Installing Flutter dependencies (flutter pub get)"
  if (cd "${PROJECT_ROOT}" && flutter pub get); then
    ok "Installing Flutter dependencies (flutter pub get) completed"
  else
    local exit_code=$?
    suggest_pub_get_failed "${exit_code}"
    return 1
  fi
}

run_flutter_devices() {
  run_flutter_command "Listing connected devices" flutter devices
}

run_flutter_doctor() {
  run_flutter_command "Running flutter doctor" flutter doctor
}

run_flutter_test() {
  run_flutter_command "Running flutter test" flutter test
}

run_flutter_analyze() {
  run_flutter_command "Running flutter analyze" flutter analyze
}

# ============================================================================
# IOS PROJECT PREPARATION
# ============================================================================

prepare_ios_project() {
  if ! ensure_cocoapods; then
    return 1
  fi

  if [[ "${IOS_PODS_READY}" == true ]]; then
    debug "iOS pods already prepared"
    return 0
  fi

  if [[ ! -d "${PROJECT_ROOT}/ios" ]]; then
    warn "iOS directory not found; skipping pod install."
    return 1
  fi

  info "Running pod install (ios/)"
  if (cd "${PROJECT_ROOT}/ios" && pod install >/dev/null 2>&1); then
    ok "pod install completed"
    IOS_PODS_READY=true
    return 0
  fi

  warn "pod install failed. Review CocoaPods setup."
  return 1
}

# ============================================================================
# WORKSPACE MANAGEMENT
# ============================================================================

reset_workspace() {
  warn "Resetting workspace (flutter clean, deleting artifacts)"
  if command -v flutter >/dev/null 2>&1; then
    run_flutter_clean || true
  fi
  rm -rf "${PROJECT_ROOT}/.dart_tool" "${PROJECT_ROOT}/build"
  rm -f "${PROJECT_ROOT}/pubspec.lock"
  ok "Workspace reset complete"
}

# ============================================================================
# INSTALLATION MARKERS
# ============================================================================

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

# ============================================================================
# MAIN INSTALLATION WORKFLOW
# ============================================================================

perform_install() {
  local mode="${1:-install}"

  info "Starting ${APP_NAME} Dev Kit installation"

  # Step 1: Validate project structure
  ensure_structure

  # Step 2: Ensure env.json exists
  ensure_env_file

  # Step 3: Check dependencies
  diagnose_dependencies

  # Step 4: Clean workspace if reinstalling
  if [[ "${mode}" == "reinstall" ]]; then
    reset_workspace
  fi

  # Step 5: Install Flutter dependencies
  run_pub_get

  # Step 6: Prepare iOS project if available
  if [[ "$(uname -s)" == "Darwin" ]] && [[ "${IOS_TOOLS_AVAILABLE}" == true ]]; then
    prepare_ios_project || warn "iOS project preparation incomplete"
  fi

  # Step 7: Mark installation complete
  mark_install

  ok "${APP_NAME} Dev Kit installation complete!"

  # Post-install summary
  printf "\n${GREEN}${BOLD}════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   Installation Complete!${RESET}\n"
  printf "${GREEN}${BOLD}════════════════════════════════════════${RESET}\n\n"

  printf "${BOLD}Next Steps:${RESET}\n"
  printf "  1. Run ${BLUE}./start.sh${RESET} to launch the app\n"
  printf "  2. Configure API keys in ${BLUE}env.json${RESET} when ready\n"
  printf "  3. Use ${BLUE}./emulators.sh${RESET} to manage devices\n\n"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  print_header
  info "RestockR Dev Kit Installer"
  info "Log file: ${LOG_FILE}"

  # Parse command line arguments
  local mode="install"
  local skip_prompts=false

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force|--reinstall)
        mode="reinstall"
        shift
        ;;
      --yes|-y)
        skip_prompts=true
        shift
        ;;
      *)
        error "Unknown option: $1"
        printf "\nUsage: $0 [--force] [--yes]\n"
        printf "  --force      Reinstall even if already installed\n"
        printf "  --yes        Skip confirmation prompts\n"
        exit 1
        ;;
    esac
  done

  # Check if already installed
  if check_install_status && [[ "${mode}" != "reinstall" ]]; then
    warn "RestockR Dev Kit is already installed"
    if [[ "${skip_prompts}" == false ]]; then
      read -r -p "Reinstall anyway? [y/N] " resp || true
      resp="${resp,,}"
      if [[ "${resp}" != "y" && "${resp}" != "yes" ]]; then
        info "Installation cancelled. Run ./start.sh to launch."
        exit 0
      fi
    fi
    mode="reinstall"
  fi

  # Run installation
  perform_install "${mode}"

  # Offer to launch
  if [[ "${skip_prompts}" == false ]]; then
    read -r -p "Launch ${APP_NAME} now? [Y/n] " resp || true
    resp="${resp,,}"
    if [[ -z "${resp}" || "${resp}" == "y" || "${resp}" == "yes" ]]; then
      exec "${SCRIPT_DIR}/start.sh"
    fi
  fi
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
