# SNN-100-Hardware-Accelerator
An ultra-low-power, 100-neuron hardware inference engine designed in Verilog for always-on edge sensor fusion. Prototyped on a Xilinx Artix-7 FPGA, this RTL architecture utilizes a time-multiplexed datapath to classify 3-axis data, consuming just 94mW and under 1% logic area

<div align="center">
  <h1>🧠 EdgeSNN-100: Ultra-Low-Power 100-Neuron Inference Engine</h1>
  <p><strong>A Time-Multiplexed Hardware Neural Network for Edge Sensor Fusion, prototyped on Xilinx Artix-7 silicon.</strong></p>

  <img src="https://img.shields.io/badge/Domain-Edge%20AI%20%7C%20Sensor%20Fusion-purple?style=for-the-badge" alt="Domain"/>
  <img src="https://img.shields.io/badge/Architecture-Time--Multiplexed%20Datapath-blue?style=for-the-badge" alt="Architecture"/>
  <img src="https://img.shields.io/badge/PPA-162%20LUTs%20%7C%2094mW-brightgreen?style=for-the-badge" alt="PPA"/>
  <img src="https://img.shields.io/badge/Tech-RTL%20%7C%20Verilog%20HDL-orange?style=for-the-badge" alt="Tech"/>
</div>

---

## 🛑 The Silicon Challenge: Always-On Sensor Processing
In modern battery-powered IoT and wearable devices, continuously monitoring 3-channel sensor data (such as X, Y, Z accelerometer vibration or RGB color thresholds) using a standard microcontroller drains battery life exponentially. The semiconductor industry requires **"Always-On" Hardware Accelerators** that can sit directly next to the sensor, process the data, and wake up the main CPU only when a specific pattern is detected. 

However, mapping a 100-neuron network into physical hardware typically consumes massive amounts of silicon Area (LUTs/DSPs) and static power.

## 💡 The Hardware Solution
**EdgeSNN-100** solves this bottleneck. It is a custom **RTL (Register Transfer Level)** hardware neural network designed to ingest 3 parallel data inputs, process them through a **100-Neuron Hidden Layer**, and output a classification confidence score using a **Population Spike Count** mechanism. 

To achieve extreme physical efficiency, this design abandons traditional spatial unrolling. Instead, it utilizes a **Time-Multiplexed Micro-architecture**, sharing a single physical Multiply-Accumulate (MAC) core across 100 virtual neurons. 

## 🏆 Key PPA Achievements (Power, Performance, Area)
This architecture was successfully synthesized, implemented, and validated on physical silicon (Digilent Basys 3). The post-implementation analytics demonstrate extreme hardware efficiency:

* 📉 **Area (<1% Device Utilization):** By time-multiplexing the datapath, the entire 100-neuron network consumes only **162 LUTs and 53 Registers**. It requires **Zero DSP Slices**.
* 🔋 **Power (94 mW Total):** The minimal silicon footprint limits static leakage, resulting in an ultra-low dynamic power draw of less than a tenth of a watt. 
* ⏱️ **Performance (Positive Slack):** Achieved strict timing closure with a Worst Negative Slack (WNS) of **+6.408 ns**, leaving massive headroom for future clock frequency scaling.

---

## 🏗️ Micro-architecture Specifications

```text
                                  Programmable Logic (Xilinx Artix-7)
┌────────────────────────┐        ┌─────────────────────────────────────────────────────┐
│ 3-Axis Sensor Data     │        │  ┌───────────────────────────────────────────────┐  │
│ (Or Physical Switches) │        │  │  Time-Multiplexed FSM Controller              │  │
│                        │        │  │ ┌──────────────┐   ┌────────────────────────┐ │  │
│  Input 0 (X-Axis) ─────┼────────┼─►│ │   ROM Bank   │   │  Fixed-Point MAC Unit  │ │  │
│  Input 1 (Y-Axis) ─────┼────────┼─►│ │ (100x W, B)  ├──►│  y = Σ(x_i * W_i) + B  │ │  │
│  Input 2 (Z-Axis) ─────┼────────┼─►│ └──────────────┘   └──────────┬─────────────┘ │  │
└────────────────────────┘        │  │                               │                 │  │
                                  │  │ ┌─────────────────────────────▼─────────────┐ │  │
                                  │  │ │ Hardware Spiking Activation (ReLU/Step)   │ │  │
                                  │  │ │ IF (y >= THRESHOLD) -> Spike = 1          │ │  │
                                  │  │ └─────────────────────────────┬─────────────┘ │  │
                                  │  └───────────────────────────────┼───────────────┘  │
                                  │                                  ▼                  │
                                  │  ┌───────────────────────────────────────────────┐  │
                                  │  │   Population Spike Aggregator                 │  │
                                  │  │   - Accumulates spikes from all 100 neurons   │  │
                                  │  └────────┬──────────────────────┬───────────────┘  │
                                  └───────────┼──────────────────────┼──────────────────┘
                                              ▼                      ▼
                            ┌────────────────────────┐    ┌──────────────────────┐
                            │  7-Segment Display     │    │  Output Neurons      │
                            │  (Confidence Score)    │    │  (System Wake-Up)    │
                            └────────────────────────┘    └──────────────────────┘
```
## 🧠 Core Engineering Features:
* Fixed-Point Arithmetic: Exclusively utilizes signed fixed-point logic (4-bit inputs, 8-bit weights, 14-bit accumulators) to bypass the power-hungry Floating-Point Units (FPUs) standard in software AI.
* Distributed On-Chip ROM: Weights and biases for all 100 neurons are baked directly into On-Chip ROM, completely eliminating external memory latency and DDR power costs.
Multi-Clock Domain Engineering: Custom clock dividers separate the high-speed neural processing core (1MHz) from the physical I/O refresh rate (1kHz) for stable 7-segment visualization.

## ⚙️ Hardware Reproduction Steps
* This project is built using the Xilinx Vivado Design Suite and targeted for the Digilent Basys 3 FPGA.

* RTL Project Setup: Clone the repository and add the Verilog (.v) files located in sources_1/ to a new Vivado project targeting part xc7a35tcpg236-1.
* Behavioral Simulation: Run the provided testbench (tb_top_module.v) to verify the FSM transitions and the mathematical accuracy of the fixed-point MAC unit.
* Physical Constraints: Import the basys3_constraints.xdc file to map the 3 physical inputs (x0, x1, x2) to the onboard slide switches, and map the Population Spike Count to the 7-segment display.

Implementation: Run Synthesis and Implementation. Review the generated Timing and Utilization reports to verify the extreme area efficiency.
Silicon Validation: Generate the Bitstream and program the FPGA to interact with the neural network in real-time.

## 📊 Analytical Reports
This repository is treated as a complete engineering package. Please review the attached corporate-style documentation in the root directory for deep-dive technical analytics:

## 🤝 Let's Connect
I engineered this project to bridge the gap between AI algorithms and the reality of bare-metal semiconductor constraints. I am actively seeking roles in ASIC/FPGA Design, RTL Engineering, and Hardware Acceleration.

If your team is tackling the physical challenges of custom silicon and Edge AI, let's connect on LinkedIn!
