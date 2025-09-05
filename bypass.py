import binascii
import os
import sys
from mitmproxy import http
from mitmproxy import ctx
import decrypt
import proto
import Login_pb2


aesUtils = decrypt.AESUtils()
protoUtils = proto.ProtobufUtils()


def hexToOctetStream(hex_str: str) -> bytes:
    return bytes.fromhex(hex_str)


def checkUIDExists(uid: str) -> bool:
    uid = uid.strip()
    try:
        with open("uid.txt", "r", encoding="utf-8") as file:
            for line in file:
                if line.strip() == uid:
                    return True
    except FileNotFoundError:
        print("Error: uid.txt not found.")
    return False


class MajorLoginInterceptor:
    def request(self, flow: http.HTTPFlow) -> None:

        if flow.request.method.upper() == "POST" and "/MajorLogin" in flow.request.path:
            enc_body = flow.request.content.hex()
            dec_body = aesUtils.decrypt_aes_cbc(enc_body)
            body = protoUtils.decode_protobuf(dec_body.hex(), Login_pb2.LoginReq)

            body.deviceData = "KqsHTxnXXUCG8sxXFVB2j0AUs3+0cvY/WgLeTdfTE/KPENeJPpny2EPnJDs8C8cBVMcd1ApAoCmM9MhzDDXabISdK31SKSFSr06eVCZ4D2Yj/C7G"
            body.reserved20 = b"\u0013RFC\u0007\u000e\\Q1"

            binary_data = body.SerializeToString()
            finalEncContent = aesUtils.encrypt_aes_cbc(
                hexToOctetStream(binary_data.hex())
            )
            flow.request.content = bytes.fromhex(finalEncContent.hex())

    def response(self, flow: http.HTTPFlow) -> None:
        if (
            flow.request.method.upper() == "POST"
            and "MajorLogin".lower() in flow.request.path.lower()
        ):

            respBody = flow.response.content.hex()
            decodedBody = protoUtils.decode_protobuf(respBody, Login_pb2.getUID)
            checkUID = checkUIDExists(str(decodedBody.uid))

            if not checkUID:
                flow.response.content = f"[ffffff] BUY THE UID BYPASS AND USE\n\n[FFFFFF]UID: {decodedBody.uid} .".encode()
                flow.response.status_code = 400
                return None


addons = [MajorLoginInterceptor()]


def load(loader) -> None:
    ctx.options.ssl_insecure = True
    ctx.options.confdir = "."


if __name__ == "__main__":
    try:
        from mitmproxy.tools.main import mitmdump as mitmdump_entry
    except Exception as import_error:
        # Ensure local site-packages (Silly installs with --prefix .local)
        major = sys.version_info.major
        minor = sys.version_info.minor
        local_site = os.path.join(os.getcwd(), ".local", "lib", f"python{major}.{minor}", "site-packages")
        if os.path.isdir(local_site) and local_site not in sys.path:
            sys.path.insert(0, local_site)
        from mitmproxy.tools.main import mitmdump as mitmdump_entry  # retry after path fix

    listen_port = os.environ.get("PORT", "8080")
    script_path = os.path.abspath(__file__)
    sys.argv = [
        "mitmdump",
        "-s",
        script_path,
        "--listen-host",
        "0.0.0.0",
        "--listen-port",
        str(listen_port),
        "--set",
        "confdir=.",
        "--set",
        "ssl_insecure=true",
    ]
    raise SystemExit(mitmdump_entry())
