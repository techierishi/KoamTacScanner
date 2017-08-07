//
//  KDCConstants.h
//  KDCReader
//
//  Created by KoamTac on 10/18/14.
//  Copyright (c) 2014 AISolution. All rights reserved.
//

#ifndef KDCReader_KDCConstants_h
#define KDCReader_KDCConstants_h

/*!
 * @enum EnableDisable
 */
enum EnableDisable
{
    DISABLE = 0,
    ENABLE
};

/*!
 * @enum KDCMode
 */
enum KDCMode
{
    NORMAL = 0,
    APPLICATION
};

/*!
 * @enum DataDelimiter
 */
enum DataDelimiter
{
    NONE = 0,
    TAB,
    SPACE,
    COMMA,
    SEMICOLON
};

/*!
 * @enum RecordDelimiter
 */
enum RecordDelimiter
{
    RECORD_NONE = 0,
    RECORD_LF,
    RECORD_CR,
    RECORD_TAB,
    RECORD_CRnLF
};

/*!
 * @enum NFCDataFormat
 */
enum NFCDataFormat
{
    NFC_PACKET_FORMAT = 0,
    NFC_DATA_ONLY
};

/*!
 * @enum AESKeyLength
 */
enum AESKeyLength
{
    AES_KEY_128 = 0,
    AES_KEY_192,
    AES_KEY_256
};

/*!
 * @enum WedgeMode
 */
enum WedgeMode
{
    WEDGE_ONLY = 0,
    WEDGE_STORE,
    STORE_ONLY,
    STORE_IF_SENT,
    STORE_IF_NOT_SENT
};

/*!
 * @enum AIMID
 */
enum AIMID
{
    AIMID_NONE = 0,
    AIMID_PREFIX,
    AIMID_SUFFIX,
    IN_PREFIX = AIMID_PREFIX,
    IN_SUFFIX = AIMID_SUFFIX
};

/*!
 * @enum DataTerminator
 */
enum DataTerminator
{
    TERMINATOR_NONE = 0,
    TERMINATOR_CR,
    TERMINATOR_LF,
    TERMINATOR_CRnLF,
    TERMINATOR_TAB,
    RIHGT_ARROW,
    LEFT_ARROW,
    DOWN_ARROW,
    UP_ARROW
};

/*!
 * @enum PowerOnTime
 */
enum PowerOnTime
{
    POWERON_DISABLED = 0,
    POWERON_1_SECOND,
    POWERON_2_SECONDS,
    POWERON_3_SECONDS,
    POWERON_4_SECONDS,
    POWERON_5_SECONDS,
    POWERON_6_SECONDS,
    POWERON_7_SECONDS,
    POWERON_8_SECONDS,
    POWERON_9_SECONDS,
    POWERON_10_SECONDS
};

/*!
 * @enum SleepTimeout
 */
enum SleepTimeout
{
    SLEEP_TIMEOUT_DISABLED = 0,
    SLEEP_TIMEOUT_1_SECOND = 1,
    SLEEP_TIMEOUT_2_SECONDS = 2,
    SLEEP_TIMEOUT_3_SECONDS = 3,
    SLEEP_TIMEOUT_4_SECONDS = 4 ,
    SLEEP_TIMEOUT_5_SECONDS = 5,
    SLEEP_TIMEOUT_10_SECONDS = 10,
    SLEEP_TIMEOUT_20_SECONDS = 20,
    SLEEP_TIMEOUT_30_SECONDS = 30,
    SLEEP_TIMEOUT_60_SECONDS = 60,
    SLEEP_TIMEOUT_120_SECONDS = 120,
    SLEEP_TIMEOUT_300_SECONDS = 300,
    SLEEP_TIMEOUT_600_SECONDS = 600
};

/*!
 * @enum DisplayFormat
 */
enum DisplayFormat
{
    TIME_BATTERY = 0,
    DISPLAY_FORMAT_TYPE_TIME,
    DISPLAY_FORMAT_TYPE_BATTERY,
    DISPLAY_FORMAT_MEMORY_STATUS,
    DISPLAY_FORMAT_GPS_DATA,
    DISPLAY_FORMAT_BARCODE_ONLY
};

/*!
 * @enum AutoPowerOffTimeout
 */
enum AutoPowerOffTimeout
{
    POWEROFF_DISABLE = 0,
    POWEROFF_5_MINUTES = 5,
    POWEROFF_10_MINUTES = 10,
    POWEROFF_20_MINUTES = 20,
    POWEROFF_30_MINUTES = 30,
    POWEROFF_60_MINUTES = 60,
    POWEROFF_120_MINUTES = 120
};

/*!
 * @struct DateTime
 */
struct DateTime
{
    uint8_t     Year;
    uint8_t     Month;
    uint8_t     Day;
    uint8_t     Hour;
    uint8_t     Minute;
    uint8_t     Second;
};

/*!
 * @enum MemoryConfiguration
 */
