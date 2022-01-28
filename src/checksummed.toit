// Copyright (C) 2022 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

import crypto.crc32 show crc32
import esp32

class CheckSummedRtc:
  bytes_/ByteArray
  checksum_/ByteArray
  static CHECKSUM_OFFSET_ ::= esp32.RTC_MEMORY_SIZE - 4

  constructor:
    rtc_bytes := esp32.rtc_user_bytes
    checksum_ = rtc_bytes[CHECKSUM_OFFSET_..]
    bytes_ = rtc_bytes[..CHECKSUM_OFFSET_]
    loaded_checksum := compute_checksum_
    if loaded_checksum != checksum_:
      throw "INCONSISTENT"

  constructor.init value/int=0:
    rtc_bytes := esp32.rtc_user_bytes
    bytes_ = rtc_bytes[..CHECKSUM_OFFSET_]
    checksum_ = rtc_bytes[CHECKSUM_OFFSET_..]
    bytes_.fill value
    update_checksum

  constructor.non_throwing value/int=0:
    catch:
      return CheckSummedRtc
    return CheckSummedRtc.init value

  do from/int=0 to/int=(bytes_.size - CHECKSUM_OFFSET_) [block]:
    if not 0 <= from <= to <= bytes_.size - CHECKSUM_OFFSET_:
    try:
      block.call bytes_[from..to]
    finally:
      update_checksum

  update_checksum -> none:
    checksum_.replace 0 compute_checksum_

  compute_checksum_ -> ByteArray:
    return crc32 bytes_
