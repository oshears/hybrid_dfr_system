import numpy as np

def mackey_glass(din):
    dout = 0
    if (din <= 0x0000_0000):
        dout = 0x0000_0008
    elif (din <= 0x016C_16C1):
        dout = 0x0000_0014
    elif (din <= 0x02D8_2D83):
        dout = 0x0000_0046
    elif (din <= 0x0444_4444):
        dout = 0x0000_0073
    elif (din <= 0x05B0_5B06):
        dout = 0x0000_0093
    elif (din <= 0x071C_71C7):
        dout = 0x0000_00C1
    elif (din <= 0x0888_8889):
        dout = 0x0000_00EE
    elif (din <= 0x09F4_9F4A):
        dout = 0x0000_010E
    elif (din <= 0x0B60_B60B):
        dout = 0x0000_013B
    elif (din <= 0x0CCC_CCCD):
        dout = 0x0000_016D
    elif (din <= 0x0E38_E38E):
        dout = 0x0000_0189
    elif (din <= 0x0FA4_FA50):
        dout = 0x0000_01BA
    elif (din <= 0x1111_1111):
        dout = 0x0000_01DF
    elif (din <= 0x127D_27D2):
        dout = 0x0000_0208
    elif (din <= 0x13E9_3E94):
        dout = 0x0000_0235
    elif (din <= 0x1555_5555):
        dout = 0x0000_0256
    elif (din <= 0x16C1_6C17):
        dout = 0x0000_0283
    elif (din <= 0x182D_82D8):
        dout = 0x0000_02B0
    elif (din <= 0x1999_999A):
        dout = 0x0000_02D1
    elif (din <= 0x1B05_B05B):
        dout = 0x0000_02FE
    elif (din <= 0x1C71_C71C):
        dout = 0x0000_032F
    elif (din <= 0x1DDD_DDDE):
        dout = 0x0000_034C
    elif (din <= 0x1F49_F49F):
        dout = 0x0000_037D
    elif (din <= 0x20B6_0B61):
        dout = 0x0000_03AA
    elif (din <= 0x2222_2222):
        dout = 0x0000_03C7
    elif (din <= 0x238E_38E4):
        dout = 0x0000_03F8
    elif (din <= 0x24FA_4FA5):
        dout = 0x0000_0414
    elif (din <= 0x2666_6666):
        dout = 0x0000_0446
    elif (din <= 0x27D2_7D28):
        dout = 0x0000_0473
    elif (din <= 0x293E_93E9):
        dout = 0x0000_0493
    elif (din <= 0x2AAA_AAAB):
        dout = 0x0000_04C1
    elif (din <= 0x2C16_C16C):
        dout = 0x0000_04EE
    elif (din <= 0x2D82_D82E):
        dout = 0x0000_0537
    elif (din <= 0x2EEE_EEEF):
        dout = 0x0000_053B
    elif (din <= 0x305B_05B0):
        dout = 0x0000_0568
    elif (din <= 0x31C7_1C72):
        dout = 0x0000_0589
    elif (din <= 0x3333_3333):
        dout = 0x0000_05BA
    elif (din <= 0x349F_49F5):
        dout = 0x0000_05D7
    elif (din <= 0x360B_60B6):
        dout = 0x0000_0608
    elif (din <= 0x3777_7777):
        dout = 0x0000_0635
    elif (din <= 0x38E3_8E39):
        dout = 0x0000_0656
    elif (din <= 0x3A4F_A4FA):
        dout = 0x0000_0683
    elif (din <= 0x3BBB_BBBC):
        dout = 0x0000_06B0
    elif (din <= 0x3D27_D27D):
        dout = 0x0000_06D1
    elif (din <= 0x3E93_E93F):
        dout = 0x0000_06FE
    elif (din <= 0x4000_0000):
        dout = 0x0000_072B
    elif (din <= 0x416C_16C1):
        dout = 0x0000_074C
    elif (din <= 0x42D8_2D83):
        dout = 0x0000_0779
    elif (din <= 0x4444_4444):
        dout = 0x0000_079A
    elif (din <= 0x45B0_5B06):
        dout = 0x0000_07C7
    elif (din <= 0x471C_71C7):
        dout = 0x0000_07F4
    elif (din <= 0x4888_8889):
        dout = 0x0000_0814
    elif (din <= 0x49F4_9F4A):
        dout = 0x0000_0842
    elif (din <= 0x4B60_B60B):
        dout = 0x0000_086F
    elif (din <= 0x4CCC_CCCD):
        dout = 0x0000_088F
    elif (din <= 0x4E38_E38E):
        dout = 0x0000_08BC
    elif (din <= 0x4FA4_FA50):
        dout = 0x0000_08E9
    elif (din <= 0x5111_1111):
        dout = 0x0000_090A
    elif (din <= 0x527D_27D2):
        dout = 0x0000_0937
    elif (din <= 0x53E9_3E94):
        dout = 0x0000_0954
    elif (din <= 0x5555_5555):
        dout = 0x0000_0981
    elif (din <= 0x56C1_6C17):
        dout = 0x0000_09AE
    elif (din <= 0x582D_82D8):
        dout = 0x0000_09CB
    elif (din <= 0x5999_999A):
        dout = 0x0000_09F8
    elif (din <= 0x5B05_B05B):
        dout = 0x0000_0A21
    elif (din <= 0x5C71_C71C):
        dout = 0x0000_0A42
    elif (din <= 0x5DDD_DDDE):
        dout = 0x0000_0A6A
    elif (din <= 0x5F49_F49F):
        dout = 0x0000_0A93
    elif (din <= 0x60B6_0B61):
        dout = 0x0000_0AB0
    elif (din <= 0x6222_2222):
        dout = 0x0000_0AD9
    elif (din <= 0x638E_38E4):
        dout = 0x0000_0AF2
    elif (din <= 0x64FA_4FA5):
        dout = 0x0000_0B17
    elif (din <= 0x6666_6666):
        dout = 0x0000_0B3B
    elif (din <= 0x67D2_7D28):
        dout = 0x0000_0B54
    elif (din <= 0x693E_93E9):
        dout = 0x0000_0B75
    elif (din <= 0x6AAA_AAAB):
        dout = 0x0000_0B91
    elif (din <= 0x6C16_C16C):
        dout = 0x0000_0BA6
    elif (din <= 0x6D82_D82E):
        dout = 0x0000_0BBE
    elif (din <= 0x6EEE_EEEF):
        dout = 0x0000_0BD7
    elif (din <= 0x705B_05B0):
        dout = 0x0000_0BE3
    elif (din <= 0x71C7_1C72):
        dout = 0x0000_0BF0
    elif (din <= 0x7333_3333):
        dout = 0x0000_0BF8
    elif (din <= 0x749F_49F5):
        dout = 0x0000_0C00
    elif (din <= 0x760B_60B6):
        dout = 0x0000_0C00
    elif (din <= 0x7777_7777):
        dout = 0x0000_0C00
    elif (din <= 0x78E3_8E39):
        dout = 0x0000_0BF4
    elif (din <= 0x7A4F_A4FA):
        dout = 0x0000_0BE3
    elif (din <= 0x7BBB_BBBC):
        dout = 0x0000_0BD3
    elif (din <= 0x7D27_D27D):
        dout = 0x0000_0BBA
    elif (din <= 0x7E93_E93F):
        dout = 0x0000_0B96
    elif (din <= 0x8000_0000):
        dout = 0x0000_0B7D
    elif (din <= 0x816C_16C1):
        dout = 0x0000_0B4C
    elif (din <= 0x82D8_2D83):
        dout = 0x0000_0B2B
    elif (din <= 0x8444_4444):
        dout = 0x0000_0AEE
    elif (din <= 0x85B0_5B06):
        dout = 0x0000_0AAC
    elif (din <= 0x871C_71C7):
        dout = 0x0000_0A7B
    elif (din <= 0x8888_8889):
        dout = 0x0000_0A31
    elif (din <= 0x89F4_9F4A):
        dout = 0x0000_09DF
    elif (din <= 0x8B60_B60B):
        dout = 0x0000_09A2
    elif (din <= 0x8CCC_CCCD):
        dout = 0x0000_0948
    elif (din <= 0x8E38_E38E):
        dout = 0x0000_08E5
    elif (din <= 0x8FA4_FA50):
        dout = 0x0000_08A0
    elif (din <= 0x9111_1111):
        dout = 0x0000_0835
    elif (din <= 0x927D_27D2):
        dout = 0x0000_07C3
    elif (din <= 0x93E9_3E94):
        dout = 0x0000_0775
    elif (din <= 0x9555_5555):
        dout = 0x0000_06FE
    elif (din <= 0x96C1_6C17):
        dout = 0x0000_06A8
    elif (din <= 0x982D_82D8):
        dout = 0x0000_0629
    elif (din <= 0x9999_999A):
        dout = 0x0000_05A2
    elif (din <= 0x9B05_B05B):
        dout = 0x0000_0548
    elif (din <= 0x9C71_C71C):
        dout = 0x0000_04BC
    elif (din <= 0x9DDD_DDDE):
        dout = 0x0000_042D
    elif (din <= 0x9F49_F49F):
        dout = 0x0000_03CB
    elif (din <= 0xA0B6_0B61):
        dout = 0x0000_033F
    elif (din <= 0xA222_2222):
        dout = 0x0000_02BC
    elif (din <= 0xA38E_38E4):
        dout = 0x0000_0273
    elif (din <= 0xA4FA_4FA5):
        dout = 0x0000_021D
    elif (din <= 0xA666_6666):
        dout = 0x0000_01F0
    elif (din <= 0xA7D2_7D28):
        dout = 0x0000_01B6
    elif (din <= 0xA93E_93E9):
        dout = 0x0000_0191
    elif (din <= 0xAAAA_AAAB):
        dout = 0x0000_0175
    elif (din <= 0xAC16_C16C):
        dout = 0x0000_0158
    elif (din <= 0xAD82_D82E):
        dout = 0x0000_013F
    elif (din <= 0xAEEE_EEEF):
        dout = 0x0000_012B
    elif (din <= 0xB05B_05B0):
        dout = 0x0000_011F
    elif (din <= 0xB1C7_1C72):
        dout = 0x0000_010A
    elif (din <= 0xB333_3333):
        dout = 0x0000_0102
    elif (din <= 0xB49F_49F5):
        dout = 0x0000_00F6
    elif (din <= 0xB60B_60B6):
        dout = 0x0000_00EE
    elif (din <= 0xB777_7777):
        dout = 0x0000_00E1
    elif (din <= 0xB8E3_8E39):
        dout = 0x0000_00D9
    elif (din <= 0xBA4F_A4FA):
        dout = 0x0000_00CD
    elif (din <= 0xBBBB_BBBC):
        dout = 0x0000_00C9
    elif (din <= 0xBD27_D27D):
        dout = 0x0000_00C1
    elif (din <= 0xBE93_E93F):
        dout = 0x0000_00BC
    elif (din <= 0xC000_0000):
        dout = 0x0000_00B4
    elif (din <= 0xC16C_16C1):
        dout = 0x0000_00B0
    elif (din <= 0xC2D8_2D83):
        dout = 0x0000_00AC
    elif (din <= 0xC444_4444):
        dout = 0x0000_00A4
    elif (din <= 0xC5B0_5B06):
        dout = 0x0000_00A0
    elif (din <= 0xC71C_71C7):
        dout = 0x0000_009C
    elif (din <= 0xC888_8889):
        dout = 0x0000_0098
    elif (din <= 0xC9F4_9F4A):
        dout = 0x0000_0093
    elif (din <= 0xCB60_B60B):
        dout = 0x0000_0093
    elif (din <= 0xCCCC_CCCD):
        dout = 0x0000_008B
    elif (din <= 0xCE38_E38E):
        dout = 0x0000_008B
    elif (din <= 0xCFA4_FA50):
        dout = 0x0000_0087
    elif (din <= 0xD111_1111):
        dout = 0x0000_0083
    elif (din <= 0xD27D_27D2):
        dout = 0x0000_0083
    elif (din <= 0xD3E9_3E94):
        dout = 0x0000_007F
    elif (din <= 0xD555_5555):
        dout = 0x0000_007B
    elif (din <= 0xD6C1_6C17):
        dout = 0x0000_007B
    elif (din <= 0xD82D_82D8):
        dout = 0x0000_0077
    elif (din <= 0xD999_999A):
        dout = 0x0000_0077
    elif (din <= 0xDB05_B05B):
        dout = 0x0000_0073
    elif (din <= 0xDC71_C71C):
        dout = 0x0000_006F
    elif (din <= 0xDDDD_DDDE):
        dout = 0x0000_006F
    elif (din <= 0xDF49_F49F):
        dout = 0x0000_006A
    elif (din <= 0xE0B6_0B61):
        dout = 0x0000_006A
    elif (din <= 0xE222_2222):
        dout = 0x0000_006A
    elif (din <= 0xE38E_38E4):
        dout = 0x0000_0066
    elif (din <= 0xE4FA_4FA5):
        dout = 0x0000_0062
    elif (din <= 0xE666_6666):
        dout = 0x0000_0062
    elif (din <= 0xE7D2_7D28):
        dout = 0x0000_0062
    elif (din <= 0xE93E_93E9):
        dout = 0x0000_0062
    elif (din <= 0xEAAA_AAAB):
        dout = 0x0000_005E
    elif (din <= 0xEC16_C16C):
        dout = 0x0000_005E
    elif (din <= 0xED82_D82E):
        dout = 0x0000_005E
    elif (din <= 0xEEEE_EEEF):
        dout = 0x0000_005A
    elif (din <= 0xF05B_05B0):
        dout = 0x0000_005A
    elif (din <= 0xF1C7_1C72):
        dout = 0x0000_005A
    elif (din <= 0xF333_3333):
        dout = 0x0000_0056
    elif (din <= 0xF49F_49F5):
        dout = 0x0000_0056
    elif (din <= 0xF60B_60B6):
        dout = 0x0000_0056
    elif (din <= 0xF777_7777):
        dout = 0x0000_0056
    elif (din <= 0xF8E3_8E39):
        dout = 0x0000_0052
    elif (din <= 0xFA4F_A4FA):
        dout = 0x0000_0052
    elif (din <= 0xFBBB_BBBC):
        dout = 0x0000_0052
    elif (din <= 0xFD27_D27D):
        dout = 0x0000_0052
    elif (din <= 0xFE93_E93F):
        dout = 0x0000_004E
    elif (din <= 0xFFFF_FFFF):
        dout = 0x0000_004E
    else:
        dout = 0
    return dout

