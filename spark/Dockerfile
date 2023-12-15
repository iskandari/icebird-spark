FROM apache/spark:latest

USER root

# Install Python and Jupyter
RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install jupyter && \
    rm -rf /var/lib/apt/lists/*
    
# Make entrypoint script executable
COPY entrypoint.sh /opt/
RUN chmod +x /opt/entrypoint.sh

# Install Maven and required jars
RUN apt-get update && \
    apt-get install -y maven && \
    rm -rf /var/lib/apt/lists/*

RUN mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=org.apache.hadoop:hadoop-aws:3.3.6 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=org.apache.iceberg:iceberg-spark-runtime-3.2_2.12:0.14.0 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=software.amazon.awssdk:url-connection-client:2.17.178 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=software.amazon.awssdk:bundle:2.17.178 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=org.apache.sedona:sedona-spark-shaded-3.4_2.12:1.5.0 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=org.datasyslab:geotools-wrapper:1.5.0-28.2 && \
    mvn dependency:get -DremoteRepositories=central::default::https://repo.maven.apache.org/maven2 -Ddest=/opt/spark/jars/ -Dartifact=org.apache.spark:spark-hadoop-cloud_2.13:3.5.0

# Expose ports for Spark UI and services
EXPOSE 4040 8080 8081 7077

ENV AWS_REGION=us-east-1
ENV PATH="/opt/spark/sbin:/opt/spark/bin:${PATH}"
ENV SPARK_HOME="/opt/spark"
ENV SPARK_MASTER="spark://spark-master:7077"
ENV SPARK_MASTER_HOST spark-master
ENV SPARK_MASTER_PORT 7077
ENV PYSPARK_PYTHON python3

COPY conf/spark-defaults.conf "$SPARK_HOME/conf"

RUN chmod u+x /opt/spark/sbin/* && \
    chmod u+x /opt/spark/bin/*

ENTRYPOINT ["/opt/entrypoint.sh", "master"]
