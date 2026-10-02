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
clone_if_missing "https://github.com/project-moon-gazer/android_device_motorola_sm6375-common.git" "vos" "device/motorola/sm6375-common"
clone_if_missing "https://github.com/project-moon-gazer/proprietary_vendor_motorola_fogos.git" "cnb" "vendor/motorola/fogos"
clone_if_missing "https://github.com/project-moon-gazer/proprietary_vendor_motorola_sm6375-common.git" "cnb" "vendor/motorola/sm6375-common"
clone_if_missing "https://github.com/project-moon-gazer/android_kernel_motorola_sm6375.git" "Benihime" "kernel/motorola/sm6375"
# Additional repos
clone_if_missing "https://github.com/project-moon-gazer/android_hardware_motorola.git" "lineage-23.2" "hardware/motorola"
clone_if_missing "https://github.com/LineageOS/android_hardware_samsung_slsi_nfc.git" "" "hardware/samsung_slsi/nfc"

# Replace upstream LineageOS FM radio repo with my fork's fix (cnb branch)
replace_repo "https://github.com/missrais/android_vendor_qcom_opensource_fm-commonsys.git" "cnb" "vendor/qcom/opensource/commonsys/fm"