enum MemoryConfiguration
{
    MEMORY_0p5M_3p5M = 0,
    MEMORY_1M_3M,
    MEMORY_2M_2M,
    MEMORY_3M_1M,
    MEMORY_4M_0M
};

/*!
 * @enum GPSPowerSaveMode
 */
enum GPSPowerSaveMode
{
    GPS_NORMAL = 0,
    GPS_POWER_SAVE
};

/*!
 * @struct BarcodeSymbolSettings
 */
struct BarcodeSymbolSettings
{
    uint32_t    FirstSymbols;
    uint32_t    SecondSymbols;
};

/*!
 * @struct BarcodeOptionSettings
 */
struct BarcodeOptionSettings
{
    uint32_t    FirstOptions;
    uint32_t    SecondOptions;
};

/*!
 * @enum ScanTimeout
 */
enum ScanTimeout
{
    SCANTIMEOUT_500_MS = 500,
    SCANTIMEOUT_1_SECOND = 1000,
    SCANTIMEOUT_2_SECONDS = 2000,
    SCANTIMEOUT_3_SECONDS = 3000,
    SCANTIMEOUT_4_SECONDS = 4000,
    SCANTIMEOUT_5_SECONDS = 5000,
    SCANTIMEOUT_6_SECONDS = 6000,
    SCANTIMEOUT_7_SECONDS = 7000,
    SCANTIMEOUT_8_SECONDS = 8000,
    SCANTIMEOUT_9_SECONDS = 9000,
    SCANTIMEOUT_10_SECONDS = 10000
};

/*!
 * @enum AutoTriggerRereadDelay
 */
enum AutoTriggerRereadDelay
{
    REREAD_CONTINUOUS = 0,
    REREAD_SHORT,
    REREAD_MEDIUM,
    REREAD_LONG,
    REREAD_EXTRA_LONG
};

/*!
 * @enum PartialAction
 */
enum PartialAction
{
    ERASE = 0,
    SELECT
};

/*!
 * @enum DataFormat
 */
enum DataFormat
{
    BARCODE_ONLY = 0,
    PACKET_DATA
};

/*!
 * @enum MessageFontSize
 */
enum MessageFontSize
{
    FONT_8x8 = 0,
    FONT_8x16,
    FONT_16x16,
    FONT_16x24,
    FONT_16x32,
    FONT_24x24,
    FONT_24x32,
    FONT_32x32
};

/*!
 * @enum MessageTextAttribute
 */
enum MessageTextAttribute
{
    NORMAL_TEXT = 0,
    REVERSE_TEXT
};

/*!
 * @enum LEDState
 */
enum LEDState
{
    GREEN_LED_OFF = 0,
    GREEN_LED_ON,
    RED_LED_OFF,
    RED_LED_ON,
    BOTH_LED_OFF,
    BOTH_LED_ON
};

/*!
 * @enum DataType
 */
enum DataType
{
    UNKNOWN = 0,
    BARCODE,
    MSR,
    GPS,
    NFC_OLD,
    NFC_NEW,
    APPLICATION_DATA
};

/*!
 * @enum NFCTag
 */
enum NFCTag
{
    NDEF_TYPE1 = 0,
    NDEF_TYPE2,
    RFID,
    CALYPSO,
    MIFARE_4K,
    TYPE_A,
    TYPE_B,
    FELICA,
    JEWEL,
    MIFARE_1K,
    MIFARE_UL_C,
    MIFARE_UL,
    MIFARE_DESFIRE,
    ISO15693
};

/*!
 * @enum AESBitLengths
 */
enum AESBitLengths
{
    AES_128_BITS = 0,
    AES_192_BITS,
    AES_256_BITS
};

/*!
 * @enum MSRCardType
 */
enum MSRCardType
{
    MSR_CARD_ISO = 0,
    MSR_CARD_OTHER_1,
    MSR_CARD_AAMVA
};

/*!
 * @enum MSRDataType
 */
enum MSRDataType
{
    MSR_DATA_PAYLOAD = 0,
    MSR_DATA_PACKET
};

/*!
 * @enum MSRDataEncryption
 */
enum MSRDataEncryption
{
    ENCRYPT_NONE = 0,
    ENCRYPT_AES
};

/*!
 * @enum MSRTrack
 */
enum MSRTrack
{
    MSR_TRACK1 = 0x01,
    MSR_TRACK2 = 0x01 << 1,
    MSR_TRACK3 = 0x01 << 3
};

/*!
 * @enum MSRTrackSeparator
 */
enum MSRTrackSeparator
{
    SEPARATOR_NONE,
    SEPARATOR_SPACE,
    SEPARATOR_COMMA,
    SEPARATOR_SEMICOLON,
    SEPARATOR_CR,
    SEPARATOR_LF,
    SEPARATOR_CRLF,
    SEPARATOR_TAB
};

/*!
 * @enum WiFiProtocol
 */
enum WiFiProtocol
{
    UDP = 0,
    TCP,
    HTTP_GET,
    HTTP_POST
};
#endif
