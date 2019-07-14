from datetime import datetime, timedelta
import os

from airflow import DAG
from airflow.contrib.operators.awsbatch_operator import AWSBatchOperator
import yaml


AWS_BATCH_JOB_DEFINITION = AWS_BATCH_JOB_QUEUE = 'aws-batch-example'
DECOMPRESS_COMMAND_TEMPLATE = '''
    decompress-decrypt
    decompress
    --input-file-path {input_file_path}
    --output-file-path {output_file_path}
'''
DECRYPT_COMMAND_TEMPLATE = '''
    decompress-decrypt
    decrypt
    --input-file-path {input_file_path}
    --output-file-path {output_file_path}
    --encryption-key {encryption_key}
'''

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2015, 6, 1),
    'email_on_retry': False,
    'retries': 0,
    'retry_delay': timedelta(minutes=5),
}

def dag_factory(
        dag_id: str,
        input_file_path: str,
        decompressed_file_path: str,
        output_file_path: str,
        schedule_interval: str,
        encryption_key: str) -> None:

    with DAG(
            dag_id=dag_id,
            schedule_interval=schedule_interval,
            default_args=default_args,
            max_active_runs=1,
    ) as dag:

        decompress = AWSBatchOperator(
            task_id='decompress',
            job_name=dag_id,
            job_definition=AWS_BATCH_JOB_DEFINITION,
            job_queue=AWS_BATCH_JOB_QUEUE,
            overrides={
                'command': DECOMPRESS_COMMAND_TEMPLATE.format(
                    input_file_path=input_file_path,
                    output_file_path=decompressed_file_path,
                    ).split()
            }
        )

        decrypt = AWSBatchOperator(
            task_id='decrypt',
            job_name=dag_id,
            job_definition=AWS_BATCH_JOB_DEFINITION,
            job_queue=AWS_BATCH_JOB_QUEUE,
            overrides={
                'command': DECRYPT_COMMAND_TEMPLATE.format(
                    input_file_path=decompressed_file_path,
                    output_file_path=output_file_path,
                    encryption_key=encryption_key,
                    ).split()
            }
        )

        decompress >> decrypt

        globals()[dag_id] = dag # Airflow looks at the module global vars for DAG type variables

for dag_config_file in os.listdir(os.path.join('dags', 'dag_config')):
    # Use the name of the file w/o the extension
    dag_id = dag_config_file.split('.')[0]

    with open(os.path.join('dags', 'dag_config', dag_config_file)) as f:
        yaml_data = yaml.safe_load(f.read())

        input_file_path = yaml_data.get('input_file_path')
        decompressed_file_path = yaml_data.get('decompressed_file_path')
        output_file_path = yaml_data.get('output_file_path')
        schedule_interval = yaml_data.get('schedule_interval')
        encryption_key = yaml_data.get('encryption_key')

    dag_factory(
        dag_id=dag_id,
        input_file_path=input_file_path,
        decompressed_file_path=decompressed_file_path,
        output_file_path=output_file_path,
        schedule_interval=schedule_interval,
        encryption_key=encryption_key
    )
