#!/bin/bash
clone_if_missing() {
    local repo_url=$1
    local branch=$2
    local target_dir=$3
    if [ ! -d "$target_dir" ]; then
        echo "Cloning $target_dir..."
        if [ -n "$branch" ]; then
            git clone "$repo_url" -b "$branch" "$target_dir"
        else
            git clone "$repo_url" "$target_dir"
        fi
        echo "Done."
    fi
}

# Removes an existing repo checkout (e.g. one brought in by repo sync/manifest)
# and clones a replacement in its place.
replace_repo() {
    local repo_url=$1
    local branch=$2
    local target_dir=$3

    echo "Removing $target_dir..."
    rm -rf "$target_dir"

    echo "Cloning $target_dir from $repo_url ($branch)..."
    git clone "$repo_url" -b "$branch" "$target_dir"
    echo "Done."
}

# Git clones
clone_if_missing "git@github.com:project-moon-gazer/android_device_motorola_sm6375-common.git" "cnb-erof" "device/motorola/sm6375-common"
clone_if_missing "git@github.com:project-moon-gazer/proprietary_vendor_motorola_fogos.git" "cnb" "vendor/motorola/fogos"
clone_if_missing "git@github.com:project-moon-gazer/proprietary_vendor_motorola_sm6375-common.git" "cnb" "vendor/motorola/sm6375-common"
clone_if_missing "git@github.com:project-moon-gazer/android_kernel_motorola_sm6375.git" "Benihime" "kernel/motorola/sm6375"
# Additional repos
clone_if_missing "https://github.com/project-moon-gazer/vendor_motorola_camera.git" "main" "vendor/motorola/camera"
if [ -d "vendor/motorola/camera" ]; then
    (cd vendor/motorola/camera && git lfs pull)
fi
clone_if_missing "https://github.com/project-moon-gazer/android_hardware_motorola.git" "lineage-23.2" "hardware/motorola"
clone_if_missing "https://github.com/LineageOS/android_hardware_samsung_slsi_nfc.git" "" "hardware/samsung_slsi/nfc"
clone_if_missing "git@github.com:missrais/vendor_lunaris_dolby.git" "cnb" "vendor/lunaris/dolby"
clone_if_missing "git@github.com:missrais/keys.git" "main" "vendor/priv-keys/keys"
clone_if_missing "git@github.com:project-moon-gazer/vendor_revanced.git" "sixteen-qpr2" "vendor/revanced"

# Replace upstream LineageOS FM radio repo with my fork's fix (cnb branch)
replace_repo "https://github.com/missrais/android_vendor_qcom_opensource_fm-commonsys.git" "cnb" "vendor/qcom/opensource/commonsys/fm"

# Patch Qualcomm audio HAL: prevent combo device (speaker-and-headphones) flapping on incoming calls
echo "Applying Qualcomm audio HAL combo device flapping fix..."
python3 - << 'EOF'
import os
import re

def patch_audio_hw(fpath):
    try:
        with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception as e:
        return

    if "derive_playback_snd_device" not in content:
        return

    orig = content
    # Case when platform_split_snd_device fails (< 0):
    # SM6375 and shared WCD codec backends cannot split speaker-and-headphones into 2 backends.
    # Instead of falling back to d2 (single device), preserve the combo device!
    p1 = r'(if\s*\(ret\s*<\s*0\)\s*\{\s*if\s*\(ret\s*!=\s*-ENOSYS\)\s*\{\s*ALOGW\([^;]+;\s*\}\s*)ret\s*=\s*d2;\s*(goto\s+end;\s*\})'
    # Case when backends match:
    # Instead of unconditionally returning d2 (case 5), retain the combo device if already on combo (case 7).
    p2 = r'(if\s*\(platform_check_backends_match\(d3\[0\],\s*d3\[1\]\)\)\s*\{\s*)ret\s*=\s*d2;\s*(goto\s+end;\s*//\s*case\s*5)'

    repl = r'\1ret = (list_length(&a1) > 1 ? d1 : d2);\n            \2'
    content = re.sub(p1, repl, content)
    content = re.sub(p2, repl, content)

    if content != orig:
        with open(fpath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[audio_hw_patch] Successfully patched {fpath}")
    else:
        if "list_length(&a1) > 1 ? d1 : d2" in content and "failed to split snd_device" in content:
            print(f"[audio_hw_patch] {fpath} already patched")
        else:
            print(f"[audio_hw_patch] Pattern not found in {fpath}")

for base in ["hardware", "vendor"]:
    if os.path.exists(base):
        for root, dirs, files in os.walk(base):
            for file in files:
                if file == "audio_hw.c":
                    patch_audio_hw(os.path.join(root, file))
EOF
