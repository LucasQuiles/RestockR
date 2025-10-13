#!/usr/bin/env bash
# RestockR Emulator & Device Management
# Handles iOS/Android emulator creation, launching, and management

set -euo pipefail

# Source common utilities and dependencies
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/envsetup.sh"
source "${SCRIPT_DIR}/install.sh"

# ============================================================================
# CLEANUP & SIGNAL HANDLING
# ============================================================================

cleanup_emulators() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]] && [[ ${exit_code} -ne 130 ]]; then
    error "Emulator management interrupted (exit code: ${exit_code})"
  fi
  log_plain "[INFO] emulators.sh exiting"
}

# Register cleanup trap (only if running as main script, not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  trap cleanup_emulators EXIT INT TERM
fi

# ============================================================================
# EMULATOR STATE VARIABLES
# ============================================================================

IOS_ACTIVE_DEVICE=""

# ============================================================================
# DEVICE LISTING & SUMMARY
# ============================================================================

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

# ============================================================================
# IOS SIMULATOR MANAGEMENT
# ============================================================================

open_simulator_app() {
  if ! command -v open >/dev/null 2>&1; then
    error "'open' command not found. Launch Simulator manually from Xcode."
    return 1
  fi

  # Try default Application bundle resolution first
  debug "Attempting to open Simulator via bundle lookup"
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
        debug "Attempting to open Simulator via path: ${sim_app}"
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
    debug "Attempting fallback Simulator path: ${fallback}"
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
  if command -v python3 >/dev/null 2>&1; then
    runtime_id="$(xcrun simctl list runtimes --json 2>/dev/null | python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
runtimes=[r for r in data.get("runtimes", []) if r.get("available") and (r.get("identifier") or "").startswith("com.apple.CoreSimulator.SimRuntime.iOS")]
if not runtimes:
    sys.exit(1)
runtimes.sort(key=lambda r: r.get("version") or r.get("identifier"), reverse=True)
sys.stdout.write(runtimes[0]["identifier"])')"
    device_id="$(xcrun simctl list devicetypes --json 2>/dev/null | python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
devices=[d for d in data.get("devicetypes", []) if "iPhone" in (d.get("name") or "")]
if not devices:
    sys.exit(1)
devices.sort(key=lambda d: d.get("name"))
sys.stdout.write(devices[-1]["identifier"])')"
  fi

  if [[ -z "${runtime_id}" ]]; then
    runtime_id="$(xcrun simctl list runtimes 2>/dev/null | awk -F'[() ]+' '/iOS/{for(i=1;i<=NF;i++){if($i~/com\.apple\.CoreSimulator\.SimRuntime\.iOS/){print $i; exit}}}')"
  fi
  if [[ -z "${device_id}" ]]; then
    device_id="$(xcrun simctl list devicetypes 2>/dev/null | awk -F'[()]+' '/iPhone/{print $2; exit}')"
  fi

  if [[ -z "${runtime_id}" || -z "${device_id}" ]]; then
    warn "Unable to determine iOS runtime or device type for simulator creation."
    return 1
  fi

  debug "create_ios_simulator resolved runtime_id=${runtime_id} device_id=${device_id}"

  local sim_name="RestockR iPhone $(date +%H%M%S)"
  info "Creating iOS simulator '${sim_name}'"
  local create_output
  if create_output="$(xcrun simctl create "${sim_name}" "${device_id}" "${runtime_id}" 2>&1)"; then
    ok "Created simulator '${sim_name}'."
    debug "simctl create output: ${create_output}"
    return 0
  fi

  local status=$?
  warn "Failed to create iOS simulator automatically (exit ${status})."
  debug "simctl create stderr: ${create_output}"
  return 1
}

