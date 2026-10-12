#!/usr/bin/env python3
"""Extract the SHA-256 of an APK's v2/v3 signing certificate.

Usage: verify_apk_signing.py <apk>
Prints the lowercase hex digest to stdout. Exits 1 when no signing block
or signer certificate is found (unsigned / v1-only APK).
"""
import hashlib
import struct
import sys

MAGIC = b"APK Sig Block 42"
SCHEME_IDS = (0x7109871A, 0xF05368C0)  # v2, v3


def lp(buf: bytes, off: int) -> tuple[bytes, int]:
    length = struct.unpack("<I", buf[off:off + 4])[0]
    return buf[off + 4:off + 4 + length], off + 4 + length


def main() -> int:
    with open(sys.argv[1], "rb") as fh:
        data = fh.read()
    idx = data.find(MAGIC)
    if idx == -1:
        print("no APK signing block found", file=sys.stderr)
        return 1
    size2 = struct.unpack("<Q", data[idx - 8:idx])[0]
    pos = idx + 16 - (size2 + 8) + 8  # first length-prefixed pair
    end = idx - 8
    while pos < end:
        plen, pid = struct.unpack("<QI", data[pos:pos + 12])
        val = data[pos + 12:pos + 8 + plen]
        if pid in SCHEME_IDS:
            signers, _ = lp(val, 0)
            signer, _ = lp(signers, 0)
            signed_data, _ = lp(signer, 0)
            _digests, off = lp(signed_data, 0)
            certs, _ = lp(signed_data, off)
            cert, _ = lp(certs, 0)
            print(hashlib.sha256(cert).hexdigest())
            return 0
        pos += 8 + plen
    print("no signer certificate parsed", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
