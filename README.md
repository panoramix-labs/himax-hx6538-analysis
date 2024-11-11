# Himax HX6538 Analysis

This repository aims to study the HX5638 chip from Himax, also known as WiseEye2.

The repository that seems the most up to date and used is in this study is:
<https://github.com/HimaxWiseEyePlus/Seeed_Grove_Vision_AI_Module_V2/>

General presentation of the organization of the SDK will follow.

The headers include information

For now, the most critical, harder to guess information is this:


## Organization of the DataPath

The "DataPath" is a collection of cores and a control system for it.

It is the name of the interconnection *between* the image processing
cores, that is responsible for the connection between the cores and
brings them to the new.

```
*       [IMX219]
|        size 3280x2464
|
*       [INP]
|\       size 3280x2464
| |      crop
| |      size 3200x2400
| |      binning
| |      subsample
| |      size 640x480
| |
| *     [HW2X2]
| |      size 640x480 max 640x480
| |      binning
| |      subsample
| |      size 640x480
| |
| *     [CDM]
|        size 640x480 max 480x270
|        motion detection
|
*       [HW5X5]
|\       size 640x480 step 8x4
| |      demosaic
| |      size 640x480
| |
| *     [JPEG]
|        size 640x480 max 640x640 mod 16x16
|
*       [WDMA3]
         size 640x480
         format rgb

?
*       [WDMA1]
?        size 381 kBytes

?
*       [WDMA2]
?        size 640x480

?
*       [SENDPLIB]
?        format jpeg
         software
         format base64+jpeg
```
