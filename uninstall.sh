#!/usr/bin/env bash
# RestockR Uninstallation Script
# Completely removes RestockR Dev Kit and optionally dependencies

set -euo pipefail

# Source common utilities
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup_uninstall() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]] && [[ ${exit_code} -ne 130 ]]; then
    error "Uninstall interrupted (exit code: ${exit_code})"
    warn "Some files may not have been removed. Check manually if needed."
  fi
  log_plain "[INFO] uninstall.sh exiting"
}

# Register cleanup trap (only if running as main script, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  trap cleanup_uninstall EXIT INT TERM
fi

# ============================================================================
# CLEANUP FUNCTIONS
# ============================================================================

remove_build_artifacts() {
  info "Removing build artifacts..."

  local items_removed=0

  # Remove Flutter build artifacts
  if [[ -d "${PROJECT_ROOT}/.dart_tool" ]]; then
    rm -rf "${PROJECT_ROOT}/.dart_tool"
    debug "Removed .dart_tool/"
    items_removed=$((items_removed + 1))
  fi

  if [[ -d "${PROJECT_ROOT}/build" ]]; then
    rm -rf "${PROJECT_ROOT}/build"
    debug "Removed build/"
    items_removed=$((items_removed + 1))
  fi

  if [[ -f "${PROJECT_ROOT}/pubspec.lock" ]]; then
    rm -f "${PROJECT_ROOT}/pubspec.lock"
    debug "Removed pubspec.lock"
    items_removed=$((items_removed + 1))
  fi

  # Remove iOS build artifacts
  if [[ -d "${PROJECT_ROOT}/ios/Pods" ]]; then
    rm -rf "${PROJECT_ROOT}/ios/Pods"
    debug "Removed ios/Pods/"
    items_removed=$((items_removed + 1))
  fi

  if [[ -f "${PROJECT_ROOT}/ios/Podfile.lock" ]]; then
    rm -f "${PROJECT_ROOT}/ios/Podfile.lock"
    debug "Removed ios/Podfile.lock"
    items_removed=$((items_removed + 1))
  fi

  if [[ -d "${PROJECT_ROOT}/ios/.symlinks" ]]; then
    rm -rf "${PROJECT_ROOT}/ios/.symlinks"
    debug "Removed ios/.symlinks/"
    items_removed=$((items_removed + 1))
  fi

  # Remove Android build artifacts
  if [[ -d "${PROJECT_ROOT}/android/.gradle" ]]; then
    rm -rf "${PROJECT_ROOT}/android/.gradle"
    debug "Removed android/.gradle/"
    items_removed=$((items_removed + 1))
  fi

  if [[ -d "${PROJECT_ROOT}/android/app/build" ]]; then
    rm -rf "${PROJECT_ROOT}/android/app/build"
    debug "Removed android/app/build/"
    items_removed=$((items_removed + 1))
  fi

  if (( items_removed > 0 )); then
    ok "Removed ${items_removed} build artifact(s)"
  else
    info "No build artifacts found"
  fi
}

remove_devkit_markers() {
  info "Removing RestockR Dev Kit markers..."

  local items_removed=0

  if [[ -f "${DEVKIT_MARKER}" ]]; then
    rm -f "${DEVKIT_MARKER}"
    debug "Removed ${DEVKIT_MARKER}"
    items_removed=$((items_removed + 1))
  fi

  if [[ -d "${LOG_DIR}" ]]; then
    local log_count
    log_count=$(find "${LOG_DIR}" -type f 2>/dev/null | wc -l | tr -d ' ')
    rm -rf "${LOG_DIR}"
    debug "Removed ${LOG_DIR} (${log_count} log files)"
    items_removed=$((items_removed + 1))
  fi

  if (( items_removed > 0 )); then
    ok "Removed ${items_removed} Dev Kit marker(s)"
  else
    info "No Dev Kit markers found"
  fi
}

remove_env_file() {
  if [[ ! -f "${PROJECT_ROOT}/env.json" ]]; then
    debug "env.json not found, skipping"
    return 0
  fi

  warn "env.json contains your API keys and configuration"
  printf "${YELLOW}Remove env.json?${RESET} [y/N] "
  read -r resp || true
  resp="${resp,,}"

  if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
    rm -f "${PROJECT_ROOT}/env.json"
    ok "Removed env.json"
    return 0
  fi

  info "Keeping env.json"
}

