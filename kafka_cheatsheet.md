Kafka Cheatsheet
-----------------


## Kafka Operations

* Run the commands on any of the kafka brokers (APIs in v0.10)


### List all Kafka Topics

> /opt/kafka/bin/kafka-topics.sh --zookeeper <ip/hostname of zookeeper>:2181 --list 


### Describe a topic (number of partitions and other policies)

> /opt/kafka/bin/kafka-topics.sh --zookeeper <ip/hostname of zookeeper>:2181 --describe --topic <topic-name>


### Create topic

* General rule of thumb for replication factor = (number of brokers * 1)/2

* Number of partitions should be determined based on the throughput and clients. More number of partitions negatively impacts latency/availability

> /opt/kafka/bin/kafka-topics.sh --zookeeper <ip/hostname of zookeeper>:2181 --create --replication-factor 2 --partitions 8 --topic <topic_name>


### Replica Election Tool

> /opt/kafka/bin/kafka-preferred-replica-election.sh  -zookeeper <ip/hostname of zookeeper> --path-to-json-file topicPartitionList.json



### Alter topic

> /opt/kafka/bin/kafka-topics.sh --zookeeper localhost:2181 --alter --topic my-topic --config max.message.bytes=128000

* It is possible to increase the number of partitions per topic but you cannot reduce the number of partitions once created

>bin/kafka-topics.sh --zookeeper zk_host:port/chroot --alter --topic my_topic_name  --partitions 40



### Check registered brokers in zookeeper namespace

> ./zookeeper-shell.sh localhost:2181 <<< "ls /brokers/ids"


### Using kafka-configs
> /opt/kafka/bin/kafka-configs.sh  --zookeeper <zk ip>:2181 --entity-type topics \
    --describe --entity-name <topic-name>

* Note: Adding and removing config from a topic should be done using kafka-configs.sh

### Add config

> /opt/kafka/bin/kafka-configs.sh  --zookeeper <zk-ip>:2181  --entity-type topics   \
  --alter --entity-name <topic-name> --add-config retention.ms=86400000 


### remove config using kafka-configs

> /opt/kafka/bin/kafka-configs.sh  --zookeeper <zk-ip>:2181 --alter --entity-type topics \
   --entity-name <topic-name> --delete-config retention.ms 

### Read kafka topic

> bin/kafka-console-consumer.sh --zookeeper localhost:2181 --topic <topic-name> --from-beginning

###  Delete topic

> /opt/kafka/bin/kafka-topics.sh --zookeeper <zk ip>:2181 --delete --topic <topic-name>
