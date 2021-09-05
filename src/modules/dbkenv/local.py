import pyspark.databricks_connect as _dbc


__author__ = "Davide Fornelli"
__copyright__ = "Copyright 2021 Microsoft Corporation, MCS ACAI Accelerator."
__credits__ = ["Davide Fornelli"]
__version__ = "0.1"
__maintainer__ = "Davide Fornelli"
__email__ = "daforne@microsoft.com"
__status__ = "Development"


class DatabricksLocal:
    """
    Sets up the local environment to use a remote instance of Databricks
    """
    def __init__(
        self,
        host: str,
        databricks_token: str,
        cluster_id: str,
        org_id: str,
        port=15001
    ):
        """
        Instantiates this object.

        Parameters
        ----------
        host : str
            Databricks host
        databricks_token : str
            Personal token
        cluster_id : str
            Cluster's id
        org_id : str
            Organization id
        port : int, optional
            Port for connection, by default 15001
        """
        self.host = host
        self.databricks_token = databricks_token
        self.cluster_id = cluster_id
        self.org_id = org_id
        self.port = port

    def initialize(self):
        """Initialize the configuration."""
        _dbc.save_config(
            host=self.host,
            token=self.databricks_token,
            cluster=self.cluster_id,
            org_id=self.org_id,
            port=self.port
        )
        _dbc.test()
        return True
