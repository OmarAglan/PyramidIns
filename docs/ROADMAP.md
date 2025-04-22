# Roadmap for Pyramid Installer (PyramidIns)

This project aims to create a bootable installer environment (CD/ISO) capable of deploying the Pyramid Bootloader (`PyramidBL`) onto a target hard drive's Master Boot Record (MBR).

## Phase 0: Project Setup & Foundation (Target: Initial Structure)

- [x] Create the core directory structure (`src`, `build`, `docs`, `assets`).
- [x] Set up basic `README.md`, `LICENSE`, and `.gitignore`.
- [x] Create placeholder source files (`kmain.c`, `installer/main.c`, etc.).
- [ ] Define initial build script (`build.ps1` or `Makefile`) placeholders.
    - [ ] Goal: Assemble a basic kernel stub and link it.
    - [ ] Goal: Create a *very* basic bootable ISO structure (even if non-functional initially).
- [ ] Implement a minimal boot sector/loader on the ISO capable of loading and jumping to `kmain.c` (could initially borrow from `PyramidBL` Stage 1/2 concepts, but simplified to just load the kernel).

## Phase 1: Minimal Kernel - Basic I/O (Target: Interaction)

- [ ] Implement basic console output functions (`src/kernel/console.c`).
    - [ ] Direct video memory access or BIOS teletype.
    - [ ] Functions for printing characters, strings, numbers.
- [ ] Implement basic keyboard input (`src/kernel/kbd.c`).
    - [ ] Using BIOS INT 16h functions.
    *   [ ] Function to get a single character.
- [ ] Integrate console and keyboard into `kmain.c` for basic "Hello World" and echo test.
- [ ] Refine build script to compile and link kernel C code.

## Phase 2: Essential Drivers (Target: Accessing Data)

- [ ] **Disk I/O Driver (`src/drivers/bios_disk.c`)**
    - [ ] Implement wrappers for BIOS INT 13h functions:
        - [ ] `AH=08h` or `AH=15h`: Detect available hard drives.
        - [ ] `AH=02h`: Read sectors.
        - [ ] `AH=03h`: Write sectors (Implement with extreme caution!).
    - [ ] Add error handling for BIOS calls.
- [ ] **ISO9660 Filesystem Driver (`src/drivers/iso9660.c`)**
    - [ ] Research ISO9660 structure (Primary Volume Descriptor, Path Tables, File Entries).
    - [ ] Implement functions to:
        - [ ] Find the Primary Volume Descriptor on the CD (usually Sector 16).
        - [ ] Locate and parse the Path Table.
        *   [ ] Find a specific file (e.g., `/assets/stage1.bin`) by path.
        - [ ] Read the contents of a file from the CD using the Disk I/O driver.
    - [ ] This driver only needs *read* capability from the boot CD.

## Phase 3: Installer Application (Target: Core Logic)

- [ ] **Installer UI (`src/installer/ui.c`)**
    - [ ] Implement simple text-based UI functions:
        - [ ] Displaying menus/prompts.
        - [ ] Getting user confirmation (Yes/No).
        - [ ] Selecting from a list (e.g., detected disks).
- [ ] **Disk Detection & Selection (`src/installer/disk.c`)**
    - [ ] Use the Disk I/O driver to list detected hard drives.
    - [ ] Use the UI functions to present the list to the user for selection.
- [ ] **Installation Logic (`src/installer/install.c`)**
    - [ ] Function to read `stage1.bin` and `stage2.bin` from the CD using the ISO9660 driver.
    - [ ] Function to write `stage1.bin` (512 bytes) to the MBR (Sector 0) of the *selected* hard drive using the Disk I/O driver.
    - [ ] Function to write `stage2.bin` to the sectors *immediately following* the MBR on the selected hard drive.
- [ ] **Main Installer Flow (`src/installer/main.c`)**
    - [ ] Integrate UI, disk selection, and installation logic.
    *   [ ] Welcome screen.
    *   [ ] Disk detection and selection prompt.
    *   [ ] **CRITICAL:** Display strong warnings about overwriting MBR and data loss potential. Require explicit user confirmation.
    *   [ ] Perform installation steps (read from CD, write to HDD).
    *   [ ] Display success or failure message.
    *   [ ] Prompt for reboot.

## Phase 4: Integration & Packaging (Target: Bootable ISO)

- [ ] Copy final `stage1.bin` and `stage2.bin` from the `PyramidBL` project into the `assets/` directory.
- [ ] Refine the build script (`build.ps1` / `Makefile`):
    - [ ] Compile kernel, drivers, installer application.
    - [ ] Link everything into a single executable kernel/installer binary.
    - [ ] Use a tool like `mkisofs` or similar to create the final bootable `PyramidInstaller.iso`.
        - [ ] Configure it to use the minimal boot sector/loader from Phase 0.
        - [ ] Include the compiled kernel/installer binary.
        - [ ] Include the `assets/` directory containing `stage1.bin` and `stage2.bin`.
- [ ] Ensure the installer correctly locates and reads files from the ISO path (e.g., `/assets/stage1.bin`).

## Phase 5: Testing & Refinement (Target: Reliability)

- [ ] Test extensively in an emulator (QEMU) with virtual hard disks.
    - [ ] Test disk detection.
    - [ ] Test installation to a blank virtual disk.
    - [ ] Test booting from the virtual disk after installation.
    - [ ] Test error conditions (disk not found, read/write errors, user cancellation).
- [ ] (Optional, Risky) Test on non-critical physical hardware if possible.
- [ ] Refine UI messages, especially warnings.
- [ ] Add comments and improve documentation (`README.md`).
- [ ] Finalize build process. 