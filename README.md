# Community Hass.io Add-ons: Shinobi Pro

[![GitHub Release][releases-shield]][releases]
![Project Stage][project-stage-shield]
[![License][license-shield]](LICENSE.md)

![Project Maintenance][maintenance-shield]
[![GitHub Activity][commits-shield]][commits]


![Shinobi screenhost](images/screenshot.jpg)

Beautiful and feature-rich CCTV/NVR for your camera's

## About

Shinobi is Open Source, written in Node.js, and real easy to use. It is the
future of CCTV and NVR for developers and end-users alike. It is catered to
by professionals and most importantly by the one who created it.

Shinobi can be used as a Baby Monitor, Construction Site Montage Viewer,
Store Camera DVR, and much more.

You can use Shinobi Pro for personal use without a license in non-commercial
locations, for educational, or simple testing. Schools, Colleges,
and Universities do not require a subscription.

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Hass.io add-on.

1. [Add our Hass.io add-ons repository][repository] to your Hass.io instance.
1. Install the "Shinobi Pro" add-on.
1. Start the "Shinobi Pro" add-on
1. Check the logs of the "Shinobi Pro" add-on to see if everything went well.
1. Surf to the superuser admin panel: `http://hassio.local:7440/super`
1. Log in with the superuser credentials as specified in the add-on configuration.
1. Create a Shinobi user account.
1. Logout from the superuser panel.

You are now ready to use Shinobi, use the freshly created login from now on.

**NOTE**: Do not add this repository to Hass.io, please use:
`https://github.com/hassio-addons/repository`.

## Configuration

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
log_level: info
super_username: admin@shinobi.video
super_password: admin
mysql: false
mysql_host: core-mariadb
mysql_username: shinobi_test
mysql_password: sh1n0b1_test
mysql_database: shinobi_test
mysql_port: 3306
mail_service: gmail
mail_username: your_email@gmail.com
mail_password: your_password
mail_host: smtp.example.com
mail_port: 587
mail_secure: false
mail_cert_verify: true
ssl: false
certfile: fullchain.pem
keyfile: privkey.pem
```

**Note**: _This is just an example, don't copy and past it! Create your own!_

### Option: `log_level`

The `log_level` option controls the level of log output by the addon and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`:  Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

### Option: `super_username`

The username to access the superuser control panel. This user is an
administrative user. This user does not have cameras to manage nor can it
see any cameras. Its purpose is to manage Admin accounts settings, limitations,
and view system logs.

### Option: `super_password`

The password for superuser of the superuser control panel.

### Option: `mysql`

By default, the add-on uses an internal SQLite database for its data.
Set this option to `true` to enable MySQL as the database backend for this
add-on. You'll need an external database server for this, like the
MariaDB core add-on provided by Home Assistant.

**Note**: _There is no migration system. When using SQLite at first, and
switching to MySQL later on, would result in data loss._

**Note**: _When using the core MariaDB add-on, please be sure to create a
separate database and user for Shinobi. DO NOT use the same database as
Home Assistant._

### Option: `mysql_host`

The hostname of the MySQL server to connect to. In case you are using the
MariaDB core add-on, please use `core-mariadb` as the hostname.

### Option: `mysql_username`

The username to use when connecting to a MySQL server.

### Option: `mysql_password`

The password to use when connecting to a MySQL server.

### Option: `mysql_database`

The MySQL database to store all Shinobi's data in.

**Note**: _DO NOT store Shinobi's data in the same database as Home Assistant!_

### Option: `mysql_port`

The port the MySQL server is running on. Should be `3306` in most cases.

### Option: `mail_service`

The mail service to use. Can be either `smtp` or `gmail`.

### Option: `mail_username`

The username to use when connecting to the mail service.

**Note**: _Please use your full mail address when using `gmail`._

### Option: `mail_password`

The password to use when connecting to the mail service.

### Option: `mail_host`

The `smtp` host or IP to connect to for sending emails.

**Note**: _This option is ignored when using `gmail` as the mail service._

### Option: `mail_port`

The port the `smtp` host is listening on.

**Note**: _This option is ignored when using `gmail` as the mail service._

### Option: `mail_secure`

If `true` the connection will use TLS when connecting to the server. If `false`
(the default) then TLS is used if a server supports the STARTTLS extension.
In most cases set this value to `true` if you are connecting to port 465.
For port 587 or 25 keep it `false`.

**Note**: _This option is ignored when using `gmail` as the mail service._

### Option: `mail_cert_verify`

Setting this to `false` would allow Shinobi to open a connection to
TLS server with self-signed or invalid TLS certificate.

**Note**: _This option is ignored when using `gmail` as the mail service._

### Option: `ssl`

Enables/Disables SSL (HTTPS) on the web interface of Shinobi. Set it `true` to
enable it, `false` otherwise.

**Note**: Enabling SSL would be additional to the already active plain HTTP
server. HTTPS will be available on port `5443`, which, of course, can be changed
in the Hass.io add-on configuration.

### Option: `certfile`

The certificate file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is default for Hass.io_

### Option: `keyfile`

The private key file to use for SSL.

