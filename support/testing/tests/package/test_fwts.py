import os

import infra.basetest


class TestFwts(infra.basetest.BRTest):
    config = \
        """
        BR2_aarch64=y
        BR2_neoverse_n1=y
        BR2_TOOLCHAIN_EXTERNAL=y
        BR2_TARGET_GENERIC_GETTY_PORT="ttyAMA0"
        BR2_TARGET_ROOTFS_EXT2=y
        BR2_TARGET_ROOTFS_EXT2_4=y
        # BR2_TARGET_ROOTFS_TAR is not set
        BR2_TARGET_ROOTFS_EXT2_SIZE="128M"
        BR2_ROOTFS_POST_IMAGE_SCRIPT="board/qemu/aarch64-sbsa/assemble-flash-images support/scripts/genimage.sh"
        BR2_ROOTFS_POST_SCRIPT_ARGS="-c board/qemu/aarch64-sbsa/genimage.cfg"
        BR2_LINUX_KERNEL=y
        BR2_LINUX_KERNEL_CUSTOM_VERSION=y
        BR2_LINUX_KERNEL_CUSTOM_VERSION_VALUE="6.6.28"
        BR2_LINUX_KERNEL_NEEDS_HOST_OPENSSL=y
        BR2_LINUX_KERNEL_USE_ARCH_DEFAULT_CONFIG=y
        BR2_TARGET_EDK2=y
        BR2_TARGET_EDK2_PLATFORM_QEMU_SBSA=y
        BR2_TARGET_GRUB2=y
        BR2_TARGET_GRUB2_ARM64_EFI=y
        BR2_TARGET_ARM_TRUSTED_FIRMWARE=y
        BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_VERSION=y
        BR2_TARGET_ARM_TRUSTED_FIRMWARE_CUSTOM_VERSION_VALUE="v2.12"
        BR2_TARGET_ARM_TRUSTED_FIRMWARE_PLATFORM="qemu_sbsa"
        BR2_TARGET_ARM_TRUSTED_FIRMWARE_FIP=y
        BR2_PACKAGE_FWTS=y
        BR2_PACKAGE_FWTS_EFI_RUNTIME_MODULE=y
        BR2_PACKAGE_HOST_GENIMAGE=y
        BR2_PACKAGE_HOST_DOSFSTOOLS=y
        BR2_PACKAGE_HOST_MTOOLS=y
        BR2_PACKAGE_HOST_QEMU=y
        BR2_PACKAGE_HOST_QEMU_SYSTEM_MODE=y
        """

    def __init__(self, names):
        """Setup common test variables."""
        super(TestFwts, self).__init__(names)
        """All EDK2 releases <= edk2-stable202408 can't be fetched from git
           anymore due to a missing git submodule as reported by [1].

           Usually Buildroot fall-back using https://sources.buildroot.net
           thanks to BR2_BACKUP_SITE where a backup of the generated archive
           is available. But the BRConfigTest remove BR2_BACKUP_SITE default
           value while generating the .config used by TestFwts.

           Replace the BR2_BACKUP_SITE override from BRConfigTest in order
           to continue testing EDK2 package using the usual backup site.

           To be removed with the next EDK2 version bump using this commit
           [2].

           [1] https://github.com/tianocore/edk2/issues/6398
           [2] https://github.com/tianocore/edk2/commit/95d8a1c255cfb8e063d679930d08ca6426eb5701
        """
        self.config = self.config.replace('BR2_BACKUP_SITE=""\n', '')

    def test_run(self):
        hda = os.path.join(self.builddir, "images", "disk.img")
        flash0 = os.path.join(self.builddir, "images", "SBSA_FLASH0.fd")
        flash1 = os.path.join(self.builddir, "images", "SBSA_FLASH1.fd")
        self.emulator.boot(arch="aarch64",
                           options=["-M", "sbsa-ref",
                                    "-cpu", "neoverse-n1",
                                    "-m", "512M",
                                    "-pflash", flash0,
                                    "-pflash", flash1,
                                    "-hda", hda])
        self.emulator.login()

        # Check the program can execute.
        self.assertRunOk("fwts --version")

        # We run a simple UEFI runtime service variable interface test
        # suite. Those tests are using the fwts efi_runtime kernel
        # module.
        self.assertRunOk("fwts -q uefirtvariable", timeout=30)

        # The previous fwts invocation is expected to have created a
        # "results.log" report. We check the file exists and contains
        # a known header string.
        expected_str = "Results generated by fwts:"
        cmd = f"grep -F '{expected_str}' results.log"
        out, ret = self.emulator.run(cmd)
        self.assertEqual(ret, 0)
        self.assertTrue(out[0].startswith(expected_str))