offer_dependency_removal() {
  printf "\n${BOLD}Remove development dependencies?${RESET}\n\n"
  printf "RestockR Dev Kit uses the following tools:\n"
  printf "  • Flutter SDK\n"
  printf "  • CocoaPods (macOS only)\n"
  printf "  • Xcode Command Line Tools (macOS only)\n\n"

  warn "These tools may be used by other projects on your system"
  printf "${YELLOW}Remove development dependencies?${RESET} [y/N] "
  read -r resp || true
  resp="${resp,,}"

  if [[ "${resp}" != "y" && "${resp}" != "yes" ]]; then
    info "Keeping development dependencies"
    return 0
  fi

  # Offer to remove CocoaPods
  if [[ "$(uname -s)" == "Darwin" ]] && command -v pod >/dev/null 2>&1; then
    printf "\n${YELLOW}Remove CocoaPods?${RESET} [y/N] "
    read -r resp || true
    resp="${resp,,}"

    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      info "Removing CocoaPods..."
      if command -v brew >/dev/null 2>&1 && brew list cocoapods >/dev/null 2>&1; then
        if brew uninstall cocoapods 2>/dev/null; then
          ok "CocoaPods removed via Homebrew"
        else
          warn "Failed to remove CocoaPods via Homebrew"
        fi
      elif command -v gem >/dev/null 2>&1; then
        if sudo gem uninstall cocoapods 2>/dev/null; then
          ok "CocoaPods removed via RubyGems"
        else
          warn "Failed to remove CocoaPods via RubyGems"
        fi
      fi
    else
      info "Keeping CocoaPods"
    fi
  fi

  # Offer to remove Flutter
  if command -v flutter >/dev/null 2>&1; then
    printf "\n${YELLOW}Remove Flutter SDK?${RESET} [y/N] "
    read -r resp || true
    resp="${resp,,}"

    if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
      local flutter_path
      flutter_path="$(command -v flutter)"
      flutter_path="$(dirname "$(dirname "${flutter_path}")")"

      warn "⚠️  CRITICAL WARNING: This will remove Flutter SDK"
      warn "Location: ${flutter_path}"
      warn "This affects ALL Flutter projects on your system!"
      printf "\n${RED}${BOLD}Type 'DELETE FLUTTER' to confirm removal:${RESET} "
      read -r confirm || true

      if [[ "${confirm}" == "DELETE FLUTTER" ]]; then
        info "Removing Flutter SDK..."
        if rm -rf "${flutter_path}"; then
          ok "Flutter SDK removed"
          warn "You may need to update your shell profile (PATH) manually"
        else
          error "Failed to remove Flutter SDK (may require sudo)"
        fi
      else
        info "Flutter SDK removal cancelled (confirmation did not match)"
      fi
    else
      info "Keeping Flutter SDK"
    fi
  fi
}

# ============================================================================
# MAIN UNINSTALL WORKFLOW
# ============================================================================

perform_uninstall() {
  local mode="${1:-standard}"

  info "Starting ${APP_NAME} Dev Kit uninstallation"

  # Confirm uninstall intent
  warn "This will remove RestockR Dev Kit and all build artifacts"

  if [[ "${mode}" != "silent" ]]; then
    printf "${YELLOW}Are you sure you want to uninstall?${RESET} [y/N] "
    read -r resp || true
    resp="${resp,,}"

    if [[ "${resp}" != "y" && "${resp}" != "yes" ]]; then
      info "Uninstall cancelled"
      return 0
    fi
  fi

  # Step 1: Remove build artifacts
  remove_build_artifacts

  # Step 2: Remove Dev Kit markers
  remove_devkit_markers

  # Step 3: Optionally remove env.json
  if [[ "${mode}" != "silent" ]]; then
    remove_env_file
  fi

  ok "${APP_NAME} Dev Kit uninstalled successfully!"

  # Step 4: Offer to remove dependencies
  if [[ "${mode}" != "silent" ]]; then
    offer_dependency_removal
  fi

  # Final summary
  printf "\n${GREEN}${BOLD}════════════════════════════════════════${RESET}\n"
  printf "${GREEN}${BOLD}   Uninstallation Complete!${RESET}\n"
  printf "${GREEN}${BOLD}════════════════════════════════════════${RESET}\n\n"

  printf "${BOLD}What was removed:${RESET}\n"
  printf "  • Build artifacts (.dart_tool, build/, pubspec.lock)\n"
  printf "  • iOS artifacts (Pods/, Podfile.lock, .symlinks/)\n"
  printf "  • Android artifacts (.gradle/, app/build/)\n"
  printf "  • Dev Kit markers (.restockr_devkit, logs/)\n\n"

  if [[ -f "${PROJECT_ROOT}/env.json" ]]; then
    printf "${BOLD}What was kept:${RESET}\n"
    printf "  • env.json (API keys and configuration)\n"
    printf "  • Source code (lib/, assets/, etc.)\n\n"
  fi

  printf "${DIM}To reinstall: ./install.sh${RESET}\n\n"
}

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  print_header
  info "RestockR Dev Kit Uninstaller"
  info "Log file: ${LOG_FILE}"

  # Parse command line arguments
  local mode="standard"

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --yes|-y|--silent)
        mode="silent"
        shift
        ;;
      --help|-h)
        printf "\nUsage: $0 [OPTIONS]\n\n"
        printf "Options:\n"
        printf "  --yes, -y, --silent   Skip all confirmation prompts\n"
        printf "  --help, -h            Show this help message\n\n"
        printf "Examples:\n"
        printf "  $0                    Interactive uninstallation\n"
        printf "  $0 --yes              Silent uninstallation (no prompts)\n\n"
        exit 0
        ;;
      *)
        error "Unknown option: $1"
        printf "\nUsage: $0 [--yes] [--help]\n"
        printf "  --yes        Skip confirmation prompts\n"
        printf "  --help       Show help message\n"
        exit 1
        ;;
    esac
  done

  # Check if Dev Kit is installed
  if [[ ! -f "${DEVKIT_MARKER}" ]]; then
    warn "RestockR Dev Kit does not appear to be installed"

    # Check if there are any artifacts to clean
    if [[ -d "${PROJECT_ROOT}/.dart_tool" ]] || \
       [[ -d "${PROJECT_ROOT}/build" ]] || \
       [[ -d "${PROJECT_ROOT}/ios/Pods" ]]; then
      printf "${YELLOW}Found build artifacts. Clean them anyway?${RESET} [y/N] "
      read -r resp || true
      resp="${resp,,}"

      if [[ "${resp}" == "y" || "${resp}" == "yes" ]]; then
        remove_build_artifacts
        ok "Cleanup complete"
      else
        info "Cleanup cancelled"
      fi
    else
      info "No artifacts found. Nothing to do."
    fi

    exit 0
  fi

  # Run uninstallation
  perform_uninstall "${mode}"
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
