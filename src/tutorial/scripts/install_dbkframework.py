"""Build and installs the dbkframework."""

from pathlib import Path

# import sys
# sys.path.append(str(Path(__file__).parent.parent.joinpath('modules')))
import os
import json
from dbkcore.core import Log
from dbkenv.core import ResourceClient
from dbkenv.core import Configuration
from dbkenv.core import DatabricksResourceManager
import argparse

Log(name=Path(__file__).stem)


def command_exec(command, ignore=False):
    """
    Execute shell command.

    Parameters
    ----------
    command : str
        Command to execute
    ignore : bool, optional
        Ignore exception, by default False

    Raises
    ------
    Exception
        Raises exception if command failes
    """
    Log.get_instance().log_info(f'Running command -> {command}')
    if not ignore:
        if os.system(command) != 0:
            raise Exception(f'Failed to execute: {command}')


def parse_args(args_list=None):
    """
    Parse command line arguments.

    Parameters
    ----------
    args_list : [type], optional
        Argument list, by default None

    Returns
    -------
    ArgumentParser
        Arguments parsed
    """
    parser = argparse.ArgumentParser()
    parser.add_argument('-c', '--config_file', help="Full path of cluster's json configuration", type=str, required=True)
    args_parsed = parser.parse_args(args_list)
    return args_parsed


def main(cluster_config_file):
    """
    Execute the script.

    Parameters
    ----------
    cluster_config_file : str
        Path of the configuration file

    Raises
    ------
    Exception
        Raises when script failes
    """
    configuration = Configuration(file_load=True)
    with open(cluster_config_file.strip(), 'r') as cl:
        cluster_configuration = json.load(cl)

    cluster_name = cluster_configuration['cluster_name']

    client = ResourceClient(
        host=configuration.DATABRICKS_HOST,
        personal_token=configuration.DATABRICKS_TOKEN
    )
    drm = DatabricksResourceManager(
        client=client,
        cluster_name=cluster_name,
        cluster_configuration=cluster_configuration
    )

    cluster_id = drm.cluster.cluster_id

    drm.cluster.start_cluster_and_wait()

    modules_to_deploy = [
        'dbkframework'
    ]

    pipelines_folder = Path(__file__).\
        parent.\
        parent.\
        parent.\
        absolute().\
        joinpath('pipelines')

    for module in modules_to_deploy:

        package_folder = pipelines_folder.joinpath(module)
        dist_folder = package_folder.joinpath('dist')

        setup_file = package_folder.joinpath('setup.py')

        command_string = f"cd {str(package_folder)} && python {str(setup_file)} sdist bdist_wheel"
        res = os.system(command_string)

        if res != 0:
            raise Exception(f'Failed to build {module}')

        wheel = sorted([v for v in dist_folder.glob('*.whl')], key=lambda i: i.stat().st_ctime, reverse=True)[0]
        dbk_whl_name = wheel.name
        dbk_whl_root = 'dbfs:/FileStore/dev/artifacts/'
        dbk_whl_path = f'{dbk_whl_root}{dbk_whl_name}'

        command_exec(f'databricks fs rm {dbk_whl_root}', ignore=True)
        command_exec(f'databricks fs cp -r {wheel} {dbk_whl_path}')

        command_exec(f'databricks libraries uninstall --cluster-id {cluster_id} --whl {dbk_whl_path}')
        command_exec(f'databricks libraries install --cluster-id {cluster_id} --whl {dbk_whl_path}')

    command_exec(f'databricks clusters restart --cluster-id {cluster_id}')


if __name__ == "__main__":
    args = parse_args()
    main(cluster_config_file=args.config_file)
