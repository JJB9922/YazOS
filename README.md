# YazOS Roadmap

- [x] Bootloader
  - Minimal bootloader (use GRUB)
  - Setup stage 1 kernel entry
    
- [ ] Basic I/O
  - Print to screen (framebuffer/VGA)
    
- [ ] Kernel Setup
  - Switch to long mode (64-bit)
  - Setup page tables (paging)
  - Initialize basic memory management

- [ ] Interrupts
  - Setup IDT (Interrupt Descriptor Table)
  - Handle basic hardware interrupts (keyboard, timer)

- [ ] Memory Management
  - Simple heap allocator
  - Basic virtual memory management

- [ ] Multitasking
  - Implement task switching (cooperative, then preemptive)
  - Setup process isolation (basic memory protection)

- [ ] File System
  - Simple filesystem driver (e.g., FAT32)
  - Read/write files

- [ ] Drivers
  - Basic hardware drivers (keyboard, storage)

- [ ] Shell
  - Basic command-line interface
  - Execute simple programs

- [ ] Networking (optional)
  - Basic TCP/IP stack
  - Simple networking application (ping)

- [ ] Debugging
  - Setup kernel debugging (serial output)

- [ ] Optimization
  - Profile and optimize boot time, memory usage
