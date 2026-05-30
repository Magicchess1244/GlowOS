# GlowOS

---

## How to Install and Run

### Prerequisites

Before running GlowOS, ensure you have the following installed on your system:

- **Rust**: You will need the Nightly toolchain and the `llvm-tools-preview` component for kernel development.
- **QEMU**: The emulator used to run the OS.
- **Bash**: A Unix-like shell to execute the startup script.

### Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Magicchess1244/GlowOS.git
   cd GlowOS
   ```

2. **Configure the Rust toolchain:**
   Make sure you are using the nightly channel and have the required components installed:
   ```bash
   rustup override set nightly
   rustup component add llvm-tools-preview
   ```

3. **Run the OS:**
   Execute the provided bash script to compile the kernel and launch it inside a QEMU virtual machine:
   ```bash
   cargo run
   ```

---

## Technical Details

*(Coming soon)*

---

## Todo

- [ ] Improve and make a somewhat finished README
- [ ] Merge linked list
- [ ] Add more commands to terminal
- [ ] Scroll up and down → No clear line when chars reach it
- [ ] Add a history of commands and access it with arrow keys
- [ ] Add a way to insert letters in the middle of words without erasing them
- [ ] File system
- [ ] Read and write to USB
- [ ] Add a config file for visuals
- [ ] Add userspace

---

## License

This project is licensed under the **MIT License**.
See the `LICENSE` file for more details.

---

## Contributing

Contributions, ideas, and optimizations are welcome!
Feel free to open issues or submit pull requests.