# InfernoX FPGA Vibration Monitoring

InfernoX is an FPGA-based automotive vibration-monitoring and fault-detection project. The current RTL implements an SPI interface for reading six accelerometer bytes from an MPU9250-compatible sensor and buffering the received bytes in a 64-byte FIFO.

## Repository structure

```text
rtl/
  fifo_buffer.v          64-byte receive FIFO
  spi_master.v           Parameterized 8-bit SPI master
  mpu9250_spi_burst.v    MPU9250 register-read controller
  mpu9250_top.v          Top-level integration module
docs/
  reports/               Project, filtering, communications, and RNN reports
  notes/                 Design and handwritten notes
```

## RTL hierarchy

`mpu9250_top` is the top-level module. It instantiates:

- `mpu9250_spi_burst`, which requests bytes through `spi_master`
- `fifo_buffer`, which stores received bytes for downstream logic

The default burst begins at register address `0x3B` (`ACCEL_XOUT_H`) and reads six bytes.

## Main interfaces

### Sensor-side SPI

- `sclk`: serial clock
- `mosi`: controller-to-sensor data
- `miso`: sensor-to-controller data
- `cs_n`: active-low chip select

### Application-side FIFO

- `start_burst`: starts an accelerometer read
- `fifo_rd_en`: advances the FIFO read pointer when data is available
- `fifo_data_out`: current FIFO byte
- `fifo_empty`: indicates that no unread data is available

All logic uses an active-low asynchronous reset named `rstn`.

## Compile check

With Icarus Verilog installed, run:

```sh
iverilog -g2012 -s mpu9250_top -o build/mpu9250.vvp rtl/*.v
```

Create the `build` directory first. No FPGA constraints file, board-specific project file, or automated testbench was present in the source archive, so hardware pin assignment and functional verification remain board-dependent.

## Documentation

The `docs` directory preserves the supplied reports and notes, including the testing and validation report, filtering material, SPI communications notes, MPU9250 notes, and the RNN research draft.

## Project status

This repository is an archival project package assembled from the available project files. Before deploying to hardware, verify SPI timing and chip-select behavior against the exact sensor datasheet and add a simulation testbench for the intended FPGA clock and board.
