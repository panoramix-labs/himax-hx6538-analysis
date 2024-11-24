# Himax HX6538 Analysis

**DISCLAIMER:** all of this information was obtained from public
source, or guessed by looking at public source, and all information
disclosed here is already publicated on one of the sources listed
through this document.

This repository aims to study the HX5638 chip from Himax, also known as WiseEye2.

The repository that seems the most up to date and used is in this study is:
<https://github.com/HimaxWiseEyePlus/Seeed_Grove_Vision_AI_Module_V2/>

This analysis uses the `allon_sensor_tflm` example as reference, as it
is the most minimal and seems to support everything and work better.

Resources from Himax:

- High-level overview of the chip:
  <https://himaxwiseeyeplus.github.io/>

- Documentation of the libraries in the header files:
  <https://github.com/HimaxWiseEyePlus/Seeed_Grove_Vision_AI_Module_V2/tree/main/EPII_CM55M_APP_S/drivers/inc>

- Seeed Studio documentation:
  <https://wiki.seeedstudio.com/grove_vision_ai_v2_himax_sdk/>

- Description of the pipeline documented inside the configuration headers in the samples:
  <https://github.com/HimaxWiseEyePlus/Seeed_Grove_Vision_AI_Module_V2/blob/main/EPII_CM55M_APP_S/app/scenario_app/allon_sensor_tflm/cis_sensor/cis_imx219/cisdp_cfg.h>


## Organization of the SDK

According to
[this source](https://github.com/LynnL4/firmware-seeed-grove-vision-ai/tree/main/Synopsys_PA8535_EM9D_DFSS_SDK_3.3),
the Himax SDK is based on the Synopsys DesignWareCore suite: a modified
[Synopsys EM9D](https://www.synopsys.com/dw/ipdir.php?ds=smart-data-fusion-subsystem)
SoC o include an ARM core instead of a
[Synposys ARC EM9D](https://www.synopsys.com/dw/ipdir.php?ds=arc-em9d-em11d) core.

This means that while some details could differ, the peripherals working is essentialy the same as the ARC peripherals.
Some elements of this SDK are published as open-source [here](https://github.com/foss-for-synopsys-dwc-arc-processors/embarc_osp).

The SDK top level directory is `EPII_CM55M_APP_S`.

On some other SDKs, there is also a `EPII_CM55M_APP_M` directory for
the other core, that contains the same SDK but with modifications for
running on the other core.


## Glossary

- **EPII** means more or less WiseEye2.
- **DP** Means DataPath (see below).
- **HW2X2** means Hardware pixel conversion engine with 2x2 window.
- **HW5X5** means Hardware pixel conversion engine with 5x5 window.
- **JPEG** means hardware-based JPEG encoder.
- **JPEGENC** means software-based JPEG encoder.
- **DW** Means DesignWare, the robust peripheral library of Synopsys


## Organization of the DataPath

The "DataPath" is a collection of cores and a control system for it.

It is the name of the interconnection *between* the image processing
cores, that is responsible for the connection between the cores and
brings them to the memory for application processing.

```
*	[IMX219]
|	< size 3280x2464 format BGR8U3C
|
*	[INP]
|\	> size 3280x2464 format BGR8U3C
| \	- crop	
| |\	- size 3200x2400 format BGR8U3C
| | |	- binning + subsample
| | |	< size 640x480 format BGR8U3C
| | |
| | *	[HW2X2]
| | |	> size 640x480 format BGR8U3C max 640x480
| | |	- binning + subsample
| | |	< size 640x480 format RGB24
| | |
| | *	[CDM]
| |	> size 640x480 format RGB24 max 480x270
| |	- motion detection
| |
| *	[hx_lib_image_resize_BGR8U3C_to_RGB24_helium]
| |	> size 640x480 format BGR8U3C
| |	- software
| |	< size 640x480 format RGB24
| |	
| *	[TensorFlowLiteMicro]	
|	> size 640x480 format RGB24
|	- Invoke()
|
*	[HW5X5]
|\	> size 640x480 format BGR8U3C step 8x4
| |	- demosaic
| |	< size 640x480 format RGB24
| |
| *	[JPEG]
| |	> size 640x480 format RGB24 max 640x640 mod 16x16
| |	- encoding
| |	< size 640x480 format JPEG
| |
| *	[WDMA3]
| |	> size 640x480 format JPEG
| |
| *	[SENDPLIB]
|	> size 640x480 format JPEG
|	- software
|	< size 640x480 format JPEG+BASE64+JSON
|
*	[WDMA2]
	> size 640x480 format RGB24

*	[WDMA1]
	> size 381 kBytes

*	[XDMA]

*	[RDMA1]
```

I am realy not sure of the location of the WDMA/RDMA/XDMA in the
chain. These seems like what interconnect nodes through the pipeline
rather than being "blocks" on their own.
