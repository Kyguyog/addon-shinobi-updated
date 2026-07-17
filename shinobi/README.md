# Shinobi Pro Home Assistant Add-on

This folder is a Home Assistant add-on. Home Assistant Supervisor builds and runs it as one container total.

The container starts:

- Shinobi on port `8080`, exposed by Home Assistant as port `7440`.
- A local MariaDB server for Shinobi, stored under `/data/mysql`.
- Shinobi application files and configuration under `/data/shinobi`.

## Configuration

Most settings are configured from the Home Assistant add-on UI and stored in `/data/options.json`.

| Option | Default |
| --- | --- |
| `log_level` | `info` |
| `super_username` | `admin@shinobi.video` |
| `super_password` | `admin` |
| `mysql_username` | `shinobi` |
| `mysql_password` | `sh1n0b1` |
| `mysql_database` | `shinobi` |
| `mysql_root_password` | `rootpassword` |
| `shinobi_update` | `false` |

After starting the add-on, open the web UI and go to `/super` to sign in as the superuser.

## Local Development

`setup_and_run.sh` and `docker-compose-main.yml` are only for local Docker testing outside Home Assistant. They still run one container total and persist data at `$HOME/ShinobiAddon`.
