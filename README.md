# docker-registry

A [Docker](https://docker.com/) container for [Docker Registry](https://github.com/docker/docker-registry) with [Nginx](http://nginx.org/) in front of it as a reverse proxy for Basic authentication.

![example1](/example1.png)

![example2](/example2.png)

## Run the container

Using the `docker` command:

    CONTAINER="registrydata" && sudo docker run \
      --name "${CONTAINER}" \
      -h "${CONTAINER}" \
      -v /registry \
      simpledrupalcloud/data:latest

    CONTAINER="registry" && sudo docker run \
      --name "${CONTAINER}" \
      -h "${CONTAINER}" \
      -p 80:80 \
      -p 443:443 \
      --volumes-from registrydata \
      -e SERVER_NAME="localhost" \
      -e USERNAME="root" \
      -e PASSWORD="root" \
      -d \
      simpledrupalcloud/registry:latest

Using the `fig` command

    TMP="$(mktemp -d)" \
      && git clone http://git.simpledrupalcloud.com/simpledrupalcloud/docker-registry.git "${TMP}" \
      && cd "${TMP}" \
      && sudo fig up

## Build the image

    TMP="$(mktemp -d)" \
      && git clone http://git.simpledrupalcloud.com/simpledrupalcloud/docker-registry.git "${TMP}" \
      && cd "${TMP}" \
      && sudo docker build -t simpledrupalcloud/registry:latest . \
      && cd -

## Add the certification authority (CA) certificate to your host so the Docker client could communicate with the private registry securely

    sudo wget --no-check-certificate https://localhost/ca -O /usr/local/share/ca-certificates/localhost.crt \
      && sudo update-ca-certificates --fresh \
      && sudo service docker restart

If you are orchestrating Docker containers using [Fig](http://www.fig.sh/) you need to log in to private registry as follows:

    sudo docker login https://localhost/v1/

You can read about the open issue more from here https://github.com/docker/fig/issues/75.

## Start the container automatically

    SERVER_NAME="localhost"
    USERNAME="root"
    PASSWORD="root"

    TMP="$(mktemp -d)" \
      && git clone http://git.simpledrupalcloud.com/simpledrupalcloud/docker-registry.git "${TMP}" \
      && cd "${TMP}" \
      && sudo cp ./fig.yml /opt/registry.yml \
      && sudo sed -i "s/localhost/${SERVER_NAME}/g" /opt/registry.yml \
      && sudo sed -i "s/USERNAME=root/USERNAME=${USERNAME}/g" /opt/registry.yml \
      && sudo sed -i "s/PASSWORD=root/PASSWORD=${PASSWORD}/g" /opt/registry.yml \
      && sudo cp ./registry.conf /etc/init/registry.conf \
      && cd -

## Back up Registry data

    sudo docker run \
      --rm \
      --volumes-from registrydata \
      -v $(pwd):/backup \
      simpledrupalcloud/base:latest tar czvf /backup/registrydata.tar.gz /registry/data /registry/ssl/certs /registry/ssl/private

## Restore Registry data from a backup

    sudo docker run \
      --rm \
      --volumes-from registrydata \
      -v $(pwd):/backup \
      simpledrupalcloud/base:latest tar xzvf /backup/registrydata.tar.gz

## License

**MIT**