ensure_ios_simulator() {
  timer_start "ensure_ios_simulator"

  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi
  if ! command -v xcrun >/dev/null 2>&1; then
    warn "xcrun (Xcode Command Line Tools) not found. Install Xcode or run 'xcode-select --install'."
    debug "ensure_ios_simulator exiting because xcrun missing"
    return 1
  fi

  # Check if any iOS runtimes are available
  timer_start "check_runtimes"
  local runtime_count
  runtime_count=$(xcrun simctl list runtimes 2>/dev/null | grep "iOS" | wc -l | tr -d ' ')

  if [[ "${runtime_count}" == "0" ]]; then
    timer_end "check_runtimes" "Runtime check"
    error "No iOS simulator runtimes are installed"
    printf "\n${BOLD}${RED}iOS Simulator Runtime Missing${RESET}\n\n"
    printf "The iOS simulator cannot run without an iOS runtime.\n\n"
    printf "${BOLD}How to install:${RESET}\n"
    printf "  ${BOLD}Option 1 (Automatic):${RESET}\n"
    printf "    • Run: ${BOLD}xcodebuild -downloadPlatform iOS${RESET}\n"
    printf "    • This will download and install the latest iOS runtime (~5-10 GB)\n\n"
    printf "  ${BOLD}Option 2 (Manual):${RESET}\n"
    printf "    1. Open Xcode\n"
    printf "    2. Go to: ${BOLD}Xcode → Settings → Platforms${RESET}\n"
    printf "    3. Click the ${BOLD}+ (Get)${RESET} button next to an iOS version\n"
    printf "    4. Wait for download and installation to complete\n\n"

    # Offer to run automatic installation
    local resp
    read -r -p "${BOLD}Download iOS runtime automatically now?${RESET} [Y/n] " resp || true
    resp="${resp,,}"
    if [[ -z "${resp}" || "${resp}" == "y" || "${resp}" == "yes" ]]; then
      info "Starting iOS runtime download (this may take 10-30 minutes depending on your connection)..."
      printf "\n${YELLOW}Note: This will download 5-10 GB. You can monitor progress in a separate terminal with:${RESET}\n"
      printf "  ${BOLD}tail -f ~/Library/Logs/com.apple.dt.Xcode/CoreSimulator.log${RESET}\n\n"

      timer_start "runtime_download"
      if xcodebuild -downloadPlatform iOS 2>&1 | tee >(cat >&2); then
        timer_end "runtime_download" "iOS runtime download"
        ok "iOS runtime installation completed successfully!"

        # Verify the runtime was installed
        local new_runtime_count
        new_runtime_count=$(xcrun simctl list runtimes 2>/dev/null | grep "iOS" | wc -l | tr -d ' ')
        if [[ "${new_runtime_count}" -gt 0 ]]; then
          ok "Verified: ${new_runtime_count} iOS runtime(s) now available"
          info "Continuing with simulator setup..."
          # Don't return, let the function continue to create/boot simulator
        else
          warn "Runtime installation completed but no runtimes detected yet"
          info "Try running the script again, or install manually via Xcode Settings → Platforms"
          return 1
        fi
      else
        timer_end "runtime_download" "iOS runtime download (failed)"
        error "Failed to download iOS runtime automatically"
        printf "\n${YELLOW}Please try one of these alternatives:${RESET}\n"
        printf "  1. Run the command manually: ${BOLD}xcodebuild -downloadPlatform iOS${RESET}\n"
        printf "  2. Use Xcode GUI: ${BOLD}Xcode → Settings → Platforms${RESET}\n"
        printf "  3. Check your internet connection and available disk space (~10 GB needed)\n\n"
        return 1
      fi
    else
      info "Skipping automatic download. You can install manually later."
      printf "\n${YELLOW}When ready, install the iOS runtime using either:${RESET}\n"
      printf "  • Command: ${BOLD}xcodebuild -downloadPlatform iOS${RESET}\n"
      printf "  • Xcode GUI: ${BOLD}Xcode → Settings → Platforms${RESET}\n\n"
      return 1
    fi
  fi
  timer_end "check_runtimes" "Runtime check (found ${runtime_count} iOS runtimes)"

  timer_start "find_simulator"
  local device_id=""

  if command -v python3 >/dev/null 2>&1; then
    device_id="$(xcrun simctl list devices --json 2>/dev/null | python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
for runtime in data.get("devices", {}).values():
    for dev in runtime:
        if dev.get("isAvailable", False) or "available" in str(dev.get("availability", "")).lower():
            name=dev.get("name") or ""
            if "iPhone" in name:
                sys.stdout.write(dev.get("udid", ""))
                raise SystemExit
')"
  fi

  if [[ -z "${device_id}" ]]; then
    # Fallback: try to find any iPhone device even if marked unavailable
    device_id="$(xcrun simctl list devices 2>/dev/null | grep -i "iPhone" | grep -v "unavailable" | awk -F '[() ]+' '{print $(NF-1); exit}')"
  fi

  if [[ -z "${device_id}" ]]; then
    timer_end "find_simulator" "Simulator search"
    debug "No existing iPhone simulators detected; attempting to create one"
    timer_start "create_simulator"
    if ! create_ios_simulator; then
      return 1
    fi
    timer_end "create_simulator" "Simulator creation"

    sleep 1
    if command -v python3 >/dev/null 2>&1; then
      device_id="$(xcrun simctl list devices --json 2>/dev/null | python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    data={}
for runtime in data.get("devices", {}).values():
    for dev in runtime:
        if dev.get("availability", "(available)").endswith("(available)") or dev.get("isAvailable"):
            name=dev.get("name") or ""
            if "iPhone" in name:
                sys.stdout.write(dev.get("udid", ""))
                raise SystemExit
')"
    fi
  else
    timer_end "find_simulator" "Simulator search"
  fi

  if [[ -z "${device_id}" ]]; then
    warn "Unable to locate an iPhone simulator after creation."
    return 1
  fi

  debug "ensure_ios_simulator using device ${device_id}"

  # Check if already booted using simctl list
  timer_start "check_boot_status"
  local boot_state
  boot_state=$(xcrun simctl list devices | grep "${device_id}" | grep -o "([^)]*)" | tail -1 | tr -d '()' || echo "Shutdown")

  if [[ "${boot_state}" == "Booted" ]]; then
    timer_end "check_boot_status" "Boot status check"
    ok "Simulator ${device_id} already booted"
    IOS_ACTIVE_DEVICE="${device_id}"
    timer_end "ensure_ios_simulator" "iOS simulator preparation"
    return 0
  fi
  timer_end "check_boot_status" "Boot status check"

  # Simulator needs to boot - start it
  timer_start "boot_simulator"
  info "Simulator state: ${boot_state}, initiating boot..."

  # Try to boot the simulator
  if ! xcrun simctl boot "${device_id}" 2>&1 | grep -qv "Unable to boot device in current state: Booted"; then
    debug "Boot command executed for ${device_id}"
  fi

  # Wait for boot completion with polling instead of bootstatus -b
  info "Waiting for simulator to boot (typically 30-90 seconds)..."

  local max_wait=120
  local elapsed=0
  local check_interval=2

  if type spinner >/dev/null 2>&1; then
    spinner "Booting simulator..." 120 &
    local spinner_pid=$!
  fi

  while (( elapsed < max_wait )); do
    boot_state=$(xcrun simctl list devices | grep "${device_id}" | grep -o "([^)]*)" | tail -1 | tr -d '()' || echo "Shutdown")

    if [[ "${boot_state}" == "Booted" ]]; then
      if [[ -n "${spinner_pid:-}" ]]; then
        kill "${spinner_pid}" 2>/dev/null || true
        wait "${spinner_pid}" 2>/dev/null || true
        printf "\r\033[K"  # Clear spinner line
      fi
      timer_end "boot_simulator" "Simulator boot"
      ok "Simulator booted successfully (state: ${boot_state})"
      IOS_ACTIVE_DEVICE="${device_id}"
      timer_end "ensure_ios_simulator" "iOS simulator preparation"
      return 0
    fi

    sleep "${check_interval}"
    elapsed=$((elapsed + check_interval))

    # Log progress every 10 seconds
    if (( elapsed % 10 == 0 )); then
      debug "Simulator boot progress: ${elapsed}s elapsed, state: ${boot_state}"
    fi
  done

  # Timeout reached
  if [[ -n "${spinner_pid:-}" ]]; then
    kill "${spinner_pid}" 2>/dev/null || true
    wait "${spinner_pid}" 2>/dev/null || true
    printf "\r\033[K"  # Clear spinner line
  fi

  timer_end "boot_simulator" "Simulator boot (timed out)"
  warn "Simulator boot timed out after ${max_wait}s (last state: ${boot_state})"

  # Continue anyway as it might still be booting
  IOS_ACTIVE_DEVICE="${device_id}"
  timer_end "ensure_ios_simulator" "iOS simulator preparation"
  return 0
}

