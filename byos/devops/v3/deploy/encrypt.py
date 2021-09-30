import argparse
from base64 import b64encode
from nacl import encoding, public

# Construct the argument parser
ap = argparse.ArgumentParser()

# Add the arguments to the parser
ap.add_argument("-p", "--publickey", required=True,
                help="public key")
ap.add_argument("-v", "--value", required=True,
                help="value")
args = vars(ap.parse_args())


def encrypt(public_key: str, secret_value: str) -> str:
    """
    Encrypts the secret value using the public key.
    :param public_key: The public key to use for encryption.
    :param secret_value: The value to encrypt.
    :return: The encrypted value.
    """
    public_key = public.PublicKey(
        public_key.encode("utf-8"), encoding.Base64Encoder())
    sealed_box = public.SealedBox(public_key)
    encrypted = sealed_box.encrypt(secret_value.encode("utf-8"))
    return b64encode(encrypted).decode("utf-8")


print(encrypt(args['publickey'], args['value']))
