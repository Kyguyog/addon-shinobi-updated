# Install Shinobi with Docker
#### 2024-05-07
https://shinobi.video
https://docs.shinobi.video/installation/docker

# Quick Install

1. Run this in terminal.
```
bash <(curl -s https://gitlab.com/Shinobi-Systems/Shinobi-Installer/raw/master/shinobi-docker.sh)
```

# Advanced Install

1. Download this repository and enter it.
    - If you **do not have Docker** installed run `sh INSTALL/docker.sh`.
2. Review and modify the `docker-compose-main.yml` file.
    - Leave it as-is for default setup.
3. Run the preparation and starter script.
    ```
    bash setup_and_run.sh
    ```

# Once Installed

The starter script builds and runs one Docker container total. That container runs Shinobi and its local MariaDB service together. Once complete open port 8080 of your Docker host in a web browser.

> The following table offers a breakdown of the configurations that control how the `shinobi` service is set up. Adjustments can be made directly in `docker-compose-main.yml` to modify the behavior of the deployment as needed.

### `docker-compose-main.yml` : `shinobi` Service Build Arguments and Environment Variables

#### Build Arguments

| Argument          | Description                                               | Default Value |
|-------------------|-----------------------------------------------------------|---------------|
| SHINOBI_BRANCH    | The branch of the Shinobi git repository to clone during the build process. | `dev`         |

#### Environment Variables

| Variable          | Description                                          | Default Value |
|-------------------|------------------------------------------------------|---------------|
| HOME              | The home directory path within the container.        | `/home/Shinobi` |
| DB_HOST           | Hostname of the local MariaDB server.                | `127.0.0.1`     |
| DB_PORT           | Port of the local MariaDB server.                    | `3306`          |
| DB_USER           | Username to connect to the local MariaDB database.   | `majesticflame` |
| DB_PASSWORD       | Password to connect to the local MariaDB database.   | `1234`          |
| DB_DATABASE       | Name of the local MariaDB database to use.           | `ccio`          |
| MYSQL_ROOT_PASSWORD | Password for the local MariaDB root user.          | `rootpassword`  |
| SHINOBI_UPDATE    | Whether to pull updates from git when the container starts. | `false`      |


**Script Failing? Run this.**

```
apt install dos2unix -y && dos2unix entrypoint.sh && chmod +x entrypoint.sh && dos2unix setup_and_run.sh && chmod +x setup_and_run.sh && bash setup_and_run.sh
```
