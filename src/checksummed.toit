// Copyright (C) 2022 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import crypto.crc32 show crc32
import esp32

/**
Checksummed RTC-backed byte array.

The byte array is accessed with the $do method.
*/
class ChecksummedRtc:
  bytes_/ByteArray
  checksum_/ByteArray
  static CHECKSUM_OFFSET_ ::= esp32.RTC_MEMORY_SIZE - 4

  /**
  Constructs a checksummed RTC-backed byte array.

  The checksum stored in RTC must match the data in RTC.
  */
  constructor:
    rtc_bytes := esp32.rtc_user_bytes
    checksum_ = rtc_bytes[CHECKSUM_OFFSET_..]
    bytes_ = rtc_bytes[..CHECKSUM_OFFSET_]
    if compute_checksum_ != checksum_:
      throw "INCONSISTENT"

  /**
  Constructs an initial checksummed RTC-backed byte array.

  The byte array is filled with the given $value.
  */
  constructor.init value/int=0:
    rtc_bytes := esp32.rtc_user_bytes
    bytes_ = rtc_bytes[..CHECKSUM_OFFSET_]
    checksum_ = rtc_bytes[CHECKSUM_OFFSET_..]
    bytes_.fill value
    update_checksum_

  /**
  Constructs an checksummed RTC-backed byte array.

  If the byte contents in RTC memory matches the checksum, then the byte array is used as is.
  Otherwise, the byte array is filled with the given value and the checksum updated.
  */
  constructor.non_throwing value/int=0:
    catch: return ChecksummedRtc
    return ChecksummedRtc.init value

  /** Size of the byte array. */
  size -> int:
    return CHECKSUM_OFFSET_

  /**
  Calls the $block with the RTC backed byte array as an argument.

  After the call, the checksum is updated.

  The given $from and $to defines the slice given to the block. They must
    satisfy 0 <= from <= to <= $size.
  */
  do from/int=0 to/int=size [block]:
    if not 0 <= from <= to <= size: throw "OUT_OF_BOUNDS"

    try:
      block.call bytes_[from..to]
    finally:
      update_checksum_

  update_checksum_ -> none:
    checksum_.replace 0 compute_checksum_

  compute_checksum_ -> ByteArray:
    return crc32 bytes_
