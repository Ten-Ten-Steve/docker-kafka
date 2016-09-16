HOST ?= <PUT YOUR IP HERE>

# You must build the docker image before you do anything
image:
	docker build -t ten_ten_steve/kafka kafka/

# Eventually I'll make this more automatic, For now, I use this handly little make rule to quickly get a host's IP
ip:
	echo "var LOCAL_IP = '$(shell ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1' | awk '{print $1}')'" > local_ip.js

# start the kafka server. This includes kafka and zookeeper running in the same container
run:
	docker run --name kafka \
	-p 2181:2181 -p 9092:9092 \
	--env ADVERTISED_HOST=${HOST} \
	--env ADVERTISED_PORT=9092 \
	ten_ten_steve/kafka

# create the "test" topic
topic:
	docker run -it --rm --name producer \
	ten_ten_steve/kafka \
	kafka-topics.sh --create --zookeeper ${HOST}:2181 --replication-factor 1 --partitions 1 --topic test

# list available topics
list:
	docker run -it --rm --name producer \
	ten_ten_steve/kafka \
	kafka-topics.sh --list --zookeeper ${HOST}:2181

# create a producer container and point it at the kafka/zookeeper server (container)
producer:
	docker run -it --rm --name producer \
	ten_ten_steve/kafka \
	kafka-console-producer.sh --broker-list ${HOST}:9092 --topic test

# create a consumer and point it at the kafka/zookeeper server (container)
consumer:
	docker run -it --rm --name consumer \
	ten_ten_steve/kafka \
	kafka-console-consumer.sh --zookeeper ${HOST}:2181 --topic test