**Note**: _The file MUST be stored in `/ssl/`, which is default for Hass.io_

## Shinobi configuration and user manuals

The add-on does not configure Shinobi for you. For example, you will need to
configure all your camera's and other things yourself.

For more information about configuring Shinobi, please refer to the extensive
documentation they offer:

<https://shinobi.video/docs>

## Setting up the MariaDB core add-on

Setting up Shinobi to use MySQL can be a little complex for some users. So, let
us give you some examples.

First, install the core MariaDB add-on provided by Home Assistant (in case you
didn't already have).

Edit the add-on configuration of MariaDB. We need to do 3 things:

1. Add a database for Shinobi
1. Add a user for Shinobi
1. Give the created user access to the created database.

An example configuration would look like this:

```yaml
databases:
  - homeassistant
  - shinobi
logins:
  - username: homeassistant
    password: PASSWORD
  - username: shinobi
    password: sh1n0b1
rights:
  - username: homeassistant
    database: homeassistant
  - username: shinobi
    database: shinobi
```

After modifying your MariaDB add-on configuration, be sure to restart the
MariaDB add-on.

For the Shinobi add-on configuration, the defaults are matching the MariaDB
example above. So, you'd only need to enable the `mysql` option by setting
it to `true`.

This is a part of the Shinobi add-on configuration that matches the above
example:

```yaml
mysql: true
mysql_host: core-mariadb
mysql_username: shinobi_test
mysql_password: sh1n0b1_test
mysql_database: shinobi_test
mysql_port: 3306
```

Save the configuration and restart the Shinobi add-on. The add-on will create
all database internals (tables and structure) for you, the first time it
connects.

## Embedding into Home Assistant

It is possible to embed Shinobi directly into Home Assistant.
Home Assistant provides the `panel_iframe` component, for these purposes.

Example configuration:

```yaml
panel_iframe:
  shinobi:
    title: Shinobi
    icon: mdi:cctv
    url: http://addres.to.your.hass.io:7440
```

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality. The format of the log is based on
[Keep a Changelog][keepchangelog].

Releases are based on [Semantic Versioning][semver], and use the format
of ``MAJOR.MINOR.PATCH``. In a nutshell, the version will be incremented
based on the following:

- ``MAJOR``: Incompatible or major changes.
- ``MINOR``: Backwards-compatible new features and enhancements.
- ``PATCH``: Backwards-compatible bugfixes and package updates.

## Support

Got questions?

You have several options to get them answered:

- The Home Assistant [Community Forum][forum], we have a
  [dedicated topic][forum] on that forum regarding this add-on.
- The Home Assistant [Discord Chat Server][discord] for general Home Assistant
  discussions and questions.
- Send me a message on [Discord][discord-me].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

## Contributing

This is an active open-source project. We are always open to people who want to
use the code or contribute to it.

We have set up a separate document containing our
[contribution guidelines](CONTRIBUTING.md).

Thank you for being involved! :heart_eyes:

## Authors & contributors

The original setup of this repository is by [Franck Nijhof][frenck].

The updated repository is maintained by [Rob Landry][roblandry]

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## We have got some Hass.io add-ons for you

Want some more functionality to your Hass.io Home Assistant instance?

We have created multiple add-ons for Hass.io. For a full list, check out
our [GitHub Repository][repository].

## License

MIT License

Copyright (c) 2018 Franck Nijhof

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[buymeacoffee-shield]: https://www.buymeacoffee.com/assets/img/guidelines/download-assets-sm-2.svg
[buymeacoffee]: https://www.buymeacoffee.com/roblandry
[commits-shield]: https://img.shields.io/github/commit-activity/y/roblandry/addon-shinobi.svg
[commits]: https://github.com/roblandry/addon-shinobi/commits/master
[contributors]: https://github.com/roblandry/addon-shinobi/graphs/contributors
[discord]: https://discord.gg/c5DvZ4e
[discord-shield]: https://img.shields.io/discord/330944238910963714.svg
[discord-me]: http://discordapp.com/users/378376356108435457
[forum-shield]: https://img.shields.io/badge/community-forum-brightgreen.svg
[forum]: https://community.home-assistant.io/t/hass-addon-shinobi-revival/183349
[frenck]: https://github.com/frenck
[roblandry]: https://github.com/roblandry
[home-assistant]: https://home-assistant.io
[issue]: https://github.com/roblandry/addon-shinobi/issues
[keepchangelog]: http://keepachangelog.com/en/1.0.0/
[license-shield]: https://img.shields.io/github/license/roblandry/addon-shinobi.svg
[maintenance-shield]: https://img.shields.io/maintenance/yes/2020.svg
[project-stage-shield]: https://img.shields.io/badge/project%20stage-beta-yellow.svg
[python-packages]: https://pypi.org/
[reddit]: https://reddit.com/r/homeassistant
[releases-shield]: https://img.shields.io/github/v/release/roblandry/addon-shinobi?include_prereleases
[releases]: https://github.com/roblandry/addon-shinobi/releases
[repository]: https://github.com/hassio-addons/repository
[semver]: http://semver.org/spec/v2.0.0.htm
