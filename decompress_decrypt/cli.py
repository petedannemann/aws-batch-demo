import logging

from cryptography.fernet import Fernet
import click
from smart_open import open

logging.basicConfig(format='%(levelname)s:%(message)s', level=logging.INFO)

@click.group()
def main():
    """Comand line tool to decompress and decrypt files."""
    pass


@main.command()
@click.option('--input-file-path', '-i', help='The path of the input file, local or S3 (s3://...)')
@click.option('--output-file-path', '-o', help='The path of the output file, local or S3 (s3://...)')
def decompress(input_file_path: str, output_file_path: str) -> None:
    """Simple program that decompresses an input file and writes it to an output file."""
    logging.info(
        'Decompressing %s to %s' % (input_file_path, output_file_path)
    )

    with open(input_file_path, 'rb') as input_stream:
        with open(output_file_path, 'wb') as output_file:
            for line in input_stream:
                output_file.write(line)

    logging.info('Decompression completed successfully!')


@main.command()
@click.option('--input-file-path', '-i', help='The path of the input file, local or S3 (s3://...)')
@click.option('--output-file-path', '-o', help='The path of the output file, local or S3 (s3://...)')
@click.option('--fernet-key', '-f', help='The decrpytion key.')
def decrypt(input_file_path: str, output_file_path: str, fernet_key: str) -> None:
    """Simple program that decrypts an input file and writes it to an output file."""
    logging.info(
        'Decrypting %s to %s' % (input_file_path, output_file_path)
    )

    decryptor = Fernet(fernet_key)

    with open(input_file_path, 'rb') as input_stream:
        with open(output_file_path, 'wb') as output_file:
            for line in input_stream:
                decrypted_line = decryptor.decrypt(line)
                output_file.write(decrypted_line)

    logging.info('Decompression completed successfully!')

if __name__ == '__main__':
    main()
                