RESERVOIR_NODES = 10
STEPS_PER_SAMPLE = RESERVOIR_NODES
NUM_SAMPLES = 5

def dfr(din):

    # RESERVOIR_NODES x 1
    reservoir_current = np.zeros(RESERVOIR_NODES, dtype=int)
    # RESERVOIR_NODES x 1
    reservoir_next = np.zeros(RESERVOIR_NODES, dtype=int)
    # RESERVOIR_NODES x (NUM_SAMPLES x STEPS_PER_SAMPLE)
    reservoir_history = np.zeros((RESERVOIR_NODES, (NUM_SAMPLES * STEPS_PER_SAMPLE)), dtype=int)
    # RESERVOIR_NODES (STEPS_PER_SAMPLE) x NUM_SAMPLES
    reservoir_loops = np.array((RESERVOIR_NODES,NUM_SAMPLES),dtype=int)
    
    

    for i in range(len(din)):
        
        a_in = din[i] + reservoir_current[RESERVOIR_NODES - 1]
        
        reservoir_next[0] = mackey_glass(a_in) << 20

        reservoir_next[1:RESERVOIR_NODES] = reservoir_current[0:RESERVOIR_NODES - 1]
        
        reservoir_current = reservoir_next.copy()

        reservoir_history[:,i] = reservoir_current

        # print(f"Sample: {i}")
        # print(f"{hex(din[i])} + {hex(reservoir_current[RESERVOIR_NODES - 1])} ==> {hex(reservoir_next[0])}")
        # print(f"{din[i]} + {reservoir_current[RESERVOIR_NODES - 1]} ==> {reservoir_next[0]}")
        # # print(reservoir_current)
        # print("===============================")

    # extract the reservoir state after each sample is fully processed (i.e., every STEPS_PER_SAMPLE)
    history_samples = STEPS_PER_SAMPLE * np.arange(1,NUM_SAMPLES+1) - 1
    # RESERVOIR_NODES (STEPS_PER_SAMPLE) x NUM_SAMPLES
    reservoir_loops = reservoir_history[:,history_samples]

    # print(reservoir_history)
    #print(reservoir_loops)

    # 1 x STEPS_PER_SAMPLE
    weights = np.ones((1,STEPS_PER_SAMPLE),dtype=int)
    # 1 x NUM_SAMPLES
    dout = weights.dot(reservoir_loops)

    
    # print(np.flip(reservoir_loops,0).T)
    # print(np.flip(reservoir_loops,0).T.shape)
    # print(weights.T)
    # print(weights.T.shape)
    # print(np.flip(reservoir_loops,0).T.dot(weights.T))
    

    return dout


din = int(0x00FF_FFFF / (NUM_SAMPLES * STEPS_PER_SAMPLE) ) * np.linspace(0, (NUM_SAMPLES * STEPS_PER_SAMPLE), (NUM_SAMPLES * STEPS_PER_SAMPLE),dtype=int)
din = din[0: NUM_SAMPLES * STEPS_PER_SAMPLE + 1]
print(din)
dout = dfr(din)
print(dout)