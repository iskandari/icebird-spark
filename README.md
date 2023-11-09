# icebird-spark

Spark @ CLO
Run a local spark cluster enabled with Apache Iceberg AWS integrations.

## Docker Setup

### Prerequisites

Before you begin, ensure you have the following prerequisites installed and configured:

- **Docker**: Please follow the [Docker installation guide](https://docs.docker.com/get-docker/).
- **AWS CLI**: Ensure AWS CLI is installed and configured for SSO. Follow the [AWS CLI configuration guide](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sso.html).
- **`aws-sso-creds` y**: Helper utility for managing AWS SSO credentials [repo](https://github.com/jaxxstorm/aws-sso-creds).

### Configuration

To interact with AWS services from within the Spark cluster the following environment variables must set:

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_SESSION_TOKEN`
- `AWS_REGION`

These credentials are necessary for Spark executors to authenticate with AWS services.

#### Setting up AWS SSO 

If you are using AWS Single Sign-On (SSO), export temporary credentials via the `aws-sso-creds` utility. 

```sh
aws sso login --profile my-sso-profile
aws-sso-creds export -p my-sso-profile

#export region
export AWS_REGION=us-east-1

#show env variables
env | grep AWS_
```

## Starting the Spark cluster

With your AWS credentials set, you can now start your Spark cluster


In the same directory as the Dockerfile, build the container:
```sh
docker build -t my-custom-spark-image:latest .
```
Start the Spark cluster with 3 workers
```sh
docker-compose up --scale spark-worker=3
```
To run the cluster in the background, add the -d flag:
```sh
docker-compose up -d --scale spark-worker=3
```

## Connecting with Python

```python

jars_packages = (
    "org.apache.hadoop:hadoop-aws:3.3.6,"
    "org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:0.14.0,"
    "software.amazon.awssdk:url-connection-client:2.17.178,"
    "software.amazon.awssdk:bundle:2.17.178"
)

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Iceberg with Jupyter") \
    .master("spark://localhost:7077") \
    .config("spark.driver.memory", "30g") \
    .config("spark.executor.memory", "15g") \
    .config("spark.jars.packages", jars_packages) \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.warehouse", warehouse_dir) \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.sql.catalog.local", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.local.type", "hadoop") \
    .config("spark.sql.catalog.local.warehouse", "s3a://icevogel") \
    .config("spark.sql.catalog.my_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.hadoop.fs.s3a.fast.upload", "true") \
    .config("spark.hadoop.fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "org.apache.hadoop.fs.s3a.TemporaryAWSCredentialsProvider") \
    .getOrCreate()


from pyspark.sql import functions as F
from pyspark.sql.types import DecimalType


df_sum_birds = df_hist.groupBy("location") \
    .agg(F.sum("birds_passed").alias("total_birds_passed")) \
    .withColumn("total_birds_passed", F.col("total_birds_passed").cast(DecimalType(18, 2))) \
    .orderBy(F.col("total_birds_passed").desc())

df_sum_birds.show()
```



## Stopping the cluster

```sh
docker-compose down
```