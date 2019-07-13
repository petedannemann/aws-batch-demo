import click
from smart_open import open


@click.command()
@click.option('--input-file-path', '-i', help='The path of the input file, local or S3 (s3://...)')
@click.option('--output-file-path', '-o', help='The path of the output file, local or S3 (s3://...)')
def main(input_file_path: str, output_file_path: str) -> None:
    """Simple program that decompresses an input file and writes it to an output file."""
    with open(input_file_path, 'rb') as input_stream:
        with open(output_file_path, 'wb') as output_file:
            for line in input_stream:
                output_file.write(line)

if __name__ == '__main__':
    main()
                