# ============================================================================
# ANDROID EMULATOR MANAGEMENT
# ============================================================================

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
  local create_output
  if create_output="$(flutter emulators --create --name "${name}" --device pixel 2>&1)"; then
    ok "Created Android emulator '${name}'."
    debug "flutter emulators --create output: ${create_output}"
    return 0
  fi

  local status=$?
  warn "Failed to auto-create Android emulator (exit ${status})."
  debug "flutter emulators --create stderr: ${create_output}"
  return 1
}

# ============================================================================
# DEVICE DETECTION & WAITING
# ============================================================================

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
        debug "Detected ${platform} device ${device_id} after $((i+1)) attempts"
        echo "${device_id}"
        return 0
      fi
    fi
    if (( (i + 1) % 5 == 0 )); then
      debug "Waiting for ${platform} device... attempt $((i+1))/${attempts}"
    fi
    sleep "${delay}"
  done
  debug "No ${platform} device detected after ${attempts} attempts"
  return 1
}

# ============================================================================
# PLATFORM LAUNCH WORKFLOWS
# ============================================================================

launch_ios_environment() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    return 1
  fi
  if ! command -v xcodebuild >/dev/null 2>&1; then
    return 1
  fi

  if ensure_ios_simulator; then
    debug "ensure_ios_simulator succeeded"
  else
    debug "ensure_ios_simulator failed"
  fi

  if open_simulator_app; then
    debug "open_simulator_app invocation succeeded"
  else
    debug "open_simulator_app invocation failed"
  fi

  local device_id="${IOS_ACTIVE_DEVICE}"
  if [[ -z "${device_id}" ]]; then
    info "Waiting for iOS simulator to boot..."
    if ! device_id="$(wait_for_device "ios" 60 2)"; then
      warn "No iOS simulator detected after waiting."
      return 1
    fi
  else
    debug "Using cached iOS simulator device ${device_id}"
  fi

  IOS_ACTIVE_DEVICE="${device_id}"
  debug "Found iOS simulator device ${device_id}"

  # Validate device ID before using it
  if ! device_id="$(validate_device_id "${device_id}")"; then
    error "Invalid device ID detected. Aborting launch for security."
    return 1
  fi

  if ! prepare_ios_project; then
    warn "iOS project not fully prepared (CocoaPods missing?)."
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

  debug "Found Android emulator device ${device_id}"

  # Validate device ID before using it
  if ! device_id="$(validate_device_id "${device_id}")"; then
    error "Invalid device ID detected. Aborting launch for security."
    return 1
  fi

  info "Launching ${APP_NAME} on Android emulator (${device_id})"
  run_flutter_run -d "${device_id}"
  return 0
}

