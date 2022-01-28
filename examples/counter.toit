// Copyright (C) 2022 Toitware ApS.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import esp32
import rtc_memory.checksummed show ChecksummedRtc

main:
  rtc_memory := ChecksummedRtc.non_throwing

  rtc_memory.do: | bytes/ByteArray |
    print "$bytes[0]"
    bytes[0] = bytes[0] + 1

  esp32.deep_sleep
    Duration --s=2
