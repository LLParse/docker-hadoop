DOCKER_NETWORK = docker-hadoop_default
ENV_FILE = hadoop.env
OWNER = llparse
current_branch := $(shell git rev-parse --abbrev-ref HEAD)
build:
	docker build -t ${OWNER}/hadoop-base:$(current_branch) ./base
	docker build -t ${OWNER}/hadoop-namenode:$(current_branch) ./namenode
	docker build -t ${OWNER}/hadoop-datanode:$(current_branch) ./datanode
	docker build -t ${OWNER}/hadoop-resourcemanager:$(current_branch) ./resourcemanager
	docker build -t ${OWNER}/hadoop-nodemanager:$(current_branch) ./nodemanager
	docker build -t ${OWNER}/hadoop-historyserver:$(current_branch) ./historyserver
	docker build -t ${OWNER}/hadoop-submit:$(current_branch) ./submit

wordcount:
	docker build -t hadoop-wordcount ./submit
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${OWNER}/hadoop-base:$(current_branch) hdfs dfs -mkdir -p /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${OWNER}/hadoop-base:$(current_branch) hdfs dfs -copyFromLocal -f /opt/hadoop-3.2.1/README.txt /input/
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} hadoop-wordcount
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${OWNER}/hadoop-base:$(current_branch) hdfs dfs -cat /output/*
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${OWNER}/hadoop-base:$(current_branch) hdfs dfs -rm -r /output
	docker run --network ${DOCKER_NETWORK} --env-file ${ENV_FILE} ${OWNER}/hadoop-base:$(current_branch) hdfs dfs -rm -r /input