auto_launch_default_environment() {
  info "Preparing development environment (autostart)"
  log_plain "[INFO] Log file: ${LOG_FILE}"

  if [[ "${IOS_TOOLS_AVAILABLE}" == true ]]; then
    if [[ "${COCOAPODS_AVAILABLE}" == true ]]; then
      if launch_ios_environment; then
        return 0
      fi
    else
      warn "CocoaPods missing; unable to auto-launch iOS. Run install.sh to install dependencies."
      log_plain "[WARN] Autostart aborted: CocoaPods unavailable."
      return 1
    fi
  else
    debug "Skipping iOS autolaunch; IOS_TOOLS_AVAILABLE=${IOS_TOOLS_AVAILABLE}"
  fi

  if launch_android_environment; then
    return 0
  fi

  warn "Falling back to Chrome (web)"
  debug "Launching Chrome because native targets were unavailable"
  run_flutter_run -d chrome
}

# ============================================================================
# SETUP WIZARDS
# ============================================================================

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

# ============================================================================
# INTERACTIVE EMULATOR MENU
# ============================================================================

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

        if [[ "${IOS_TOOLS_AVAILABLE}" != true ]]; then
          if check_xcode_toolchain; then
            IOS_TOOLS_AVAILABLE=true
            debug "iOS toolchain became available via emulator menu"
          else
            IOS_TOOLS_AVAILABLE=false
            warn "iOS tooling still unavailable. Install Xcode and re-run."
            continue
          fi
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

          # Sanitize user input
          sim_id="$(sanitize_input "${sim_id}")"

          if [[ -z "${sim_id}" ]]; then
            open_simulator_app || true
          else
            # Validate simulator ID
            if ! sim_id="$(validate_device_id "${sim_id}")"; then
              error "Invalid simulator ID format. Please try again."
              continue
            fi

            info "Launching iOS Simulator: ${sim_id}"
            if flutter emulators --launch "${sim_id}"; then
              ok "Simulator launched. Use start.sh to run ${APP_NAME}."
            else
              suggest_simulator_not_found
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

          # Sanitize user input
          emu_id="$(sanitize_input "${emu_id}")"

          if [[ -n "${emu_id}" ]]; then
            # Validate emulator ID
            if ! emu_id="$(validate_device_id "${emu_id}")"; then
              error "Invalid emulator ID format. Please try again."
              continue
            fi

            info "Launching Android Emulator: ${emu_id}"
            if flutter emulators --launch "${emu_id}"; then
              ok "Emulator launched. Use start.sh to run ${APP_NAME}."
            else
              suggest_emulator_launch_failed "${emu_id}"
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

# ============================================================================
# MAIN EXECUTION
# ============================================================================

main() {
  print_header
  info "Emulator & Device Management"
  info "Log file: ${LOG_FILE}"

  # Check if Flutter is installed
  if ! command -v flutter >/dev/null 2>&1; then
    error "Flutter not found. Run ./install.sh first."
    exit 1
  fi

  # Run emulator menu
  launch_emulator_menu
}

# Only run main if script is executed directly (not sourced)
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
