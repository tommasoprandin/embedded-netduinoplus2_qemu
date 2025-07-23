## ARM STM32 Runtimes

### Runtimes Supported

- Light
- Light-Tasking
- Embedded

### Targets Supported
Cortex-M4 and Cortex-M7 MCUs

### System Clocks

#### Clocks Configuration

The system clock source is the main phase-locked loop (PLL) driven by an
external crystal. The frequency of the external crystal (HSE) is
specified in package System.BB.Board_Parameters (in the gnat directory as
file s-bbbopa.ads), as is the main clock frequency. For example:

```ada
   Main_Clock_Frequency : constant := 168_000_000;
   HSE_Clock_Frequency : constant := 8_000_000;
```

Change the values in that package to reflect your specific board, as
necessary. The runtime system uses them to configure the clocks so
changes will take effect automatically. Package System.BB.Parameters
(gnat/s-bbpara.ads) imports those values and re-exports them as constants
used by library procedure Setup_PLL. The shared procedure Setup_PLL
configures the PLL and the derived clocks to achieve that main clock
frequency. Compilation will fail if the requested clock frequency is not
achievable.

#### Clock Overdriving

Procedure Setup_PLL always attempts to enable clock overdriving by
calling procedure PWR_Overdrive_Enable declared in package
System.BB.MCU_Parameters. However, not all targets allow overdriving so
the corresponding procedure body is null in the sources for those
targets. Change the procedure body for your target accordingly.

### Startup Code

The Ravenscar runtime libraries use the SysTick interrupt to implement Ada
semantics for time, i.e., delay statements and package Ada.Real_Time. The
SysTick interrupt handler runs at highest priority. See procedure
Sys_Tick_Handler in package body System.BB.CPU_Primitives
(gnat/s-bbcppr.adb), which calls through to the handler in the trap vectors
only when necessary for the sake of efficiency.

The runtime libraries provide a minimal version of package Ada.Text_IO
supporting character- and string-based input and output routines. These are
implemented using a board-specific UART. You can change the UART selection
as well as the configuration (e.g., the baud rate). The source files are
located in the gnat directory in a package named System.Text_IO
(gnat/s-textio.adb).

### Notes
The checks on PLL and power initialization have been disabled as a workaround for sloppy QEMU emulation.

### Building

Create the user directories if missing:
```
mkdir gnat_user gnarl_user
```

First build the runtime:
```
alr exec -- gprbuild -P runtime_build.gpr
```
then the Ravenscar:
```
alr exec -- gprbuild -P ravenscar_build.gpr
```

If Alire complains of `origin missing` or similar, try first launching `alr build` (it will fail). Then retry again the two previous commands.