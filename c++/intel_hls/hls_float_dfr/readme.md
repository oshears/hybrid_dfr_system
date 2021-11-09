# Using Intel HLS Compiler
```
cd /home/oshears/intelFPGA_pro/21.3/hls/examples/counter
~/intelFPGA_pro/21.3/hls/init_hls.sh
make test-fpga DEVICE=CycloneV
```


# bladeRF Hosted Design Utilization
```
+-------------------------------------------------------------------------------+
; Flow Summary                                                                  ;
+---------------------------------+---------------------------------------------+
; Flow Status                     ; Successful - Thu Oct 28 15:23:19 2021       ;
; Quartus Prime Version           ; 20.1.1 Build 720 11/11/2020 SJ Lite Edition ;
; Revision Name                   ; hosted                                      ;
; Top-level Entity Name           ; bladerf                                     ;
; Family                          ; Cyclone V                                   ;
; Device                          ; 5CEBA4F23C8                                 ;
; Timing Models                   ; Final                                       ;
; Logic utilization (in ALMs)     ; 6,280 / 18,480 ( 34 % )                     ;
; Total registers                 ; 14006                                       ;
; Total pins                      ; 173 / 224 ( 77 % )                          ;
; Total virtual pins              ; 0                                           ;
; Total block memory bits         ; 1,824,256 / 3,153,920 ( 58 % )              ;
; Total DSP Blocks                ; 8 / 66 ( 12 % )                             ;
; Total HSSI RX PCSs              ; 0                                           ;
; Total HSSI PMA RX Deserializers ; 0                                           ;
; Total HSSI TX PCSs              ; 0                                           ;
; Total HSSI PMA TX Serializers   ; 0                                           ;
; Total PLLs                      ; 3 / 4 ( 75 % )                              ;
; Total DLLs                      ; 0 / 4 ( 0 % )                               ;
+---------------------------------+---------------------------------------------+
```

# DFR Core Design Utilization
```
+-------------------------------------------------------------------------------+
; Flow Summary                                                                  ;
+---------------------------------+---------------------------------------------+
; Flow Status                     ; Successful - Thu Oct 28 16:11:44 2021       ;
; Quartus Prime Version           ; 20.1.1 Build 720 11/11/2020 SJ Lite Edition ;
; Revision Name                   ; quartus_compile                             ;
; Top-level Entity Name           ; quartus_compile                             ;
; Family                          ; Cyclone V                                   ;
; Device                          ; 5CEBA4F23C8                                 ;
; Timing Models                   ; Final                                       ;
; Logic utilization (in ALMs)     ; 16,909 / 18,480 ( 91 % )                    ;
; Total registers                 ; 46110                                       ;
; Total pins                      ; 0 / 224 ( 0 % )                             ;
; Total virtual pins              ; 71                                          ;
; Total block memory bits         ; 399,652 / 3,153,920 ( 13 % )                ;
; Total DSP Blocks                ; 66 / 66 ( 100 % )                           ;
; Total HSSI RX PCSs              ; 0                                           ;
; Total HSSI PMA RX Deserializers ; 0                                           ;
; Total HSSI TX PCSs              ; 0                                           ;
; Total HSSI PMA TX Serializers   ; 0                                           ;
; Total PLLs                      ; 0 / 4 ( 0 % )                               ;
; Total DLLs                      ; 0 / 4 ( 0 % )                               ;
+---------------------------------+---------------------------------------------+
```