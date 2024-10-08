# icebird-spark

Spark @ CLO
Run a local spark cluster enabled with Apache Iceberg AWS integrations.


### Requirments
- docker && docker-compose

### Configuration

Download jar files from our S3 bucket

```sh
cd spark/
mkdir jars
aws s3 sync s3://ice.bird/jars/ ./jars/ --profile icebird
cd ..
```

Add `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` env variables to the .env.spark file


From the root directory, start the Spark cluster with 4 workers

```sh
docker-compose up --scale spark-worker=4 -d
```

Open the Jupyter notebook in at http://localhost:9999/
