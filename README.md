# icebird-spark

Spark @ CLO
Run a local spark cluster enabled with Apache Iceberg AWS integrations.

## Docker Setup

### Configuration


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


Define a config for your Spark context

```python

warehouse_dir = "s3a://icevogel/"

jars_packages = (
    "org.apache.hadoop:hadoop-aws:3.3.6,"
    "org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:0.14.0,"
    "software.amazon.awssdk:url-connection-client:2.17.178,"
    "software.amazon.awssdk:bundle:2.17.178,"
    "org.apache.sedona:sedona-spark-shaded-3.4_2.12:1.5.0,"
    "org.datasyslab:geotools-wrapper:1.5.0-28.2,"
    "org.apache.spark:spark-hadoop-cloud_2.13:3.5.0"
)

from pyspark.sql import SparkSession

from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("Iceberg with Jupyter") \
    .master("local[*]") \
    .config("spark.driver.memory", "30g") \
    .config("spark.executor.memory", "15g") \
    .config("spark.dynamicAllocation.enabled", "true") \
    .config("spark.shuffle.service.enabled", "true") \
    .config("spark.dynamicAllocation.maxExecutors", "10") \
    .config("spark.jars.packages", jars_packages) \
    .config("mapreduce.fileoutputcommitter.algorithm.version", "2") \
    .config("spark.sql.catalog.glue_catalog", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.glue_catalog.warehouse", warehouse_dir) \
    .config("spark.sql.catalog.glue_catalog.catalog-impl", "org.apache.iceberg.aws.glue.GlueCatalog") \
    .config("spark.sql.catalog.glue_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.sql.catalog.local", "org.apache.iceberg.spark.SparkCatalog") \
    .config("spark.sql.catalog.local.type", "hadoop") \
    .config("spark.sql.catalog.local.warehouse", "s3a://icevogel") \
    .config("spark.sql.catalog.my_catalog.io-impl", "org.apache.iceberg.aws.s3.S3FileIO") \
    .config("spark.hadoop.fs.s3a.fast.upload", "true") \
    .config("spark.hadoop.fs.s3a.bucket.all.committer.magic.enabled", "true") \
    .config("spark.hadoop.fs.s3.impl", "org.apache.hadoop.fs.s3a.S3AFileSystem") \
    .config("spark.hadoop.fs.s3a.aws.credentials.provider", "com.amazonaws.auth.profile.ProfileCredentialsProvider") \
    .config("spark.hadoop.fs.s3a.access.key", credentials['AccessKeyId']) \
    .config("spark.hadoop.fs.s3a.secret.key", credentials['SecretAccessKey']) \
    .config("spark.hadoop.fs.s3a.connection.timeout", "60000")  \
    .config("spark.hadoop.fs.s3a.socket.timeout", "180000") \
    .config("spark.serializer", KryoSerializer.getName) \
    .config("spark.kryo.registrator",  SedonaKryoRegistrator.getName) \
    .config('spark.sql.session.timeZone', 'UTC') \
    .config("spark.sql.sources.partitionOverwriteMode", "dynamic") \
    .getOrCreate()

from pyspark.sql import functions as F
from pyspark.sql.types import DecimalType

#load data from the catalog
df_hist = spark.read \
    .format("iceberg") \
    .load("glue_catalog.dashboard.hist")


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